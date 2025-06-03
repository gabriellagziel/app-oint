// Copyright (c) 2017, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// @docImport 'package:analyzer/src/generated/engine.dart';
library;

import 'dart:async';
import 'dart:collection';
import 'dart:typed_data';

import 'package:analyzer/dart/analysis/declared_variables.dart';
import 'package:analyzer/file_system/file_system.dart';
import 'package:analyzer/src/context/context.dart';
import 'package:analyzer/src/dart/analysis/analysis_options_map.dart';
import 'package:analyzer/src/dart/analysis/byte_store.dart';
import 'package:analyzer/src/dart/analysis/driver.dart';
import 'package:analyzer/src/dart/analysis/driver_event.dart';
import 'package:analyzer/src/dart/analysis/file_state.dart';
import 'package:analyzer/src/dart/analysis/info_declaration_store.dart';
import 'package:analyzer/src/dart/analysis/library_graph.dart';
import 'package:analyzer/src/dart/analysis/performance_logger.dart';
import 'package:analyzer/src/dart/analysis/session.dart';
import 'package:analyzer/src/dart/element/element.dart';
import 'package:analyzer/src/exception/exception.dart';
import 'package:analyzer/src/fine/library_manifest.dart';
import 'package:analyzer/src/fine/requirements.dart';
import 'package:analyzer/src/generated/source.dart';
import 'package:analyzer/src/summary/package_bundle_reader.dart';
import 'package:analyzer/src/summary2/bundle_reader.dart';
import 'package:analyzer/src/summary2/data_reader.dart';
import 'package:analyzer/src/summary2/data_writer.dart';
import 'package:analyzer/src/summary2/link.dart';
import 'package:analyzer/src/summary2/linked_element_factory.dart';
import 'package:analyzer/src/summary2/reference.dart';
import 'package:analyzer/src/util/performance/operation_performance.dart';
import 'package:collection/collection.dart';

/// Context information necessary to analyze one or more libraries within an
/// [AnalysisDriver].
///
/// Currently this is implemented as a wrapper around [AnalysisContext].
class LibraryContext {
  final LibraryContextTestData? testData;
  final PerformanceLog logger;
  final ByteStore byteStore;
  final StreamController<Object>? eventsController;
  final InfoDeclarationStore infoDeclarationStore;
  final FileSystemState fileSystemState;
  final File? packagesFile;
  final SummaryDataStore store = SummaryDataStore();

  late final AnalysisContextImpl analysisContext;
  late final LinkedElementFactory elementFactory;

  Set<LibraryCycle> loadedBundles = Set.identity();
  final LinkedBundleProvider linkedBundleProvider;

  LibraryContext({
    required this.testData,
    required AnalysisSessionImpl analysisSession,
    required this.logger,
    required this.byteStore,
    required this.eventsController,
    required this.infoDeclarationStore,
    required this.fileSystemState,
    required this.linkedBundleProvider,
    required AnalysisOptionsMap analysisOptionsMap,
    required DeclaredVariables declaredVariables,
    required SourceFactory sourceFactory,
    required this.packagesFile,
    required SummaryDataStore? externalSummaries,
  }) {
    testData?.instance = this;

    analysisContext = AnalysisContextImpl(
      analysisOptionsMap: analysisOptionsMap,
      declaredVariables: declaredVariables,
      sourceFactory: sourceFactory,
    );

    elementFactory = LinkedElementFactory(
      analysisContext,
      analysisSession,
      Reference.root(),
    );
    if (externalSummaries != null) {
      for (var bundle in externalSummaries.bundles) {
        elementFactory.addBundle(
          BundleReader(
            elementFactory: elementFactory,
            resolutionBytes: bundle.resolutionBytes,
            unitsInformativeBytes: {},
            infoDeclarationStore: infoDeclarationStore,
            libraryManifests: {},
          ),
        );
      }
    }
  }

  /// Computes a [CompilationUnitElementImpl] for the given library/unit pair.
  CompilationUnitElementImpl computeUnitElement(
    LibraryFileKind library,
    FileState unit,
  ) {
    var reference = elementFactory.rootReference
        .getChild(library.file.uriStr)
        .getChild('@fragment')
        .getChild(unit.uriStr);
    var element = elementFactory.elementOfReference(reference);
    return element as CompilationUnitElementImpl;
  }

  /// Notifies this object that it is about to be discarded.
  ///
  /// Returns the keys of the artifacts that are no longer used.
  Set<String> dispose() {
    var keys = unloadAll();
    elementFactory.dispose();
    testData?.instance = null;
    return keys;
  }

