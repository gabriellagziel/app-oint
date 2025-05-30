// Copyright (c) 2014, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Defines the element model. The element model describes the semantic (as
/// opposed to syntactic) structure of Dart code. The syntactic structure of the
/// code is modeled by the [AST
/// structure](../dart_ast_ast/dart_ast_ast-library.html).
///
/// The element model consists of two closely related kinds of objects: elements
/// (instances of a subclass of `Element`) and types. This library defines the
/// elements, the types are defined in
/// [type.dart](../dart_element_type/dart_element_type-library.html).
///
/// Generally speaking, an element represents something that is declared in the
/// code, such as a class, method, or variable. Elements are organized in a tree
/// structure in which the children of an element are the elements that are
/// logically (and often syntactically) part of the declaration of the parent.
/// For example, the elements representing the methods and fields in a class are
/// children of the element representing the class.
///
/// Every complete element structure is rooted by an instance of the class
/// `LibraryElement`. A library element represents a single Dart library. Every
/// library is defined by one or more compilation units (the library and all of
/// its parts). The compilation units are represented by the class
/// `CompilationUnitElement` and are children of the library that is defined by
/// them. Each compilation unit can contain zero or more top-level declarations,
/// such as classes, functions, and variables. Each of these is in turn
/// represented as an element that is a child of the compilation unit. Classes
/// contain methods and fields, methods can contain local variables, etc.
///
/// The element model does not contain everything in the code, only those things
/// that are declared by the code. For example, it does not include any
/// representation of the statements in a method body, but if one of those
/// statements declares a local variable then the local variable will be
/// represented by an element.
library;

import 'package:_fe_analyzer_shared/src/base/analyzer_public_api.dart';
import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/analysis/session.dart';
import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element2.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/scope.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/dart/element/type_provider.dart';
import 'package:analyzer/dart/element/type_system.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/source/line_info.dart';
import 'package:analyzer/source/source.dart';
import 'package:analyzer/src/dart/constant/evaluation.dart';
import 'package:analyzer/src/dart/element/element.dart'
    show elementModelDeprecationMsg;
import 'package:analyzer/src/dart/resolver/scope.dart' show Namespace;
import 'package:analyzer/src/generated/engine.dart' show AnalysisContext;
import 'package:analyzer/src/generated/utilities_dart.dart';
// ignore: deprecated_member_use_from_same_package
import 'package:analyzer/src/task/api/model.dart' show AnalysisTarget;
import 'package:meta/meta.dart';
import 'package:pub_semver/pub_semver.dart';

/// The result of applying augmentations to a [ClassElement].
///
/// Clients may not extend, implement or mix-in this class.
@Deprecated(elementModelDeprecationMsg)
abstract class AugmentedClassElement implements AugmentedInterfaceElement {
  @override
  ClassElement get firstFragment;
}

/// The result of applying augmentations to an [EnumElement].
///
/// Clients may not extend, implement or mix-in this class.
@Deprecated(elementModelDeprecationMsg)
abstract class AugmentedEnumElement implements AugmentedInterfaceElement {
  /// The enum constants declared in this element.
  List<FieldElement> get constants;

  @override
  EnumElement get firstFragment;
}

/// The result of applying augmentations to an [ExtensionElement].
///
/// Clients may not extend, implement or mix-in this class.
@Deprecated(elementModelDeprecationMsg)
abstract class AugmentedExtensionElement implements AugmentedInstanceElement {
  /// The type that is extended by this extension.
  DartType get extendedType;
}

/// The result of applying augmentations to an [ExtensionTypeElement].
///
/// Clients may not extend, implement or mix-in this class.
@Deprecated(elementModelDeprecationMsg)
abstract class AugmentedExtensionTypeElement
    implements AugmentedInterfaceElement {
  @override
  ExtensionTypeElement get firstFragment;

  /// The primary constructor of this extension.
  ConstructorElement get primaryConstructor;

  /// The representation of this extension.
  FieldElement get representation;

  /// The extension type erasure, obtained by recursively replacing every
  /// subterm which is an extension type by the corresponding representation
  /// type.
  DartType get typeErasure;
}

/// The result of applying augmentations to a [InstanceElement].
///
/// Clients may not extend, implement or mix-in this class.
@Deprecated(elementModelDeprecationMsg)
abstract class AugmentedInstanceElement {
  /// The accessors (getters and setters) declared in this element.
  ///
  /// [PropertyAccessorElement]s replace corresponding elements,
  /// other [PropertyAccessorElement]s are appended.
  List<PropertyAccessorElement> get accessors;

  /// The fields declared in this element.
  ///
  /// `FieldAugmentationElement`s replace corresponding elements, other
  /// [FieldElement]s are appended.
  List<FieldElement> get fields;

  /// The declaration (not augmentation) that owns this result.
  InstanceElement get firstFragment;

  /// The metadata associated with this element.
  ///
  /// This is a union of annotations associated with the class declaration and
  /// all its augmentations.
  List<ElementAnnotation> get metadata;

  /// The methods declared in this element.
  ///
  /// `MethodAugmentationElement`s replace corresponding elements, other
  /// [MethodElement]s are appended.
  List<MethodElement> get methods;

  /// The type of `this` expression.
  DartType get thisType;

  /// Returns the field from [fields] that has the given [name].
  FieldElement? getField(String name);

  /// Returns the getter from [accessors] that has the given [name].
  PropertyAccessorElement? getGetter(String name);

  /// Returns the method from [methods] that has the given [name].
  MethodElement? getMethod(String name);

  /// Returns the setter from [accessors] that has the given [name].
  PropertyAccessorElement? getSetter(String name);

  /// Returns the element representing the getter that results from looking up
  /// the given [name] in this class with respect to the given [library],
  /// or `null` if the look up fails.
  ///
  /// The behavior of this method is defined by the Dart Language Specification
  /// in section 17.18 Lookup.
  PropertyAccessorElement? lookUpGetter({
    required String name,
    required LibraryElement library,
  });

  /// Returns the element representing the method that results from looking up
  /// the given [name] in this class with respect to the given [library],
  /// or `null` if the look up fails.
  ///
  /// The behavior of this method is defined by the Dart Language Specification
  /// in section 17.18 Lookup.
  MethodElement? lookUpMethod({
    required String name,
    required LibraryElement library,
  });

  /// Returns the element representing the setter that results from looking up
  /// the given [name] in this class with respect to the given [library],
  /// or `null` if the look up fails.
  ///
  /// The behavior of this method is defined by the Dart Language Specification
  /// in section 17.18 Lookup.
  PropertyAccessorElement? lookUpSetter({
    required String name,
    required LibraryElement library,
  });
}

/// The result of applying augmentations to a [InterfaceElement].
///
/// Clients may not extend, implement or mix-in this class.
@Deprecated(elementModelDeprecationMsg)
abstract class AugmentedInterfaceElement implements AugmentedInstanceElement {
  /// The constructors declared in this element.
  ///
  /// `ConstructorAugmentationElement`s replace corresponding elements,
  /// other [ConstructorElement]s are appended.
  List<ConstructorElement> get constructors;

  @override
  InterfaceElement get firstFragment;

  /// The interfaces implemented by this element.
  ///
  /// This is a union of interfaces declared by the class declaration and
  /// all its augmentations.
  List<InterfaceType> get interfaces;

  /// The mixins applied by this class or in its augmentations.
  ///
  /// This is a union of mixins applied by the class declaration and all its
  /// augmentations.
  List<InterfaceType> get mixins;

  @override
  InterfaceType get thisType;

  /// The unnamed constructor from [constructors].
  ConstructorElement? get unnamedConstructor;

  /// Returns the constructor from [constructors] that has the given [name].
  ConstructorElement? getNamedConstructor(String name);
}

/// The result of applying augmentations to a [MixinElement].
///
/// Clients may not extend, implement or mix-in this class.
@Deprecated(elementModelDeprecationMsg)
abstract class AugmentedMixinElement extends AugmentedInterfaceElement {
  /// The superclass constraints of this element.
  ///
  /// This is a union of constraints declared by the class declaration and
  /// all its augmentations.
  List<InterfaceType> get superclassConstraints;
}

/// A pattern variable that is explicitly declared.
///
/// Clients may not extend, implement or mix-in this class.
@Deprecated(
    'Use BindPatternVariableFragment and BindPatternVariableElement2 instead')
abstract class BindPatternVariableElement implements PatternVariableElement {}

/// An element that represents a class or a mixin. The class can be defined by
/// either a class declaration (with a class body), a mixin application (without
/// a class body), a mixin declaration, or an enum declaration.
///
/// Clients may not extend, implement or mix-in this class.
@Deprecated('Use ClassElement2 instead')
abstract class ClassElement implements InterfaceElement {
  @Deprecated(elementModelDeprecationMsg)
  @override
  AugmentedClassElement get augmented;

  /// Whether the class or its superclass declares a non-final instance field.
  bool get hasNonFinalField;

  /// Whether the class is abstract. A class is abstract if it has an
  /// explicit `abstract` modifier. Note, that this definition of
  /// <i>abstract</i> is different from <i>has unimplemented members</i>.
  bool get isAbstract;

  /// Whether this class is a base class.
  ///
  /// A class is a base class if it has an explicit `base` modifier, or the
  /// class has a `base` induced modifier and [isSealed] is `true` as well.
  /// The base modifier allows the class to be extended but not implemented.
  bool get isBase;

  /// Whether the class can be instantiated.
  bool get isConstructable;

  /// Whether the class represents the class 'Enum' defined in `dart:core`.
  bool get isDartCoreEnum;

  /// Whether the class represents the class 'Object' defined in `dart:core`.
  bool get isDartCoreObject;

  /// Whether the class has the property where, in a switch, if you cover all
  /// of the subtypes of this element, then the compiler knows that you have
  /// covered all possible instances of the type.
  bool get isExhaustive;

  /// Whether the class is a final class.
  ///
  /// A class is a final class if it has an explicit `final` modifier, or the
  /// class has a `final` induced modifier and [isSealed] is `true` as well.
  /// The final modifier prohibits this class from being extended, implemented,
  /// or mixed in.
  bool get isFinal;

  /// Whether the class is an interface class.
  ///
  /// A class is an interface class if it has an explicit `interface` modifier,
  /// or the class has an `interface` induced modifier and [isSealed] is `true`
  /// as well. The interface modifier allows the class to be implemented, but
  /// not extended or mixed in.
  bool get isInterface;

  /// Whether the class is a mixin application.
  ///
  /// A class is a mixin application if it was declared using the syntax
  /// `class A = B with C;`.
  bool get isMixinApplication;

  /// Whether the class is a mixin class.
  ///
  /// A class is a mixin class if it has an explicit `mixin` modifier.
  bool get isMixinClass;

  /// Whether the class is a sealed class.
  ///
  /// A class is a sealed class if it has an explicit `sealed` modifier.
  bool get isSealed;

