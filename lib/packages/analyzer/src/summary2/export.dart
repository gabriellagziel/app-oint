// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/src/dart/element/element.dart';
import 'package:analyzer/src/summary2/combinator.dart';
import 'package:analyzer/src/summary2/library_builder.dart';
import 'package:analyzer/src/summary2/reference.dart';
import 'package:analyzer/src/utilities/extensions/collection.dart';

class Export {
  final LibraryBuilder exporter;
  final ExportLocation location;
  final List<Combinator> combinators;

  Export({
    required this.exporter,
    required this.location,
    required this.combinators,
  });

  bool addToExportScope(String name, ExportedReference exported) {
    if (combinators.allows(name)) {
      return exporter.exportScope.export(location, name, exported);
    }
    return false;
  }
}

class ExportedReference {
  final Reference reference;

  ExportedReference({
    required this.reference,
  });

  /// We are done updating this object, returns the immutable version.
  ExportedReference toFinalized() => this;

  @override
  String toString() {
    return '$reference';
  }
}

/// [ExportedReference] for a public element declared in the library.
class ExportedReferenceDeclared extends ExportedReference {
  ExportedReferenceDeclared({
    required super.reference,
  });
}

/// [ExportedReference] for an element that is re-exported.
class ExportedReferenceExported extends ExportedReference {
  /// The locations of `export` (at least one) that export the element.
  final List<ExportLocation> locations;

  ExportedReferenceExported({
    required super.reference,
    required this.locations,
  });

  void addLocation(ExportLocation location) {
    // This list is very small, contains on it is probably ok.
    if (!locations.contains(location)) {
      locations.add(location);
    }
  }

  @override
  ExportedReference toFinalized() {
    return ExportedReferenceExported(
      reference: reference,
      locations: locations.toFixedList(),
    );
  }
}

class ExportLocation {
  /// The index of the fragment with the `export` directive, `0` means the
  /// library file, a positive value means an included fragment.
  final int fragmentIndex;

  /// The index in [CompilationUnitElementImpl.libraryExports].
  final int exportIndex;

  ExportLocation({
    required this.fragmentIndex,
    required this.exportIndex,
  });

  @override
  bool operator ==(Object other) {
    return other is ExportLocation &&
        other.fragmentIndex == fragmentIndex &&
        other.exportIndex == exportIndex;
  }

  LibraryExportElementImpl exportOf(LibraryElementImpl library) {
    var fragment = library.units[fragmentIndex];
    return fragment.libraryExports[exportIndex];
  }

  @override
  String toString() {
    return '($fragmentIndex, $exportIndex)';
  }
}

class ExportScope {
  final Map<String, ExportedReference> map = {};

  void declare(String name, Reference reference) {
    map[name] = ExportedReferenceDeclared(
      reference: reference,
    );
  }

  bool export(
    ExportLocation location,
    String name,
    ExportedReference exported,
  ) {
    var existing = map[name];
    if (existing?.reference == exported.reference) {
      if (existing is ExportedReferenceExported) {
        existing.addLocation(location);
      }
      return false;
    }

    // Ambiguous declaration detected.
    if (existing != null) return false;

    map[name] = ExportedReferenceExported(
      reference: exported.reference,
      locations: [location],
    );
    return true;
  }

  void forEach(void Function(String name, ExportedReference reference) f) {
    map.forEach(f);
  }

  List<ExportedReference> toReferences() {
    return map.values.map((reference) {
      return reference.toFinalized();
    }).toFixedList();
  }
}