  /// Get the [LibraryElementImpl] for the given library.
  LibraryElementImpl getLibraryElement(Uri uri) {
    _createElementFactoryTypeProvider();
    return elementFactory.libraryOfUri2(uri);
  }

  /// Load data required to access elements of the given [targetLibrary].
  void load({
    required LibraryFileKind targetLibrary,
    required OperationPerformanceImpl performance,
  }) {
    var librariesTotal = 0;
    var librariesLoaded = 0;
    var librariesLinked = 0;
    var librariesLinkedTimer = Stopwatch();
    var bytesGet = 0;
    var bytesPut = 0;

    void loadBundle(LibraryCycle cycle) {
      if (!loadedBundles.add(cycle)) return;
      addToLogRing('[load][cycle: $cycle]');

      performance.getDataInt('cycleCount').increment();
      performance.getDataInt('libraryCount').add(cycle.libraries.length);

      librariesTotal += cycle.libraries.length;

      for (var directDependency in cycle.directDependencies) {
        loadBundle(directDependency);
      }

      var unitsInformativeBytes = <Uri, Uint8List>{};
      for (var library in cycle.libraries) {
        for (var file in library.files) {
          unitsInformativeBytes[file.uri] = file.unlinked2.informativeBytes;
        }
      }

      var bundleEntry = linkedBundleProvider.get(cycle.linkedKey);

      var inputLibraryManifests = <Uri, LibraryManifest>{};
      if (withFineDependencies && bundleEntry != null) {
        var isSatisfied = performance.run(
          'libraryContext(isSatisfied)',
          (performance) {
            inputLibraryManifests = bundleEntry!.libraryManifests;
            // If anything change in the API signature, relink the cycle.
            // But use previous manifests to reuse item versions.
            if (bundleEntry.apiSignature != cycle.nonTransitiveApiSignature) {
              return false;
            } else {
              var requirements = bundleEntry.requirements;
              var failure = requirements.isSatisfied(
                elementFactory: elementFactory,
                libraryManifests: elementFactory.libraryManifests,
              );
              if (failure != null) {
                eventsController?.add(
                  CannotReuseLinkedBundle(
                    elementFactory: elementFactory,
                    cycle: cycle,
                    failure: failure,
                  ),
                );
                return false;
              }
            }
            return true;
          },
        );
        if (!isSatisfied) {
          bundleEntry = null;
        }
      }

      if (bundleEntry == null) {
        librariesLinkedTimer.start();

        testData?.linkedCycles.add(
          cycle.libraries.map((e) => e.file.path).toSet(),
        );

        Uint8List linkedBytes;
        try {
          if (withFineDependencies) {
            var requirements = RequirementsManifest();
            globalResultRequirements = requirements;

            var linkResult = performance.run('link', (performance) {
              return link(
                elementFactory: elementFactory,
                apiSignature: cycle.nonTransitiveApiSignature,
                performance: performance,
                inputLibraries: cycle.libraries,
                inputLibraryManifests: inputLibraryManifests,
              );
            });
            globalResultRequirements = null;
            linkedBytes = linkResult.resolutionBytes;

            var newLibraryManifests = <Uri, LibraryManifest>{};
            performance.run('computeManifests', (performance) {
              newLibraryManifests = LibraryManifestBuilder(
                elementFactory: elementFactory,
                inputLibraries: cycle.libraries,
                inputManifests: inputLibraryManifests,
              ).computeManifests(
                performance: performance,
              );
              elementFactory.libraryManifests.addAll(newLibraryManifests);
            });

            requirements.addExports(
              elementFactory: elementFactory,
              libraryUriSet: cycle.libraryUris,
            );
            requirements.removeReqForLibs(cycle.libraryUris);

            bundleEntry = LinkedBundleEntry(
              apiSignature: cycle.nonTransitiveApiSignature,
              libraryManifests: newLibraryManifests,
              requirements: requirements,
              linkedBytes: linkedBytes,
            );
            linkedBundleProvider.put(
              key: cycle.linkedKey,
              entry: bundleEntry,
            );

            eventsController?.add(
              LinkLibraryCycle(
                elementFactory: elementFactory,
                cycle: cycle,
                requirements: requirements,
              ),
            );
          } else {
            var linkResult = performance.run('link', (performance) {
              return link(
                elementFactory: elementFactory,
                apiSignature: cycle.nonTransitiveApiSignature,
                performance: performance,
                inputLibraries: cycle.libraries,
                inputLibraryManifests: inputLibraryManifests,
              );
            });
            linkedBytes = linkResult.resolutionBytes;

            bundleEntry = LinkedBundleEntry(
              apiSignature: cycle.nonTransitiveApiSignature,
              libraryManifests: {},
              requirements: RequirementsManifest(),
              linkedBytes: linkedBytes,
            );
            linkedBundleProvider.put(
              key: cycle.linkedKey,
              entry: bundleEntry,
            );

            eventsController?.add(
              LinkLibraryCycle(
                elementFactory: elementFactory,
                cycle: cycle,
                requirements: null,
              ),
            );
          }
          librariesLinked += cycle.libraries.length;
        } catch (exception, stackTrace) {
          _throwLibraryCycleLinkException(cycle, exception, stackTrace);
        }

        performance.getDataInt('bytesPut').add(linkedBytes.length);
        testData?.forCycle(cycle).putKeys.add(cycle.linkedKey);
        bytesPut += linkedBytes.length;

        librariesLinkedTimer.stop();
      } else {
        var linkedBytes = bundleEntry.linkedBytes;
        testData?.forCycle(cycle).getKeys.add(cycle.linkedKey);
        performance.getDataInt('bytesGet').add(linkedBytes.length);
        performance.getDataInt('libraryLoadCount').add(cycle.libraries.length);
        // TODO(scheglov): Take / clear parsed units in files.
        bytesGet += linkedBytes.length;
        librariesLoaded += cycle.libraries.length;
        eventsController?.add(
          ReuseLinkLibraryCycleBundle(cycle: cycle),
        );
        var bundleReader = performance.run('bundleReader', (performance) {
          return BundleReader(
            elementFactory: elementFactory,
            unitsInformativeBytes: unitsInformativeBytes,
            resolutionBytes: linkedBytes,
            infoDeclarationStore: infoDeclarationStore,
            libraryManifests: bundleEntry!.libraryManifests,
          );
        });
        elementFactory.addBundle(bundleReader);
        elementFactory.libraryManifests.addAll(
          bundleEntry.libraryManifests,
        );
        addToLogRing('[load][addedBundle][cycle: $cycle]');
      }
    }

    var libraryCycle = performance.run('libraryCycle', (performance) {
      fileSystemState.newFileOperationPerformance = performance;
      try {
        return targetLibrary.libraryCycle;
      } finally {
        fileSystemState.newFileOperationPerformance = null;
      }
    });

    if (loadedBundles.contains(libraryCycle)) {
      return;
    }

    logger.run('Prepare linked bundles', () {
      loadBundle(libraryCycle);
      logger.writeln(
        '[librariesTotal: $librariesTotal]'
        '[librariesLoaded: $librariesLoaded]'
        '[librariesLinked: $librariesLinked]'
        '[librariesLinkedTimer: ${librariesLinkedTimer.elapsedMilliseconds} ms]'
        '[bytesGet: $bytesGet][bytesPut: $bytesPut]',
      );
    });

    // There might be a rare (and wrong) situation, when the external summaries
    // already include the [targetLibrary]. When this happens, [loadBundle]
    // exists without doing any work. But the type provider must be created.
    _createElementFactoryTypeProvider();
  }