  /// Whether the class can validly be used as a mixin when defining
  /// another class.
  ///
  /// For classes defined by a class declaration or a mixin application, the
  /// behavior of this method is defined by the Dart Language Specification
  /// in section 9:
  /// <blockquote>
  /// It is a compile-time error if a declared or derived mixin refers to super.
  /// It is a compile-time error if a declared or derived mixin explicitly
  /// declares a constructor. It is a compile-time error if a mixin is derived
  /// from a class whose superclass is not Object.
  /// </blockquote>
  bool get isValidMixin;

  /// Whether the class, assuming that it is within scope, is extendable to
  /// classes in the given [library].
  bool isExtendableIn(LibraryElement library);

  /// Whether the class, assuming that it is within scope, is
  /// implementable to classes, mixins, and enums in the given [library].
  bool isImplementableIn(LibraryElement library);

  /// Whether the class, assuming that it is within scope, is able to be
  /// mixed-in by classes and enums in the given [library].
  bool isMixableIn(LibraryElement library);
}

/// An element that is contained within a [ClassElement].
///
/// Clients may not extend, implement or mix-in this class.
@Deprecated('''
There is no common interface for class members in the new analyzer element
model. If you are using this class in an `is` test or a pattern match, replace
it with checks for the specific element types you are interested in (e.g.,
`ConstructorElement2`, `MethodElement2`, etc.). If you are using this class as
a type annotation for a variable that could hold any kind of class member, use
`Element2` instead.''')
abstract class ClassMemberElement implements Element {
  // TODO(brianwilkerson): Either remove this class or rename it to something
  //  more correct.

  @override
  Element get enclosingElement3;

  /// Whether the element is a static element.
  ///
  /// A static element is an element that is not associated with a particular
  /// instance, but rather with an entire library or class.
  bool get isStatic;
}

/// An element representing a compilation unit.
///
/// Clients may not extend, implement or mix-in this class.
@Deprecated(elementModelDeprecationMsg)
abstract class CompilationUnitElement implements UriReferencedElement {
  /// The extension elements accessible within this unit.
  List<ExtensionElement> get accessibleExtensions;

  /// The top-level accessors (getters and setters) declared in this
  /// compilation unit.
  List<PropertyAccessorElement> get accessors;

  /// The classes declared in this compilation unit.
  List<ClassElement> get classes;

  /// The [CompilationUnitElement] that uses `part` directive to include this
  /// element, or `null` if this element is the defining unit of the library.
  @override
  CompilationUnitElement? get enclosingElement3;

  /// The enums declared in this compilation unit.
  List<EnumElement> get enums;

  /// The extensions declared in this compilation unit.
  List<ExtensionElement> get extensions;

  /// The extension types declared in this compilation unit.
  @experimental
  List<ExtensionTypeElement> get extensionTypes;

  /// The top-level functions declared in this compilation unit.
  List<FunctionElement> get functions;

  /// The libraries exported by this unit.
  List<LibraryExportElement> get libraryExports;

  /// The prefixes used by [libraryImports].
  ///
  /// Each prefix can be used in more than one `import` directive.
  List<PrefixElement> get libraryImportPrefixes;

  /// The libraries imported by this unit.
  List<LibraryImportElement> get libraryImports;

  /// The [LineInfo] for the [source].
  LineInfo get lineInfo;

  /// The mixins declared in this compilation unit.
  List<MixinElement> get mixins;

  /// The parts included by this unit.
  List<PartElement> get parts;

  /// The scope used to resolve names within this compilation unit.
  ///
  /// It includes all of the elements that are declared in the library, and all
  /// of the elements imported into this unit or parent units.
  Scope get scope;

  @override
  AnalysisSession get session;

  /// The top-level variables declared in this compilation unit.
  List<TopLevelVariableElement> get topLevelVariables;

  /// The type aliases declared in this compilation unit.
  List<TypeAliasElement> get typeAliases;

  /// Returns the class defined in this compilation unit that has the given
  /// [name], or `null` if this compilation unit does not define a class with
  /// the given name.
  ClassElement? getClass(String name);

  /// Returns the enum defined in this compilation unit that has the given
  /// [name], or `null` if this compilation unit does not define an enum with
  /// the given name.
  EnumElement? getEnum(String name);
}

/// An element representing a constructor or a factory method defined within a
/// class.
///
/// Clients may not extend, implement or mix-in this class.
@Deprecated('Use ConstructorElement2 instead')
abstract class ConstructorElement
    implements ClassMemberElement, ExecutableElement, ConstantEvaluationTarget {
  @override
  ConstructorElement get declaration;

  @override
  String get displayName;

  @override
  InterfaceElement get enclosingElement3;

  /// Whether the constructor is a const constructor.
  bool get isConst;

  /// Whether the constructor can be used as a default constructor - unnamed,
  /// and has no required parameters.
  bool get isDefaultConstructor;

  /// Whether the constructor represents a factory constructor.
  bool get isFactory;

  /// Whether the constructor represents a generative constructor.
  bool get isGenerative;

  @override
  String get name;

  /// The offset of the character immediately following the last character of
  /// this constructor's name, or `null` if not named.
  ///
  // TODO(migration): encapsulate [nameEnd] and [periodOffset]?
  int? get nameEnd;

  /// The offset of the `.` before this constructor name, or `null` if not
  /// named.
  int? get periodOffset;

  /// The constructor to which this constructor is redirecting, or `null` if
  /// this constructor does not redirect to another constructor or if the
  /// library containing this constructor has not yet been resolved.
  ConstructorElement? get redirectedConstructor;

  @override
  InterfaceType get returnType;

  /// The constructor of the superclass that this constructor invokes, or
  /// `null` if this constructor redirects to another constructor, or if the
  /// library containing this constructor has not yet been resolved.
  ConstructorElement? get superConstructor;
}

/// [ImportElementPrefix] that is used together with `deferred`.
///
/// Clients may not extend, implement or mix-in this class.
@Deprecated('Use PrefixElement2 instead')
abstract class DeferredImportElementPrefix implements ImportElementPrefix {}

/// Meaning of a URI referenced in a directive.
///
/// Clients may not extend, implement or mix-in this class.
abstract class DirectiveUri {}

/// [DirectiveUriWithSource] that references a [LibraryElement2].
///
/// Clients may not extend, implement or mix-in this class.
abstract class DirectiveUriWithLibrary extends DirectiveUriWithSource {
  /// The library referenced by the [source].
  @Deprecated(elementModelDeprecationMsg)
  LibraryElement get library;

  /// The library referenced by the [source].
  LibraryElement2 get library2;
}

/// [DirectiveUriWithRelativeUriString] that can be parsed into a relative URI.
///
/// Clients may not extend, implement or mix-in this class.
abstract class DirectiveUriWithRelativeUri
    extends DirectiveUriWithRelativeUriString {
  /// The relative URI, parsed from [relativeUriString].
  Uri get relativeUri;
}

/// [DirectiveUri] for which we can get its relative URI string.
///
/// Clients may not extend, implement or mix-in this class.
abstract class DirectiveUriWithRelativeUriString extends DirectiveUri {
  /// The relative URI string specified in code.
  String get relativeUriString;
}

/// [DirectiveUriWithRelativeUri] that resolves to a [Source].
///
/// Clients may not extend, implement or mix-in this class.
abstract class DirectiveUriWithSource extends DirectiveUriWithRelativeUri {
  /// The result of resolving [relativeUri] against the enclosing URI.
  Source get source;
}

/// [DirectiveUriWithSource] that references a [LibraryFragment].
///
/// Clients may not extend, implement or mix-in this class.
abstract class DirectiveUriWithUnit extends DirectiveUriWithSource {
  /// The library fragment referenced by the [source].
  @experimental
  LibraryFragment get libraryFragment;

  /// The unit referenced by the [source].
  @Deprecated('Use libraryFragment instead')
  CompilationUnitElement get unit;
}

/// The base class for all of the elements in the element model. Generally
/// speaking, the element model is a semantic model of the program that
/// represents things that are declared with a name and hence can be referenced
/// elsewhere in the code.
///
/// There are two exceptions to the general case. First, there are elements in
/// the element model that are created for the convenience of various kinds of
/// analysis but that do not have any corresponding declaration within the
/// source code. Such elements are marked as being <i>synthetic</i>. Examples of
/// synthetic elements include
/// * default constructors in classes that do not define any explicit
///   constructors,
/// * getters and setters that are induced by explicit field declarations,
/// * fields that are induced by explicit declarations of getters and setters,
///   and
/// * functions representing the initialization expression for a variable.
///
/// Second, there are elements in the element model that do not have a name.
/// These correspond to unnamed functions and exist in order to more accurately
/// represent the semantic structure of the program.
///
/// Clients may not extend, implement or mix-in this class.
@Deprecated(elementModelDeprecationMsg)
abstract class Element implements AnalysisTarget {
  /// A list of this element's children.
  ///
  /// There is no guarantee of the order in which the children will be included.
  @Deprecated(elementModelDeprecationMsg)
  List<Element> get children;

  /// The analysis context in which this element is defined.
  AnalysisContext get context;

  /// The declaration of this element.
  ///
  /// If the element is a view on an element, e.g. a method from an interface
  /// type, with substituted type parameters, return the corresponding element
  /// from the class, without any substitutions. If this element is already a
  /// declaration (or a synthetic element, e.g. a synthetic property accessor),
  /// return itself.
  @Deprecated(elementModelDeprecationMsg)
  Element? get declaration;

  /// The display name of this element, possibly the empty string if the
  /// element does not have a name.
  ///
  /// In most cases the name and the display name are the same. Differences
  /// though are cases such as setters where the name of some setter `set f(x)`
  /// is `f=`, instead of `f`.
  String get displayName;

  /// The content of the documentation comment (including delimiters) for this
  /// element, or `null` if this element does not or cannot have documentation.
  String? get documentationComment;

  /// The element that either physically or logically encloses this element.
  ///
  /// For [LibraryElement] returns `null`, because libraries are the top-level
  /// elements in the model.
  ///
  /// For [CompilationUnitElement] returns the [CompilationUnitElement] that
  /// uses `part` directive to include this element, or `null` if this element
  /// is the defining unit of the library.
  @Deprecated('Use Element2.enclosingElement2 instead or '
      'Fragment.enclosingFragment instead')
  Element? get enclosingElement3;

  /// Whether the element has an annotation of the form `@alwaysThrows`.
  bool get hasAlwaysThrows;

  /// Whether the element has an annotation of the form `@deprecated`
  /// or `@Deprecated('..')`.
  bool get hasDeprecated;

  /// Whether the element has an annotation of the form `@doNotStore`.
  bool get hasDoNotStore;

  /// Whether the element has an annotation of the form `@doNotSubmit`.
  bool get hasDoNotSubmit;

  /// Whether the element has an annotation of the form `@factory`.
  bool get hasFactory;

  /// Whether the element has an annotation of the form `@immutable`.
  bool get hasImmutable;

  /// Whether the element has an annotation of the form `@internal`.
  bool get hasInternal;

  /// Whether the element has an annotation of the form `@isTest`.
  bool get hasIsTest;

  /// Whether the element has an annotation of the form `@isTestGroup`.
  bool get hasIsTestGroup;

  /// Whether the element has an annotation of the form `@JS(..)`.
  bool get hasJS;

  /// Whether the element has an annotation of the form `@literal`.
  bool get hasLiteral;

  /// Whether the element has an annotation of the form `@mustBeConst`.
  bool get hasMustBeConst;

  /// Whether the element has an annotation of the form `@mustBeOverridden`.
  bool get hasMustBeOverridden;

  /// Whether the element has an annotation of the form `@mustCallSuper`.
  bool get hasMustCallSuper;

  /// Whether the element has an annotation of the form `@nonVirtual`.
  bool get hasNonVirtual;

  /// Whether the element has an annotation of the form `@optionalTypeArgs`.
  bool get hasOptionalTypeArgs;

  /// Whether the element has an annotation of the form `@override`.
  bool get hasOverride;

  /// Whether the element has an annotation of the form `@protected`.
  bool get hasProtected;

  /// Whether the element has an annotation of the form `@redeclare`.
  bool get hasRedeclare;

  /// Whether the element has an annotation of the form `@reopen`.
  bool get hasReopen;

  /// Whether the element has an annotation of the form `@required`.
  bool get hasRequired;

  /// Whether the element has an annotation of the form `@sealed`.
  bool get hasSealed;

  /// Whether the element has an annotation of the form `@useResult`
  /// or `@UseResult('..')`.
  bool get hasUseResult;

  /// Whether the element has an annotation of the form `@visibleForOverriding`.
  bool get hasVisibleForOverriding;

  /// Whether the element has an annotation of the form `@visibleForTemplate`.
  bool get hasVisibleForTemplate;

  /// Whether the element has an annotation of the form `@visibleForTesting`.
  bool get hasVisibleForTesting;

  /// Whether the element has an annotation of the form
  /// `@visibleOutsideTemplate`.
  bool get hasVisibleOutsideTemplate;

  /// The unique integer identifier of this element.
  int get id;

  /// Whether the element is private.
  ///
  /// Private elements are visible only within the library in which they are
  /// declared.
  bool get isPrivate;

  /// Whether the element is public.
  ///
  /// Public elements are visible within any library that imports the library
  /// in which they are declared.
  bool get isPublic;

  /// Whether the element is synthetic.
  ///
  /// A synthetic element is an element that is not represented in the source
  /// code explicitly, but is implied by the source code, such as the default
  /// constructor for a class that does not explicitly define any constructors.
  bool get isSynthetic;

  /// The kind of element that this is.
  ElementKind get kind;

  /// Library that contains this element.
  ///
  /// This will be the element itself if it is a library element. This will be
  /// `null` if this element is [MultiplyDefinedElement2] that is not contained
  /// in a library.
  @Deprecated(elementModelDeprecationMsg)
  LibraryElement? get library;

  /// The location of this element in the element model.
  ///
  /// The object can be used to locate this element at a later time.
  ElementLocation? get location;

  /// All of the metadata associated with this element.
  ///
  /// The array will be empty if the element does not have any metadata or if
  /// the library containing this element has not yet been resolved.
  List<ElementAnnotation> get metadata;

  /// The name of this element, or `null` if this element does not have a name.
  String? get name;

  /// The length of the name of this element in the file that contains the
  /// declaration of this element, or `0` if this element does not have a name.
  int get nameLength;

  /// The offset of the name of this element in the file that contains the
  /// declaration of this element, or `-1` if this element is synthetic, does
  /// not have a name, or otherwise does not have an offset.
  int get nameOffset;

  /// The non-synthetic element that caused this element to be created.
  ///
  /// If this element is not synthetic, then the element itself is returned.
  ///
  /// If this element is synthetic, then the corresponding non-synthetic
  /// element is returned. For example, for a synthetic getter of a
  /// non-synthetic field the field is returned; for a synthetic constructor
  /// the enclosing class is returned.
  @Deprecated(elementModelDeprecationMsg)
  Element get nonSynthetic;

  /// The analysis session in which this element is defined.
  AnalysisSession? get session;

  /// The version where this SDK API was added.
  ///
  /// A `@Since()` annotation can be applied to a library declaration,
  /// any public declaration in a library, or in a class, or to an optional
  /// parameter, etc.
  ///
  /// The returned version is "effective", so that if a library is annotated
  /// then all elements of the library inherit it; or if a class is annotated
  /// then all members and constructors of the class inherit it.
  ///
  /// If multiple `@Since()` annotations apply to the same element, the latest
  /// version takes precedence.
  ///
  /// Returns `null` if the element is not declared in SDK, or does not have
  /// a `@Since()` annotation applicable to it.
  Version? get sinceSdkVersion;

  @override
  Source? get source;

  /// Uses the given [visitor] to visit this element.
  ///
  /// Returns the value returned by the visitor as a result of visiting this
  /// element.
  @Deprecated('Use Element2 and accept2() instead')
  T? accept<T>(ElementVisitor<T> visitor);

  /// Returns the presentation of this element as it should appear when
  /// presented to users.
  ///
  /// If [withNullability] is `true`, then [NullabilitySuffix.question] and
  /// [NullabilitySuffix.star] in types will be represented as `?` and `*`.
  /// [NullabilitySuffix.none] does not have any explicit presentation.
  ///
  /// If [withNullability] is `false`, nullability suffixes will not be
  /// included into the presentation.
  ///
  /// If [multiline] is `true`, the string may be wrapped over multiple lines
  /// with newlines to improve formatting. For example function signatures may
  /// be formatted as if they had trailing commas.
  ///
  /// Clients should not depend on the content of the returned value as it will
  /// be changed if doing so would improve the UX.
  String getDisplayString({
    @Deprecated('Only non-nullable by default mode is supported')
    bool withNullability = true,
    bool multiline = false,
  });

  /// Returns a display name for the given element that includes the path to the
  /// compilation unit in which the type is defined. If [shortName] is `null`
  /// then [displayName] will be used as the name of this element. Otherwise
  /// the provided name will be used.
  // TODO(brianwilkerson): Make the parameter optional.
  String getExtendedDisplayName(String? shortName);

  /// Whether the element, assuming that it is within scope, is accessible to
  /// code in the given [library].
  ///
  /// This is defined by the Dart Language Specification in section 6.2:
  /// <blockquote>
  /// A declaration <i>m</i> is accessible to a library <i>L</i> if <i>m</i> is
  /// declared in <i>L</i> or if <i>m</i> is public.
  /// </blockquote>
  @Deprecated(elementModelDeprecationMsg)
  bool isAccessibleIn(LibraryElement library);

  /// Returns either this element or the most immediate ancestor of this element
  /// for which the [predicate] returns `true`, or `null` if there is no such
  /// element.
  @Deprecated('Use Element2.thisOrAncestorMatching2() instead')
  E? thisOrAncestorMatching<E extends Element>(
    bool Function(Element) predicate,
  );

  /// Returns either this element or the most immediate ancestor of this element
  /// for which the [predicate] returns `true`, or `null` if there is no such
  /// element.
  @Deprecated('Use Element2.thisOrAncestorMatching2() instead')
  E? thisOrAncestorMatching3<E extends Element>(
    bool Function(Element) predicate,
  );

  /// Returns either this element or the most immediate ancestor of this element
  /// that has the given type, or `null` if there is no such element.
  @Deprecated('Use Element2.thisOrAncestorMatching2() instead')
  E? thisOrAncestorOfType<E extends Element>();

  /// Returns either this element or the most immediate ancestor of this element
  /// that has the given type, or `null` if there is no such element.
  @Deprecated('Use Element2.thisOrAncestorMatching2() instead')
  E? thisOrAncestorOfType3<E extends Element>();

  /// Uses the given [visitor] to visit all of the children of this element.
  /// There is no guarantee of the order in which the children will be visited.
  @Deprecated('Use Element2 and visitChildren2() instead')
  void visitChildren(ElementVisitor visitor);
}

/// A single annotation associated with an element.
///
/// Clients may not extend, implement or mix-in this class.
abstract class ElementAnnotation implements ConstantEvaluationTarget {
  /// The errors that were produced while computing a value for this
  /// annotation, or `null` if no value has been computed.
  ///
  /// If a value has been produced but no errors were generated, then the
  /// list will be empty.
  List<AnalysisError>? get constantEvaluationErrors;

  /// Returns the element referenced by this annotation.
  ///
  /// In valid code this element can be a [PropertyAccessorElement] getter
  /// of a constant top-level variable, or a constant static field of a
  /// class; or a constant [ConstructorElement].
  ///
  /// In invalid code this element can be `null`, or a reference to any
  /// other element.
  @Deprecated('Use element2 instead')
  Element? get element;

  /// Returns the element referenced by this annotation.
  ///
  /// In valid code this element can be a [GetterElement] of a constant
  /// top-level variable, or a constant static field of a class; or a
  /// constant [ConstructorElement2].
  ///
  /// In invalid code this element can be `null`, or a reference to any
  /// other element.
  Element2? get element2;

  /// Whether the annotation marks the associated function as always throwing.
  bool get isAlwaysThrows;

  /// Whether the annotation marks the associated element as being deprecated.
  bool get isDeprecated;

  /// Whether the annotation marks the associated element as not to be stored.
  bool get isDoNotStore;

  /// Whether the annotation marks the associated member as not to be used.
  bool get isDoNotSubmit;

  /// Whether the annotation marks the associated member as a factory.
  bool get isFactory;

  /// Whether the annotation marks the associated class and its subclasses as
  /// being immutable.
  bool get isImmutable;

  /// Whether the annotation marks the associated element as being internal to
  /// its package.
  bool get isInternal;

  /// Whether the annotation marks the associated member as running a single
  /// test.
  bool get isIsTest;

  /// Whether the annotation marks the associated member as running a test
  /// group.
  bool get isIsTestGroup;

  /// Whether the annotation marks the associated element with the `JS`
  /// annotation.
  bool get isJS;

  /// Whether the annotation marks the associated constructor as being literal.
  bool get isLiteral;

  /// Whether the annotation marks the associated returned element as
  /// requiring a constant argument.
  bool get isMustBeConst;

  /// Whether the annotation marks the associated member as requiring
  /// subclasses to override this member.
  bool get isMustBeOverridden;

  /// Whether the annotation marks the associated member as requiring
  /// overriding methods to call super.
  bool get isMustCallSuper;

  /// Whether the annotation marks the associated member as being non-virtual.
  bool get isNonVirtual;

  /// Whether the annotation marks the associated type as having "optional"
  /// type arguments.
  bool get isOptionalTypeArgs;

  /// Whether the annotation marks the associated method as being expected to
  /// override an inherited method.
  bool get isOverride;