  /// Remove libraries represented by the [removed] files.
  /// If we need these libraries later, we will relink and reattach them.
  void remove(Set<FileState> removed, Set<String> removedKeys) {
    elementFactory.removeLibraries(
      removed.map((e) => e.uri).toSet(),
    );

    loadedBundles.removeWhere((cycle) {
      var cycleFiles = cycle.libraries.map((e) => e.file);
      if (cycleFiles.any(removed.contains)) {
        removedKeys.add(cycle.linkedKey);
        return true;
      }
      return false;
    });
  }

  /// Unloads all loaded bundles.
  ///
  /// Returns the keys of the artifacts that are no longer used.
  Set<String> unloadAll() {
    var keySet = <String>{};
    var uriSet = <Uri>{};

    for (var cycle in loadedBundles) {
      keySet.add(cycle.linkedKey);
      uriSet.addAll(cycle.libraries.map((e) => e.file.uri));
    }

    elementFactory.removeLibraries(uriSet);
    loadedBundles.clear();

    return keySet;
  }

  /// Ensure that type provider is created.
  void _createElementFactoryTypeProvider() {
    if (!analysisContext.hasTypeProvider) {
      elementFactory.createTypeProviders(
        elementFactory.dartCoreElement,
        elementFactory.dartAsyncElement,
      );
    }
  }