  /// Whether the annotation marks the associated member as being protected.
  bool get isProtected;

  /// Whether the annotation marks the associated class as implementing a proxy
  /// object.
  bool get isProxy;

  /// Whether the annotation marks the associated member as redeclaring.
  bool get isRedeclare;

  /// Whether the annotation marks the associated member as being reopened.
  bool get isReopen;

  /// Whether the annotation marks the associated member as being required.
  bool get isRequired;

  /// Whether the annotation marks the associated class as being sealed.
  bool get isSealed;

  /// Whether the annotation marks the associated class as being intended to
  /// be used as an annotation.
  bool get isTarget;

  /// Whether the annotation marks the associated returned element as
  /// requiring use.
  bool get isUseResult;

  /// Whether the annotation marks the associated member as being visible for
  /// overriding only.
  bool get isVisibleForOverriding;

  /// Whether the annotation marks the associated member as being visible for
  /// template files.
  bool get isVisibleForTemplate;

  /// Whether the annotation marks the associated member as being visible for
  /// testing.
  bool get isVisibleForTesting;

  /// Whether the annotation marks the associated member as being visible
  /// outside of template files.
  bool get isVisibleOutsideTemplate;

  /// Whether the annotation marks the associated member as being a widget
  /// factory.
  bool get isWidgetFactory;

  /// Returns a representation of the value of this annotation, forcing the
  /// value to be computed if it had not previously been computed, or `null`
  /// if the value of this annotation could not be computed because of errors.
  DartObject? computeConstantValue();

  /// Returns a textual description of this annotation in a form approximating
  /// valid source.
  ///
  /// The returned string will not be valid source primarily in the case where
  /// the annotation itself is not well-formed.
  String toSource();
}

/// The kind of elements in the element model.
///
/// Clients may not extend, implement or mix-in this class.
class ElementKind implements Comparable<ElementKind> {
  static const ElementKind AUGMENTATION_IMPORT =
      ElementKind('AUGMENTATION_IMPORT', 0, "augmentation import");

  static const ElementKind CLASS = ElementKind('CLASS', 1, "class");

  static const ElementKind CLASS_AUGMENTATION =
      ElementKind('CLASS_AUGMENTATION', 2, "class augmentation");

  static const ElementKind COMPILATION_UNIT =
      ElementKind('COMPILATION_UNIT', 3, "compilation unit");

  static const ElementKind CONSTRUCTOR =
      ElementKind('CONSTRUCTOR', 4, "constructor");

  static const ElementKind DYNAMIC = ElementKind('DYNAMIC', 5, "<dynamic>");

  static const ElementKind ENUM = ElementKind('ENUM', 6, "enum");

  static const ElementKind ERROR = ElementKind('ERROR', 7, "<error>");

  static const ElementKind EXPORT =
      ElementKind('EXPORT', 8, "export directive");

  static const ElementKind EXTENSION = ElementKind('EXTENSION', 9, "extension");

  static const ElementKind EXTENSION_TYPE =
      ElementKind('EXTENSION_TYPE', 10, "extension type");

  static const ElementKind FIELD = ElementKind('FIELD', 11, "field");

  static const ElementKind FUNCTION = ElementKind('FUNCTION', 12, "function");

  static const ElementKind GENERIC_FUNCTION_TYPE =
      ElementKind('GENERIC_FUNCTION_TYPE', 13, 'generic function type');

  static const ElementKind GETTER = ElementKind('GETTER', 14, "getter");

  static const ElementKind IMPORT =
      ElementKind('IMPORT', 15, "import directive");

  static const ElementKind LABEL = ElementKind('LABEL', 16, "label");

  static const ElementKind LIBRARY = ElementKind('LIBRARY', 17, "library");

  static const ElementKind LIBRARY_AUGMENTATION =
      ElementKind('LIBRARY_AUGMENTATION', 18, "library augmentation");

  static const ElementKind LOCAL_VARIABLE =
      ElementKind('LOCAL_VARIABLE', 19, "local variable");

  static const ElementKind METHOD = ElementKind('METHOD', 20, "method");

  static const ElementKind MIXIN = ElementKind('MIXIN', 21, "mixin");

  static const ElementKind NAME = ElementKind('NAME', 22, "<name>");

  static const ElementKind NEVER = ElementKind('NEVER', 23, "<never>");

  static const ElementKind PARAMETER =
      ElementKind('PARAMETER', 24, "parameter");

  static const ElementKind PART = ElementKind('PART', 25, "part");

  static const ElementKind PREFIX = ElementKind('PREFIX', 26, "import prefix");

  static const ElementKind RECORD = ElementKind('RECORD', 27, "record");

  static const ElementKind SETTER = ElementKind('SETTER', 28, "setter");

  static const ElementKind TOP_LEVEL_VARIABLE =
      ElementKind('TOP_LEVEL_VARIABLE', 29, "top level variable");

  static const ElementKind FUNCTION_TYPE_ALIAS =
      ElementKind('FUNCTION_TYPE_ALIAS', 30, "function type alias");

  static const ElementKind TYPE_PARAMETER =
      ElementKind('TYPE_PARAMETER', 31, "type parameter");

  static const ElementKind TYPE_ALIAS =
      ElementKind('TYPE_ALIAS', 32, "type alias");

  static const ElementKind UNIVERSE = ElementKind('UNIVERSE', 33, "<universe>");

  static const List<ElementKind> values = [
    CLASS,
    CLASS_AUGMENTATION,
    COMPILATION_UNIT,
    CONSTRUCTOR,
    DYNAMIC,
    ENUM,
    ERROR,
    EXPORT,
    EXTENSION,
    EXTENSION_TYPE,
    FIELD,
    FUNCTION,
    GENERIC_FUNCTION_TYPE,
    GETTER,
    IMPORT,
    LABEL,
    LIBRARY,
    LOCAL_VARIABLE,
    METHOD,
    MIXIN,
    NAME,
    NEVER,
    PARAMETER,
    PART,
    PREFIX,
    RECORD,
    SETTER,
    TOP_LEVEL_VARIABLE,
    FUNCTION_TYPE_ALIAS,
    TYPE_PARAMETER,
    UNIVERSE
  ];

  /// The name of this element kind.
  final String name;

  /// The ordinal value of the element kind.
  final int ordinal;

  /// The name displayed in the UI for this kind of element.
  final String displayName;

  /// Initialize a newly created element kind to have the given [displayName].
  const ElementKind(this.name, this.ordinal, this.displayName);

  @override
  int compareTo(ElementKind other) => ordinal - other.ordinal;

  @override
  String toString() => name;
}

/// The location of an element within the element model.
///
/// Clients may not extend, implement or mix-in this class.
abstract class ElementLocation {
  /// The path to the element whose location is represented by this object.
  ///
  /// Clients must not modify the returned array.
  List<String> get components;

  /// The encoded representation of this location that can be used to create a
  /// location that is equal to this location.
  String get encoding;
}

/// An object that can be used to visit an element structure.
///
/// Clients may not extend, implement or mix-in this class. There are classes
/// that implement this interface that provide useful default behaviors in
/// `package:analyzer/dart/element/visitor.dart`. A couple of the most useful
/// include
/// * SimpleElementVisitor which implements every visit method by doing nothing,
/// * RecursiveElementVisitor which will cause every node in a structure to be
///   visited, and
/// * ThrowingElementVisitor which implements every visit method by throwing an
///   exception.
@Deprecated('Use ElementVisitor2 instead')
abstract class ElementVisitor<R> {
  R? visitClassElement(ClassElement element);

  R? visitCompilationUnitElement(CompilationUnitElement element);

  R? visitConstructorElement(ConstructorElement element);

  R? visitEnumElement(EnumElement element);

  R? visitExtensionElement(ExtensionElement element);

  R? visitExtensionTypeElement(ExtensionTypeElement element);

  R? visitFieldElement(FieldElement element);

  R? visitFieldFormalParameterElement(FieldFormalParameterElement element);

  R? visitFunctionElement(FunctionElement element);

  R? visitGenericFunctionTypeElement(GenericFunctionTypeElement element);

  R? visitLabelElement(LabelElement element);

  R? visitLibraryElement(LibraryElement element);

  R? visitLibraryExportElement(LibraryExportElement element);

  R? visitLibraryImportElement(LibraryImportElement element);

  R? visitLocalVariableElement(LocalVariableElement element);

  R? visitMethodElement(MethodElement element);

  R? visitMixinElement(MixinElement element);

  R? visitMultiplyDefinedElement(MultiplyDefinedElement element);

  R? visitParameterElement(ParameterElement element);

  R? visitPartElement(PartElement element);

  R? visitPrefixElement(PrefixElement element);

  R? visitPropertyAccessorElement(PropertyAccessorElement element);

  R? visitSuperFormalParameterElement(SuperFormalParameterElement element);

  R? visitTopLevelVariableElement(TopLevelVariableElement element);

  R? visitTypeAliasElement(TypeAliasElement element);

  R? visitTypeParameterElement(TypeParameterElement element);
}

/// An element that represents an enum.
///
/// Clients may not extend, implement or mix-in this class.
@Deprecated('Use EnumElement2 instead')
abstract class EnumElement implements InterfaceElement {
  @Deprecated(elementModelDeprecationMsg)
  @override
  AugmentedEnumElement get augmented;
}

/// An element representing an executable object, including functions, methods,
/// constructors, getters, and setters.
///
/// Clients may not extend, implement or mix-in this class.
@Deprecated('Use ExecutableElement2 instead')
abstract class ExecutableElement implements FunctionTypedElement {
  @override
  ExecutableElement get declaration;

  @override
  String get displayName;

  @override
  Element get enclosingElement3;

  /// Whether the executable element did not have an explicit return type
  /// specified for it in the original source.
  bool get hasImplicitReturnType;

  /// Whether the executable element is abstract.
  ///
  /// Executable elements are abstract if they are not external, and have no
  /// body.
  bool get isAbstract;

  /// Whether the executable element has body marked as being asynchronous.
  bool get isAsynchronous;

  /// Whether the element is an augmentation.
  ///
  /// If `true`, declaration has the explicit `augment` modifier.
  bool get isAugmentation;

  /// Whether the executable element is an extension type member.
  bool get isExtensionTypeMember;

  /// Whether the executable element is external.
  ///
  /// Executable elements are external if they are explicitly marked as such
  /// using the 'external' keyword.
  bool get isExternal;

  /// Whether the executable element has a body marked as being a generator.
  bool get isGenerator;

  /// Whether the executable element is an operator.
  ///
  /// The test may be based on the name of the executable element, in which
  /// case the result will be correct when the name is legal.
  bool get isOperator;

  /// Whether the element is a static element.
  ///
  /// A static element is an element that is not associated with a particular
  /// instance, but rather with an entire library or class.
  bool get isStatic;

  /// Whether the executable element has a body marked as being synchronous.
  bool get isSynchronous;

  @override
  String get name;
}

/// An element that represents an extension.
///
/// Clients may not extend, implement or mix-in this class.
@Deprecated('Use ExtensionElement2 instead')
abstract class ExtensionElement implements InstanceElement {
  @Deprecated(elementModelDeprecationMsg)
  @override
  AugmentedExtensionElement get augmented;

  /// The type that is extended by this extension.
  DartType get extendedType;

  /// Returns the element representing the field with the given [name] that is
  /// declared in this extension, or `null` if this extension does not declare a
  /// field with the given name.
  FieldElement? getField(String name);

  /// Returns the element representing the getter with the given [name] that is
  /// declared in this extension, or `null` if this extension does not declare a
  /// getter with the given name.
  PropertyAccessorElement? getGetter(String name);

  /// Returns the element representing the method with the given [name] that is
  /// declared in this extension, or `null` if this extension does not declare a
  /// method with the given name.
  MethodElement? getMethod(String name);

  /// Returns the element representing the setter with the given [name] that is
  /// declared in this extension, or `null` if this extension does not declare a
  /// setter with the given name.
  PropertyAccessorElement? getSetter(String name);
}

/// An element that represents an extension type.
///
/// Clients may not extend, implement or mix-in this class.
@Deprecated('Use ExtensionTypeElement2 instead')
abstract class ExtensionTypeElement implements InterfaceElement {
  @Deprecated(elementModelDeprecationMsg)
  @override
  AugmentedExtensionTypeElement get augmented;

  /// The primary constructor of this extension.
  @Deprecated(elementModelDeprecationMsg)
  ConstructorElement get primaryConstructor;

  /// The representation of this extension.
  FieldElement get representation;

  /// The extension type erasure, obtained by recursively replacing every
  /// subterm which is an extension type by the corresponding representation
  /// type.
  DartType get typeErasure;
}

/// A field defined within a class.
///
/// Clients may not extend, implement or mix-in this class.
@Deprecated('Use FieldElement2 instead')
abstract class FieldElement
    implements ClassMemberElement, PropertyInducingElement {
  @override
  FieldElement get declaration;

  /// Whether the field is abstract.
  ///
  /// Executable fields are abstract if they are declared with the `abstract`
  /// keyword.
  bool get isAbstract;

  /// Whether the field was explicitly marked as being covariant.
  bool get isCovariant;

  /// Whether the element is an enum constant.
  bool get isEnumConstant;

  /// Whether the field was explicitly marked as being external.
  bool get isExternal;

  /// Whether the field can be type promoted.
  bool get isPromotable;

  /// Whether the element is a static element.
  ///
  /// A static element is an element that is not associated with a particular
  /// instance, but rather with an entire library or class.
  @override
  bool get isStatic;
}

/// A field formal parameter defined within a constructor element.
///
/// Clients may not extend, implement or mix-in this class.
@Deprecated('Use FieldFormalParameterElement2 instead')
abstract class FieldFormalParameterElement implements ParameterElement {
  /// The field element associated with this field formal parameter, or `null`
  /// if the parameter references a field that doesn't exist.
  @Deprecated(elementModelDeprecationMsg)
  FieldElement? get field;
}

/// A (non-method) function. This can be either a top-level function, a local
/// function, a closure, or the initialization expression for a field or
/// variable.
///
/// Clients may not extend, implement or mix-in this class.
@Deprecated('Use TopLevelFunctionElement or LocalFunctionElement')
abstract class FunctionElement implements ExecutableElement, LocalElement {
  /// The name of the method that can be implemented by a class to allow its
  /// instances to be invoked as if they were a function.
  static final String CALL_METHOD_NAME = "call";

  /// The name of the synthetic function defined for libraries that are
  /// deferred.
  static final String LOAD_LIBRARY_NAME = "loadLibrary";

  /// The name of the function used as an entry point.
  static const String MAIN_FUNCTION_NAME = "main";

  /// The name of the method that will be invoked if an attempt is made to
  /// invoke an undefined method on an object.
  static final String NO_SUCH_METHOD_METHOD_NAME = "noSuchMethod";

  /// Whether the function represents `identical` from the `dart:core` library.
  bool get isDartCoreIdentical;

  /// Whether the function is an entry point, i.e. a top-level function and
  /// has the name `main`.
  bool get isEntryPoint;
}

/// An element that has a [FunctionType] as its [type].
///
/// This also provides convenient access to the parameters and return type.
///
/// Clients may not extend, implement or mix-in this class.
@Deprecated('Use FunctionTypedElement2 instead')
abstract class FunctionTypedElement implements TypeParameterizedElement {
  /// The parameters defined by this executable element.
  List<ParameterElement> get parameters;

  /// The return type defined by this element.
  DartType get returnType;

  /// The type defined by this element.
  FunctionType get type;
}

/// The pseudo-declaration that defines a generic function type.
///
/// Clients may not extend, implement, or mix-in this class.
@Deprecated('Use GenericFunctionTypeElement2 instead')
abstract class GenericFunctionTypeElement implements FunctionTypedElement {}

/// A combinator that causes some of the names in a namespace to be hidden when
/// being imported.
///
/// Clients may not extend, implement or mix-in this class.
abstract class HideElementCombinator implements NamespaceCombinator {
  /// The names that are not to be made visible in the importing library even
  /// if they are defined in the imported library.
  List<String> get hiddenNames;
}

/// Usage of a [PrefixElement] in an `import` directive.
///
/// Clients may not extend, implement or mix-in this class.
@Deprecated('Use PrefixElement2 instead')
abstract class ImportElementPrefix {
  /// The prefix that was specified as part of the import directive, or `null`
  /// if there was no prefix specified.
  PrefixElement get element;
}

/// An element that has `this`.
///
/// Clients may not extend, implement or mix-in this class.
@Deprecated('Use InstanceElement2 instead')
abstract class InstanceElement
    implements TypeDefiningElement, TypeParameterizedElement {
  /// The declared accessors (getters and setters).
  List<PropertyAccessorElement> get accessors;

  /// The result of merging augmentations.
  ///
  /// It includes the members of the base element and its augmentations as
  /// specified by the merge operations.
  @Deprecated(elementModelDeprecationMsg)
  AugmentedInstanceElement get augmented;

  @Deprecated(elementModelDeprecationMsg)
  @override
  CompilationUnitElement get enclosingElement3;

  /// The declared fields.
  List<FieldElement> get fields;

  /// Whether the element is an augmentation.
  ///
  /// If `true`, declaration has the explicit `augment` modifier.
  bool get isAugmentation;

  /// The declared methods.
  List<MethodElement> get methods;

  /// The type of `this` expression.
  ///
  /// Same as `augmented.thisType`.
  DartType get thisType;
}

/// An element that defines an [InterfaceType].
///
/// Clients may not extend, implement or mix-in this class.
@Deprecated('Use InterfaceElement2 instead')
abstract class InterfaceElement implements InstanceElement {
  /// All the supertypes defined for this element and its supertypes.
  ///
  /// This includes superclasses, mixins, interfaces, and superclass constraints.
  List<InterfaceType> get allSupertypes;

  @Deprecated(elementModelDeprecationMsg)
  @override
  AugmentedInterfaceElement get augmented;

  /// The declared constructors.
  ///
  /// The list is empty for [MixinElement].
  @Deprecated(elementModelDeprecationMsg)
  List<ConstructorElement> get constructors;

  /// The interfaces that are implemented by this class.
  ///
  /// <b>Note:</b> Because the element model represents the state of the code,
  /// it is possible for it to be semantically invalid. In particular, it is not
  /// safe to assume that the inheritance structure of a class does not contain
  /// a cycle. Clients that traverse the inheritance structure must explicitly
  /// guard against infinite loops.
  List<InterfaceType> get interfaces;

  /// The mixins that are applied to the class being extended in order to
  /// derive the superclass of this class.
  ///
  /// [ClassElement] and [EnumElement] can have mixins.
  ///
  /// [MixinElement] cannot have mixins, so the empty list is returned.
  ///
  /// <b>Note:</b> Because the element model represents the state of the code,
  /// it is possible for it to be semantically invalid. In particular, it is not
  /// safe to assume that the inheritance structure of a class does not contain
  /// a cycle. Clients that traverse the inheritance structure must explicitly
  /// guard against infinite loops.
  @Deprecated(elementModelDeprecationMsg)
  List<InterfaceType> get mixins;

  @override
  String get name;

  /// The superclass of this element.
  ///
  /// For [ClassElement] returns `null` only if this class is `Object`. If the
  /// superclass is not explicitly specified, or the superclass cannot be
  /// resolved, then the implicit superclass `Object` is returned.
  ///
  /// For [EnumElement] returns `Enum` from `dart:core`.
  ///
  /// For [MixinElement] always returns `null`.
  ///
  /// <b>Note:</b> Because the element model represents the state of the code,
  /// it is possible for it to be semantically invalid. In particular, it is not
  /// safe to assume that the inheritance structure of a class does not contain
  /// a cycle. Clients that traverse the inheritance structure must explicitly
  /// guard against infinite loops.
  @Deprecated(elementModelDeprecationMsg)
  InterfaceType? get supertype;

  @override
  InterfaceType get thisType;

  /// The unnamed constructor declared directly in this class.
  ///
  /// If the class does not declare any constructors, a synthetic default
  /// constructor will be returned.
  // TODO(scheglov): Deprecate and remove it.
  @Deprecated(elementModelDeprecationMsg)
  ConstructorElement? get unnamedConstructor;

  /// The field (synthetic or explicit) defined directly in this class or
  /// augmentation that has the given [name].
  // TODO(scheglov): Deprecate and remove it.
  FieldElement? getField(String name);

  /// The getter (synthetic or explicit) defined directly in this class or
  /// augmentation that has the given [name].
  // TODO(scheglov): Deprecate and remove it.
  PropertyAccessorElement? getGetter(String name);

  /// The method defined directly in this class or augmentation that has the
  /// given [name].
  // TODO(scheglov): Deprecate and remove it.
  MethodElement? getMethod(String name);

  /// The constructor defined directly in this class or augmentation
  /// that has the given [name].
  // TODO(scheglov): Deprecate and remove it.
  @Deprecated(elementModelDeprecationMsg)
  ConstructorElement? getNamedConstructor(String name);

  /// The setter (synthetic or explicit) defined directly in this class or
  /// augmentation that has the given [name].
  // TODO(scheglov): Deprecate and remove it.
  PropertyAccessorElement? getSetter(String name);

  /// Create the [InterfaceType] for this element with the given
  /// [typeArguments] and [nullabilitySuffix].
  InterfaceType instantiate({
    required List<DartType> typeArguments,
    required NullabilitySuffix nullabilitySuffix,
  });