  /// The [exception] was caught during the [cycle] linking.
  ///
  /// Throw another exception that wraps the given one, with more information.
  Never _throwLibraryCycleLinkException(
    LibraryCycle cycle,
    Object exception,
    StackTrace stackTrace,
  ) {
    var fileContentMap = <String, String>{};
    for (var library in cycle.libraries) {
      for (var file in library.files) {
        fileContentMap[file.path] = file.content;
      }
    }
    throw CaughtExceptionWithFiles(exception, stackTrace, fileContentMap);
  }
}

class LibraryContextTestData {
  final FileSystemTestData fileSystemTestData;

  // TODO(scheglov): Use [libraryCycles] and textual dumps for the driver too.
  final List<Set<String>> linkedCycles = [];

  /// Keys: the sorted list of library files.
  final Map<List<FileTestData>, LibraryCycleTestData> libraryCycles =
      LinkedHashMap(
    hashCode: Object.hashAll,
    equals: const ListEquality<FileTestData>().equals,
  );

  /// The current instance of [LibraryContext].
  LibraryContext? instance;

  LibraryContextTestData({
    required this.fileSystemTestData,
  });

  LibraryCycleTestData forCycle(LibraryCycle cycle) {
    var files = cycle.libraries.map((library) {
      var file = library.file;
      return fileSystemTestData.forFile(file.resource, file.uri);
    }).toList();
    files.sortBy((fileData) => fileData.file.path);

    return libraryCycles[files] ??= LibraryCycleTestData();
  }
}

class LibraryCycleTestData {
  final List<String> getKeys = [];
  final List<String> putKeys = [];
}

/// The entry in [LinkedBundleProvider].
class LinkedBundleEntry {
  /// See [LibraryCycle.nonTransitiveApiSignature].
  final String apiSignature;

  /// The manifests of libraries in [linkedBytes].
  ///
  /// If we have to relink libraries, we will match new elements against
  /// these old manifests, and reuse IDs for not affected elements.
  final Map<Uri, LibraryManifest> libraryManifests;

  /// The requirements of libraries in [linkedBytes].
  ///
  /// These requirements are to the libraries in dependencies.
  ///
  /// If [withFineDependencies] is `false`, the requirements are empty.
  final RequirementsManifest requirements;

  /// The serialized libraries, for [BundleReader].
  final Uint8List linkedBytes;

  LinkedBundleEntry({
    required this.apiSignature,
    required this.libraryManifests,
    required this.requirements,
    required this.linkedBytes,
  });
}

/// The cache of serialized libraries.
///
/// It is used for performance reasons to avoid reading requirements again
/// and again. Currently after a change to a file with many transitive clients
/// we discard all libraries, and then try to load them again, checking the
/// requirements.
///
/// We also use [BundleReader] to read library headers (not full libraries),
/// but this is relatively cheap.
class LinkedBundleProvider {
  final ByteStore byteStore;

  /// The cache of deserialized bundles, used only when [withFineDependencies]
  /// to avoid reading requirements and manifests again and again.
  ///
  /// The keys are [LibraryCycle.linkedKey].
  final Map<String, LinkedBundleEntry> map = {};

  LinkedBundleProvider({
    required this.byteStore,
  });

  LinkedBundleEntry? get(String key) {
    if (map[key] case var entry?) {
      return entry;
    }

    var bytes = byteStore.get(key);
    if (bytes == null) {
      return null;
    }

    var reader = SummaryDataReader(bytes);
    var apiSignature = reader.readStringUtf8();
    var libraryManifests = reader.readMap(
      readKey: () => reader.readUri(),
      readValue: () => LibraryManifest.read(reader),
    );
    var requirements = RequirementsManifest.read(reader);
    var linkedBytes = reader.readUint8List();

    var result = LinkedBundleEntry(
      apiSignature: apiSignature,
      libraryManifests: libraryManifests,
      requirements: requirements,
      linkedBytes: linkedBytes,
    );

    if (withFineDependencies) {
      map[key] = result;
    }

    // We have copies of all data.
    byteStore.release([key]);

    return result;
  }

  void put({
    required String key,
    required LinkedBundleEntry entry,
  }) {
    var sink = BufferedSink();

    sink.writeStringUtf8(entry.apiSignature);
    sink.writeMap(
      entry.libraryManifests,
      writeKey: (uri) => sink.writeUri(uri),
      writeValue: (manifest) => manifest.write(sink),
    );
    entry.requirements.write(sink);
    sink.writeUint8List(entry.linkedBytes);

    var bytes = sink.takeBytes();
    byteStore.putGet(key, bytes);

    if (withFineDependencies) {
      map[key] = entry;
    }
  }
}