  /// Returns the element representing the method that results from looking up
  /// the given [methodName] in this class with respect to the given [library],
  /// ignoring abstract methods, or `null` if the look up fails.
  ///
  /// The behavior of this method is defined by the Dart Language Specification
  /// in section 16.15.1:
  /// <blockquote>
  /// The result of looking up method <i>m</i> in class <i>C</i> with respect to
  /// library <i>L</i> is: If <i>C</i> declares an instance method named
  /// <i>m</i> that is accessible to <i>L</i>, then that method is the result of
  /// the lookup. Otherwise, if <i>C</i> has a superclass <i>S</i>, then the
  /// result of the lookup is the result of looking up method <i>m</i> in
  /// <i>S</i> with respect to <i>L</i>. Otherwise, we say that the lookup has
  /// failed.
  /// </blockquote>
  // TODO(scheglov): Deprecate and remove it.
  MethodElement? lookUpConcreteMethod(
      String methodName, LibraryElement library);

  /// Returns the element representing the getter that results from looking up
  /// the given [getterName] in this class with respect to the given [library],
  /// or `null` if the look up fails.
  ///
  /// The behavior of this method is defined by the Dart Language Specification
  /// in section 16.15.2:
  /// <blockquote>
  /// The result of looking up getter (respectively setter) <i>m</i> in class
  /// <i>C</i> with respect to library <i>L</i> is: If <i>C</i> declares an
  /// instance getter (respectively setter) named <i>m</i> that is accessible to
  /// <i>L</i>, then that getter (respectively setter) is the result of the
  /// lookup. Otherwise, if <i>C</i> has a superclass <i>S</i>, then the result
  /// of the lookup is the result of looking up getter (respectively setter)
  /// <i>m</i> in <i>S</i> with respect to <i>L</i>. Otherwise, we say that the
  /// lookup has failed.
  /// </blockquote>
  @Deprecated('Use `element.augmented.lookUpGetter`.')
  PropertyAccessorElement? lookUpGetter(
      String getterName, LibraryElement library);

  /// Returns the element representing the getter that results from looking up
  /// the given [getterName] in the superclass of this class with respect to the
  /// given [library], ignoring abstract getters, or `null` if the look up
  /// fails.
  ///
  /// The behavior of this method is defined by the Dart Language Specification
  /// in section 16.15.2:
  /// <blockquote>
  /// The result of looking up getter (respectively setter) <i>m</i> in class
  /// <i>C</i> with respect to library <i>L</i> is: If <i>C</i> declares an
  /// instance getter (respectively setter) named <i>m</i> that is accessible to
  /// <i>L</i>, then that getter (respectively setter) is the result of the
  /// lookup. Otherwise, if <i>C</i> has a superclass <i>S</i>, then the result
  /// of the lookup is the result of looking up getter (respectively setter)
  /// <i>m</i> in <i>S</i> with respect to <i>L</i>. Otherwise, we say that the
  /// lookup has failed.
  /// </blockquote>
  // TODO(scheglov): Deprecate and remove it.
  PropertyAccessorElement? lookUpInheritedConcreteGetter(
      String getterName, LibraryElement library);

  /// Returns the element representing the method that results from looking up
  /// the given [methodName] in the superclass of this class with respect to the
  /// given [library], ignoring abstract methods, or `null` if the look up
  /// fails.
  ///
  /// The behavior of this method is defined by the Dart Language Specification
  /// in section 16.15.1:
  /// <blockquote>
  /// The result of looking up method <i>m</i> in class <i>C</i> with respect to
  /// library <i>L</i> is:  If <i>C</i> declares an instance method named
  /// <i>m</i> that is accessible to <i>L</i>, then that method is the result of
  /// the lookup. Otherwise, if <i>C</i> has a superclass <i>S</i>, then the
  /// result of the lookup is the result of looking up method <i>m</i> in
  /// <i>S</i> with respect to <i>L</i>. Otherwise, we say that the lookup has
  /// failed.
  /// </blockquote>
  // TODO(scheglov): Deprecate and remove it.
  MethodElement? lookUpInheritedConcreteMethod(
      String methodName, LibraryElement library);

  /// Returns the element representing the setter that results from looking up
  /// the given [setterName] in the superclass of this class with respect to the
  /// given [library], ignoring abstract setters, or `null` if the look up
  /// fails.
  ///
  /// The behavior of this method is defined by the Dart Language Specification
  /// in section 16.15.2:
  /// <blockquote>
  /// The result of looking up getter (respectively setter) <i>m</i> in class
  /// <i>C</i> with respect to library <i>L</i> is:  If <i>C</i> declares an
  /// instance getter (respectively setter) named <i>m</i> that is accessible to
  /// <i>L</i>, then that getter (respectively setter) is the result of the
  /// lookup. Otherwise, if <i>C</i> has a superclass <i>S</i>, then the result
  /// of the lookup is the result of looking up getter (respectively setter)
  /// <i>m</i> in <i>S</i> with respect to <i>L</i>. Otherwise, we say that the
  /// lookup has failed.
  /// </blockquote>
  // TODO(scheglov): Deprecate and remove it.
  PropertyAccessorElement? lookUpInheritedConcreteSetter(
      String setterName, LibraryElement library);

  /// Returns the element representing the method that results from looking up
  /// the given [methodName] in the superclass of this class with respect to the
  /// given [library], or `null` if the look up fails.
  ///
  /// The behavior of this method is defined by the Dart Language Specification
  /// in section 16.15.1:
  /// <blockquote>
  /// The result of looking up method <i>m</i> in class <i>C</i> with respect to
  /// library <i>L</i> is:  If <i>C</i> declares an instance method named
  /// <i>m</i> that is accessible to <i>L</i>, then that method is the result of
  /// the lookup. Otherwise, if <i>C</i> has a superclass <i>S</i>, then the
  /// result of the lookup is the result of looking up method <i>m</i> in
  /// <i>S</i> with respect to <i>L</i>. Otherwise, we say that the lookup has
  /// failed.
  /// </blockquote>
  // TODO(scheglov): Deprecate and remove it.
  MethodElement? lookUpInheritedMethod(
      String methodName, LibraryElement library);

  /// Returns the element representing the method that results from looking up
  /// the given [methodName] in this class with respect to the given [library],
  /// or `null` if the look up fails.
  ///
  /// The behavior of this method is defined by the Dart Language Specification
  /// in section 16.15.1:
  /// <blockquote>
  /// The result of looking up method <i>m</i> in class <i>C</i> with respect to
  /// library <i>L</i> is:  If <i>C</i> declares an instance method named
  /// <i>m</i> that is accessible to <i>L</i>, then that method is the result of
  /// the lookup. Otherwise, if <i>C</i> has a superclass <i>S</i>, then the
  /// result of the lookup is the result of looking up method <i>m</i> in
  /// <i>S</i> with respect to <i>L</i>. Otherwise, we say that the lookup has
  /// failed.
  /// </blockquote>
  @Deprecated('Use `element.augmented.lookUpMethod`.')
  MethodElement? lookUpMethod(String methodName, LibraryElement library);

  /// Returns the element representing the setter that results from looking up
  /// the given [setterName] in this class with respect to the given [library],
  /// or `null` if the look up fails.
  ///
  /// The behavior of this method is defined by the Dart Language Specification
  /// in section 16.15.2:
  /// <blockquote>
  /// The result of looking up getter (respectively setter) <i>m</i> in class
  /// <i>C</i> with respect to library <i>L</i> is: If <i>C</i> declares an
  /// instance getter (respectively setter) named <i>m</i> that is accessible to
  /// <i>L</i>, then that getter (respectively setter) is the result of the
  /// lookup. Otherwise, if <i>C</i> has a superclass <i>S</i>, then the result
  /// of the lookup is the result of looking up getter (respectively setter)
  /// <i>m</i> in <i>S</i> with respect to <i>L</i>. Otherwise, we say that the
  /// lookup has failed.
  /// </blockquote>
  @Deprecated('Use `element.augmented.lookUpSetter`.')
  PropertyAccessorElement? lookUpSetter(
      String setterName, LibraryElement library);
}

/// A pattern variable that is a join of other pattern variables, created
/// for a logical-or patterns, or shared `case` bodies in `switch` statements.
///
/// Clients may not extend, implement or mix-in this class.
@Deprecated(
    'Use JoinPatternVariableFragment and JoinPatternVariableElement2 instead')
abstract class JoinPatternVariableElement implements PatternVariableElement {
  /// Whether the [variables] are consistent, present in all branches,
  /// and have the same type and finality.
  bool get isConsistent;

  /// The variables that join into this variable.
  List<PatternVariableElement> get variables;
}

/// A label associated with a statement.
///
/// Clients may not extend, implement or mix-in this class.
@Deprecated('Use LabelElement2 instead')
abstract class LabelElement implements Element {
  @Deprecated(elementModelDeprecationMsg)
  @override
  ExecutableElement get enclosingElement3;

  @override
  String get name;
}

/// A library.
///
/// Clients may not extend, implement or mix-in this class.
@Deprecated('Use LibraryElement2 instead')
abstract class LibraryElement implements _ExistingElement {
  /// The compilation unit that defines this library.
  @Deprecated(elementModelDeprecationMsg)
  CompilationUnitElement get definingCompilationUnit;

  /// Returns `null`, because libraries are the top-level elements in the model.
  @override
  Null get enclosingElement3;

  /// The entry point for this library, or `null` if this library does
  /// not have an entry point.
  ///
  /// The entry point is defined to be a zero argument top-level function
  /// whose name is `main`.
  @Deprecated(elementModelDeprecationMsg)
  FunctionElement? get entryPoint;

  /// The libraries that are exported from this library.
  List<LibraryElement> get exportedLibraries;

  /// The export [Namespace] of this library.
  Namespace get exportNamespace;

  /// The set of features available to this library.
  ///
  /// Determined by the combination of the language version for the enclosing
  /// package, enabled experiments, and the presence of a `// @dart` language
  /// version override comment at the top of the file.
  FeatureSet get featureSet;

  /// The identifier that uniquely identifies this element among the children
  /// of this element's parent.
  String get identifier;

  /// The libraries that are imported into this library.
  ///
  /// This includes all of the libraries that are imported using a prefix, and
  /// those that are imported without a prefix.
  List<LibraryElement> get importedLibraries;

  /// Whether the library is the `dart:async` library.
  bool get isDartAsync;

  /// Whether the library is the `dart:core` library.
  bool get isDartCore;

  /// Whether the library is part of the SDK.
  bool get isInSdk;

  /// The language version for this library.
  LibraryLanguageVersion get languageVersion;

  @override
  LibraryElement get library;

  /// The element representing the synthetic function `loadLibrary` that is
  /// implicitly defined for this library if the library is imported using a
  /// deferred import.
  @Deprecated(elementModelDeprecationMsg)
  FunctionElement get loadLibraryFunction;

  /// The name of this library, possibly the empty string if this library does
  /// not have an explicit name.
  @override
  String get name;

  /// The public [Namespace] of this library.
  Namespace get publicNamespace;

  @override
  AnalysisSession get session;

  /// The top-level elements defined in each of the compilation units that are
  /// included in this library. This includes both public and private elements,
  /// but does not include imports, exports, or synthetic elements.
  Iterable<Element> get topLevelElements;

  /// The [TypeProvider] that is used in this library.
  TypeProvider get typeProvider;

  /// The [TypeSystem] that is used in this library.
  TypeSystem get typeSystem;

  /// The compilation units this library consists of.
  ///
  /// This includes the defining compilation unit and units included using the
  /// `part` directive.
  @Deprecated(elementModelDeprecationMsg)
  List<CompilationUnitElement> get units;

  /// The class defined in this library that has the given [name], or
  /// `null` if this library does not define a class with the given name.
  @Deprecated(elementModelDeprecationMsg)
  ClassElement? getClass(String name);
}

/// A single export directive within a library.
///
/// Clients may not extend, implement or mix-in this class.
@Deprecated('Use LibraryExport instead')
abstract class LibraryExportElement implements _ExistingElement {
  /// The combinators that were specified as part of the `export` directive in
  /// the order in which they were specified.
  List<NamespaceCombinator> get combinators;

  @Deprecated(elementModelDeprecationMsg)
  @override
  CompilationUnitElement get enclosingElement3;

  /// The [LibraryElement], if [uri] is a [DirectiveUriWithLibrary].
  LibraryElement? get exportedLibrary;

  /// The offset of the `export` keyword.
  int get exportKeywordOffset;

  /// The interpretation of the URI specified in the directive.
  DirectiveUri get uri;
}

/// A single import directive within a library.
///
/// Clients may not extend, implement or mix-in this class.
@Deprecated('Use LibraryImport instead')
abstract class LibraryImportElement implements _ExistingElement {
  /// The combinators that were specified as part of the `import` directive in
  /// the order in which they were specified.
  List<NamespaceCombinator> get combinators;

  @Deprecated(elementModelDeprecationMsg)
  @override
  CompilationUnitElement get enclosingElement3;

  /// The [LibraryElement], if [uri] is a [DirectiveUriWithLibrary].
  LibraryElement? get importedLibrary;

  /// The offset of the `import` keyword.
  int get importKeywordOffset;

  /// The [Namespace] that this directive contributes to the containing library.
  Namespace get namespace;

  /// The prefix that was specified as part of the import directive, or `null`
  /// if there was no prefix specified.
  @Deprecated(elementModelDeprecationMsg)
  ImportElementPrefix? get prefix;

  /// The interpretation of the URI specified in the directive.
  DirectiveUri get uri;
}

class LibraryLanguageVersion {
  /// The version for the whole package that contains this library.
  final Version package;

  /// The version specified using `@dart` override, `null` if absent or invalid.
  final Version? override;

  LibraryLanguageVersion({
    required this.package,
    required this.override,
  });

  /// The effective language version for the library.
  Version get effective {
    return override ?? package;
  }
}

/// An element that can be (but is not required to be) defined within a method
/// or function (an [ExecutableElement]).
///
/// Clients may not extend, implement or mix-in this class.
@Deprecated('Use LocalElement2 instead')
abstract class LocalElement implements Element {}

/// A local variable.
///
/// Clients may not extend, implement or mix-in this class.
@Deprecated('Use LocalVariableFragment and LocalVariableElement2 instead')
abstract class LocalVariableElement implements PromotableElement {
  /// Whether the variable has an initializer at declaration.
  bool get hasInitializer;

  @override
  String get name;
}

/// An element that represents a method defined within a class.
///
/// Clients may not extend, implement or mix-in this class.
@Deprecated('Use MethodElement2 instead')
abstract class MethodElement implements ClassMemberElement, ExecutableElement {
  @override
  MethodElement get declaration;
}

/// An element that represents a mixin.
///
/// Clients may not extend, implement or mix-in this class.
@Deprecated('Use MixinElement2 instead')
abstract class MixinElement implements InterfaceElement {
  @Deprecated(elementModelDeprecationMsg)
  @override
  AugmentedMixinElement get augmented;

  /// Whether the mixin is a base mixin.
  ///
  /// A mixin is a base mixin if it has an explicit `base` modifier.
  /// The base modifier allows a mixin to be mixed in, but not implemented.
  bool get isBase;

  /// The superclass constraints defined for this mixin.
  ///
  /// If the declaration does not have an `on` clause, then the list will
  /// contain the type for the class `Object`.
  ///
  /// <b>Note:</b> Because the element model represents the state of the code,
  /// it is possible for it to be semantically invalid. In particular, it is not
  /// safe to assume that the inheritance structure of a class does not contain
  /// a cycle. Clients that traverse the inheritance structure must explicitly
  /// guard against infinite loops.
  List<InterfaceType> get superclassConstraints;

  /// Whether the element, assuming that it is within scope, is
  /// implementable to classes, mixins, and enums in the given [library].
  bool isImplementableIn(LibraryElement library);
}

/// A pseudo-element that represents multiple elements defined within a single
/// scope that have the same name. This situation is not allowed by the
/// language, so objects implementing this interface always represent an error.
/// As a result, most of the normal operations on elements do not make sense
/// and will return useless results.
///
/// Clients may not extend, implement or mix-in this class.
@Deprecated('Use MultiplyDefinedElement2 instead')
abstract class MultiplyDefinedElement implements Element {
  /// The elements that were defined within the scope to have the same name.
  List<Element> get conflictingElements;
}

/// An object that controls how namespaces are combined.
///
/// Clients may not extend, implement or mix-in this class.
sealed class NamespaceCombinator {
  /// The offset of the character immediately following the last character of
  /// this node.
  int get end;

  /// The offset of the first character of this node.
  int get offset;
}

/// A parameter defined within an executable element.
///
/// Clients may not extend, implement or mix-in this class.
@Deprecated('Use FormalParameterElement instead')
abstract class ParameterElement
    implements PromotableElement, ConstantEvaluationTarget {
  @override
  ParameterElement get declaration;

  /// The code of the default value, or `null` if no default value.
  String? get defaultValueCode;

  @experimental
  FormalParameterElement get element;

  /// Whether the parameter has a default value.
  bool get hasDefaultValue;

  /// Whether the parameter is covariant, meaning it is allowed to have a
  /// narrower type in an override.
  bool get isCovariant;

  /// Whether the parameter is an initializing formal parameter.
  bool get isInitializingFormal;

  /// Whether the parameter is a named parameter.
  ///
  /// Named parameters that are annotated with the `@required` annotation are
  /// considered optional. Named parameters that are annotated with the
  /// `required` syntax are considered required.
  bool get isNamed;

  /// Whether the parameter is an optional parameter.
  ///
  /// Optional parameters can either be positional or named. Named parameters
  /// that are annotated with the `@required` annotation are considered
  /// optional. Named parameters that are annotated with the `required` syntax
  /// are considered required.
  bool get isOptional;

  /// Whether the parameter is both an optional and named parameter.
  ///
  /// Named parameters that are annotated with the `@required` annotation are
  /// considered optional. Named parameters that are annotated with the
  /// `required` syntax are considered required.
  bool get isOptionalNamed;

  /// Whether the parameter is both an optional and positional parameter.
  bool get isOptionalPositional;

  /// Whether the parameter is a positional parameter.
  ///
  /// Positional parameters can either be required or optional.
  bool get isPositional;

  /// Whether the parameter is either a required positional parameter, or a
  /// named parameter with the `required` keyword.
  ///
  /// Note: the presence or absence of the `@required` annotation does not
  /// change the meaning of this getter. The parameter `{@required int x}`
  /// will return `false` and the parameter `{@required required int x}`
  /// will return `true`.
  bool get isRequired;

  /// Whether the parameter is both a required and named parameter.
  ///
  /// Named parameters that are annotated with the `@required` annotation are
  /// considered optional. Named parameters that are annotated with the
  /// `required` syntax are considered required.
  bool get isRequiredNamed;

  /// Whether the parameter is both a required and positional parameter.
  bool get isRequiredPositional;

  /// Whether the parameter is a super formal parameter.
  bool get isSuperFormal;

  @override
  String get name;

  /// The kind of this parameter.
  @Deprecated('Use the getters isOptionalNamed, isOptionalPositional, '
      'isRequiredNamed, and isRequiredPositional')
  ParameterKind get parameterKind;

  /// The parameters defined by this parameter.
  ///
  /// A parameter will only define other parameters if it is a function typed
  /// parameter.
  List<ParameterElement> get parameters;

  /// The type parameters defined by this parameter.
  ///
  /// A parameter will only define type parameters if it is a function typed
  /// parameter.
  @Deprecated(elementModelDeprecationMsg)
  List<TypeParameterElement> get typeParameters;

  /// Appends the type, name and possibly the default value of this parameter
  /// to the given [buffer].
  void appendToWithoutDelimiters(
    StringBuffer buffer, {
    @Deprecated('Only non-nullable by default mode is supported')
    bool withNullability = true,
  });
}

/// A 'part' directive within a library.
///
/// Clients may not extend, implement or mix-in this class.
@Deprecated('Use PartInclude instead')
abstract class PartElement implements _ExistingElement {
  /// The interpretation of the URI specified in the directive.
  DirectiveUri get uri;
}

/// A pattern variable.
///
/// Clients may not extend, implement or mix-in this class.
@Deprecated('Use PatternVariableFragment and PatternVariableElement2 instead')
abstract class PatternVariableElement implements LocalVariableElement {
  /// The variable in which this variable joins with other pattern variables
  /// with the same name, in a logical-or pattern, or shared case scope.
  JoinPatternVariableElement? get join;
}

/// A prefix used to import one or more libraries into another library.
///
/// Clients may not extend, implement or mix-in this class.
@Deprecated('Use PrefixElement2 instead')
abstract class PrefixElement implements _ExistingElement {
  @Deprecated(elementModelDeprecationMsg)
  @override
  CompilationUnitElement get enclosingElement3;

  /// The imports that share this prefix.
  List<LibraryImportElement> get imports;

  @override
  String get name;

  /// The name lookup scope for this import prefix.
  ///
  /// It consists of elements imported into the enclosing library with this
  /// prefix. The namespace combinators of the import directives are taken
  /// into account.
  Scope get scope;
}

/// A variable that might be subject to type promotion.  This might be a local
/// variable or a parameter.
///
/// Clients may not extend, implement or mix-in this class.
@Deprecated('Use PromotableElement2 instead')
abstract class PromotableElement implements LocalElement, VariableElement {
  // Promotable elements are guaranteed to have a name.
  @override
  String get name;
}

/// A getter or a setter. Note that explicitly defined property accessors
/// implicitly define a synthetic field. Symmetrically, synthetic accessors are
/// implicitly created for explicitly defined fields. The following rules apply:
///
/// * Every explicit field is represented by a non-synthetic [FieldElement].
/// * Every explicit field induces a getter and possibly a setter, both of which
///   are represented by synthetic [PropertyAccessorElement]s.
/// * Every explicit getter or setter is represented by a non-synthetic
///   [PropertyAccessorElement].
/// * Every explicit getter or setter (or pair thereof if they have the same
///   name) induces a field that is represented by a synthetic [FieldElement].
///
/// Clients may not extend, implement or mix-in this class.
@Deprecated('Use PropertyAccessorElement2 instead')
abstract class PropertyAccessorElement implements ExecutableElement {
  /// The accessor representing the getter that corresponds to (has the same
  /// name as) this setter, or `null` if this accessor is not a setter or
  /// if there is no corresponding getter.
  PropertyAccessorElement? get correspondingGetter;

  /// The accessor representing the setter that corresponds to (has the same
  /// name as) this getter, or `null` if this accessor is not a getter or
  /// if there is no corresponding setter.
  PropertyAccessorElement? get correspondingSetter;

  @override
  PropertyAccessorElement get declaration;

  @override
  Element get enclosingElement3;

  /// Whether the accessor represents a getter.
  bool get isGetter;

  /// Whether the accessor represents a setter.
  bool get isSetter;

  /// The field or top-level variable associated with this accessor.
  ///
  /// If this accessor was explicitly defined (is not synthetic) then the
  /// variable associated with it will be synthetic.
  ///
  /// If this accessor is an augmentation, and [augmentationTarget] is `null`,
  /// the variable is `null`.
  PropertyInducingElement? get variable2;
}

/// A variable that has an associated getter and possibly a setter. Note that
/// explicitly defined variables implicitly define a synthetic getter and that
/// non-`final` explicitly defined variables implicitly define a synthetic
/// setter. Symmetrically, synthetic fields are implicitly created for
/// explicitly defined getters and setters. The following rules apply:
///
/// * Every explicit variable is represented by a non-synthetic
///   [PropertyInducingElement].
/// * Every explicit variable induces a getter and possibly a setter, both of
///   which are represented by synthetic [PropertyAccessorElement]s.
/// * Every explicit getter or setter is represented by a non-synthetic
///   [PropertyAccessorElement].
/// * Every explicit getter or setter (or pair thereof if they have the same
///   name) induces a variable that is represented by a synthetic
///   [PropertyInducingElement].
///
/// Clients may not extend, implement or mix-in this class.
@Deprecated('Use PropertyInducingElement2 instead')
abstract class PropertyInducingElement implements VariableElement {
  @override
  String get displayName;

  /// The getter associated with this variable.
  ///
  /// If this variable was explicitly defined (is not synthetic) then the
  /// getter associated with it will be synthetic.
  @Deprecated(elementModelDeprecationMsg)
  PropertyAccessorElement? get getter;

  /// Whether the variable has an initializer at declaration.
  bool get hasInitializer;

  /// Whether the element is an augmentation.
  ///
  /// If `true`, declaration has the explicit `augment` modifier.
  bool get isAugmentation;

  @override
  LibraryElement get library;

  @override
  String get name;

  /// The setter associated with this variable, or `null` if the variable
  /// is effectively `final` and therefore does not have a setter associated
  /// with it.
  ///
  /// This can happen either because the variable is explicitly defined as
  /// being `final` or because the variable is induced by an explicit getter
  /// that does not have a corresponding setter. If this variable was
  /// explicitly defined (is not synthetic) then the setter associated with
  /// it will be synthetic.
  @Deprecated(elementModelDeprecationMsg)
  PropertyAccessorElement? get setter;
}

/// A combinator that cause some of the names in a namespace to be visible (and
/// the rest hidden) when being imported.
///
/// Clients may not extend, implement or mix-in this class.
abstract class ShowElementCombinator implements NamespaceCombinator {
  /// The names that are to be made visible in the importing library if they
  /// are defined in the imported library.
  List<String> get shownNames;
}

/// A super formal parameter defined within a constructor element.
///
/// Clients may not extend, implement or mix-in this class.
@Deprecated('Use SuperFormalParameterElement2 instead')
abstract class SuperFormalParameterElement implements ParameterElement {
  /// The associated super-constructor parameter, from the super-constructor
  /// that is referenced by the implicit or explicit super-constructor
  /// invocation.
  ///
  /// Can be `null` for erroneous code - not existing super-constructor,
  /// no corresponding parameter in the super-constructor.
  ParameterElement? get superConstructorParameter;
}

/// A top-level variable.
///
/// Clients may not extend, implement or mix-in this class.
@Deprecated('Use TopLevelVariableElement2 instead')
abstract class TopLevelVariableElement implements PropertyInducingElement {
  @override
  TopLevelVariableElement get declaration;

  /// Whether the field was explicitly marked as being external.
  bool get isExternal;
}

/// A type alias (`typedef`).
///
/// Clients may not extend, implement or mix-in this class.
@Deprecated('Use TypeAliasElement2 instead')
abstract class TypeAliasElement
    implements TypeParameterizedElement, TypeDefiningElement {
  /// If the aliased type has structure, return the corresponding element.
  /// For example it could be [GenericFunctionTypeElement].
  ///
  /// If there is no structure, return `null`.
  @Deprecated(elementModelDeprecationMsg)
  Element? get aliasedElement;

  /// The aliased type.
  ///
  /// If non-function type aliases feature is enabled for the enclosing library,
  /// this type might be just anything. If the feature is disabled, return
  /// a [FunctionType].
  DartType get aliasedType;

  @Deprecated(elementModelDeprecationMsg)
  @override
  CompilationUnitElement get enclosingElement3;

  /// Whether the element is an augmentation.
  ///
  /// If `true`, declaration has the explicit `augment` modifier.
  bool get isAugmentation;

  @override
  String get name;

  /// Produces the type resulting from instantiating this typedef with the given
  /// [typeArguments] and [nullabilitySuffix].
  ///
  /// Note that this always instantiates the typedef itself, so for a
  /// [TypeAliasElement] the returned [DartType] might still be a generic
  /// type, with type formals. For example, if the typedef is:
  ///
  ///     typedef F<T> = void Function<U>(T, U);
  ///
  /// then `F<int>` will produce `void Function<U>(int, U)`.
  DartType instantiate({
    required List<DartType> typeArguments,
    required NullabilitySuffix nullabilitySuffix,
  });
}

/// An element that defines a type.
///
/// Clients may not extend, implement or mix-in this class.
@Deprecated('Use TypeDefiningElement2 instead')
abstract class TypeDefiningElement implements Element {}

/// A type parameter.
///
/// Clients may not extend, implement or mix-in this class.
@Deprecated('Use TypeParameterElement2 instead')
abstract class TypeParameterElement implements TypeDefiningElement {
  /// The type representing the bound associated with this parameter, or `null`
  /// if this parameter does not have an explicit bound. Being able to
  /// distinguish between an implicit and explicit bound is needed by the
  /// instantiate to bounds algorithm.
  DartType? get bound;

  @override
  TypeParameterElement get declaration;

  @override
  String get displayName;

  @override
  String get name;

  /// Creates the [TypeParameterType] with the given [nullabilitySuffix] for
  /// this type parameter.
  TypeParameterType instantiate({
    required NullabilitySuffix nullabilitySuffix,
  });
}

/// An element that has type parameters, such as a class or a typedef. This also
/// includes functions and methods if support for generic methods is enabled.
///
/// Clients may not extend, implement or mix-in this class.
@Deprecated('Use TypeParameterizedElement2 instead')
abstract class TypeParameterizedElement implements _ExistingElement {
  /// If the element defines a type, indicates whether the type may safely
  /// appear without explicit type parameters as the bounds of a type parameter
  /// declaration.
  ///
  /// If the element does not define a type, returns `true`.
  bool get isSimplyBounded;

  /// The type parameters declared by this element directly.
  ///
  /// This does not include type parameters that are declared by any enclosing
  /// elements.
  @Deprecated(elementModelDeprecationMsg)
  List<TypeParameterElement> get typeParameters;
}

/// A pseudo-elements that represents names that are undefined. This situation
/// is not allowed by the language, so objects implementing this interface
/// always represent an error. As a result, most of the normal operations on
/// elements do not make sense and will return useless results.
///
/// Clients may not extend, implement or mix-in this class.
@Deprecated('Not used anymore')
abstract class UndefinedElement implements Element {}

/// An element included into a library using some URI.
///
/// Clients may not extend, implement or mix-in this class.
@Deprecated('Use Element2 instead')
abstract class UriReferencedElement implements _ExistingElement {
  /// The URI that is used to include this element into the enclosing library,
  /// or `null` if this is the defining compilation unit of a library.
  String? get uri;

  /// The offset of the character immediately following the last character of
  /// this node's URI, or `-1` for synthetic import.
  int get uriEnd;

  /// The offset of the URI in the file, or `-1` if this element is synthetic.
  int get uriOffset;
}

/// A variable. There are more specific subclasses for more specific kinds of
/// variables.
///
/// Clients may not extend, implement or mix-in this class.
@Deprecated('Use VariableElement2 instead')
abstract class VariableElement implements Element, ConstantEvaluationTarget {
  @override
  VariableElement get declaration;

  /// Whether the variable element did not have an explicit type specified
  /// for it.
  bool get hasImplicitType;

  /// Whether the variable was declared with the 'const' modifier.
  bool get isConst;

  /// Whether the variable was declared with the 'final' modifier.
  ///
  /// Variables that are declared with the 'const' modifier will return `false`
  /// even though they are implicitly final.
  bool get isFinal;

  /// Whether the variable uses late evaluation semantics.
  ///
  /// This will always return `false` unless the experiment 'non-nullable' is
  /// enabled.
  bool get isLate;

  /// Whether the element is a static variable, as per section 8 of the Dart
  /// Language Specification:
  ///
  /// > A static variable is a variable that is not associated with a particular
  /// > instance, but rather with an entire library or class. Static variables
  /// > include library variables and class variables. Class variables are
  /// > variables whose declaration is immediately nested inside a class
  /// > declaration and includes the modifier static. A library variable is
  /// > implicitly static.
  bool get isStatic;

  @override
  String get name;

  /// The declared type of this variable.
  DartType get type;

  /// Returns a representation of the value of this variable, forcing the value
  /// to be computed if it had not previously been computed, or `null` if either
  /// this variable was not declared with the 'const' modifier or if the value
  /// of this variable could not be computed because of errors.
  DartObject? computeConstantValue();
}

/// This class exists to provide non-nullable overrides for existing elements,
/// as opposite to artificial "multiply defined" element.
@Deprecated('Use Element2 instead')
@AnalyzerPublicApi(
    message: 'Exposed because it is implemented by various elements')
abstract class _ExistingElement implements Element {
  @Deprecated(elementModelDeprecationMsg)
  @override
  Element get declaration;

  @Deprecated(elementModelDeprecationMsg)
  @override
  LibraryElement get library;

  @override
  Source get librarySource;

  @override
  Source get source;
}
