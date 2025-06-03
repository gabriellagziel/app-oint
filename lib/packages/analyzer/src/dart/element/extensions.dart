// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/element/element2.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/src/dart/element/element.dart';
import 'package:analyzer/src/dart/element/type.dart';
import 'package:analyzer/src/generated/utilities_dart.dart';
import 'package:analyzer/src/utilities/extensions/element.dart';
import 'package:analyzer/src/utilities/extensions/string.dart';
import 'package:meta/meta_meta.dart';

extension DartTypeExtension on DartType {
  bool get isExtensionType {
    return element3 is ExtensionTypeElement2;
  }
}

extension Element2Extension on Element2 {
  TypeImpl? get firstParameterType {
    var self = this;
    if (self is MethodElement2OrMember) {
      return self.formalParameters.firstOrNull?.type;
    }
    return null;
  }

  /// Return `true` if this element, the enclosing class (if there is one), or
  /// the enclosing library, has been annotated with the `@doNotStore`
  /// annotation.
  bool get hasOrInheritsDoNotStore {
    if (this case Annotatable annotatable) {
      if (annotatable.metadata2.hasDoNotStore) {
        return true;
      }
    }

    var ancestor = enclosingElement2;
    if (ancestor is InterfaceElement2) {
      if (ancestor.metadata2.hasDoNotStore) {
        return true;
      }
      ancestor = ancestor.enclosingElement2;
    } else if (ancestor is ExtensionElement2) {
      if (ancestor.metadata2.hasDoNotStore) {
        return true;
      }
      ancestor = ancestor.enclosingElement2;
    }

    return ancestor is LibraryElement2 && ancestor.metadata2.hasDoNotStore;
  }

  /// Return `true` if this element is an instance member of a class or mixin.
  ///
  /// Only [MethodElement2]s, [GetterElement]s, and  [SetterElement]s are
  /// supported.
  ///
  /// We intentionally exclude [ConstructorElement2]s - they can only be
  /// invoked in instance creation expressions, and [FieldElement2]s - they
  /// cannot be invoked directly and are always accessed using corresponding
  /// [GetterElement]s or [SetterElement]s.
  bool get isInstanceMember {
    assert(this is! PropertyInducingElement2,
        'Check the GetterElement or SetterElement instead');
    var this_ = this;
    var enclosing = this_.enclosingElement2;
    if (enclosing is InterfaceElement2) {
      return this_ is MethodElement2 && !this_.isStatic ||
          this_ is GetterElement && !this_.isStatic ||
          this_ is SetterElement && !this_.isStatic;
    }
    return false;
  }

  /// Whether this element is a wildcard variable.
  bool get isWildcardVariable {
    return name3 == '_' &&
        (this is LocalFunctionElement ||
            this is LocalVariableElement2 ||
            this is PrefixElement2 ||
            this is TypeParameterElement2 ||
            (this is FormalParameterElement &&
                this is! FieldFormalParameterElement2 &&
                this is! SuperFormalParameterElement2)) &&
        library2.hasWildcardVariablesFeatureEnabled;
  }
}

extension Element2OrNullExtension on Element2? {
  /// Return true if this element is a wildcard variable.
  bool get isWildcardVariable {
    return this?.isWildcardVariable ?? false;
  }
}

extension ElementAnnotationExtensions on ElementAnnotation {
  static final Map<String, TargetKind> _targetKindsByName = {
    for (var kind in TargetKind.values) kind.name: kind,
  };

  /// Return the target kinds defined for this [ElementAnnotation].
  Set<TargetKind> get targetKinds {
    var element = element2;
    InterfaceElement2? interfaceElement;

    if (element is GetterElement) {
      var type = element.returnType;
      if (type is InterfaceType) {
        interfaceElement = type.element3;
      }
    } else if (element is ConstructorElement2) {
      interfaceElement = element.enclosingElement2;
    }
    if (interfaceElement == null) {
      return const <TargetKind>{};
    }
    for (var annotation in interfaceElement.metadata) {
      if (annotation.isTarget) {
        var value = annotation.computeConstantValue();
        if (value == null) {
          return const <TargetKind>{};
        }

        var annotationKinds = value.getField('kinds')?.toSetValue();
        if (annotationKinds == null) {
          return const <TargetKind>{};
        }

        return annotationKinds
            .map((e) {
              // Support class-based and enum-based target kind implementations.
              var field = e.getField('name') ?? e.getField('_name');
              return field?.toStringValue();
            })
            .map((name) => _targetKindsByName[name])
            .nonNulls
            .toSet();
      }
    }
    return const <TargetKind>{};
  }
}

extension ExecutableElement2Extension on ExecutableElement2 {
  /// Whether the enclosing element is the class `Object`.
  bool get isObjectMember {
    var enclosing = enclosingElement2;
    return enclosing is ClassElement2 && enclosing.isDartCoreObject;
  }
}

extension FormalParameterElementMixinExtension on FormalParameterElementMixin {
  /// Returns [FormalParameterElementImpl] with the specified properties
  /// replaced.
  FormalParameterElementImpl copyWith({
    TypeImpl? type,
    ParameterKind? kind,
    bool? isCovariant,
  }) {
    var firstFragment = this.firstFragment as ParameterElementImpl;
    return FormalParameterElementImpl(
      firstFragment.copyWith(
        type: type,
        kind: kind,
        isCovariant: isCovariant,
      ),
    );
  }
}

extension InterfaceTypeExtension on InterfaceType {
  bool get isDartCoreObjectNone {
    return isDartCoreObject && nullabilitySuffix == NullabilitySuffix.none;
  }
}

extension LibraryExtension2 on LibraryElement2? {
  bool get hasWildcardVariablesFeatureEnabled =>
      this?.featureSet.isEnabled(Feature.wildcard_variables) ?? false;
}

extension ParameterElementMixinExtension on ParameterElementMixin {
  /// Return [ParameterElementImpl] with the specified properties replaced.
  ParameterElementImpl copyWith({
    TypeImpl? type,
    ParameterKind? kind,
    bool? isCovariant,
  }) {
    return ParameterElementImpl.synthetic(
      name.nullIfEmpty,
      type ?? this.type,
      kind ?? parameterKind,
    )..isExplicitlyCovariant = isCovariant ?? this.isCovariant;
  }
}

extension RecordTypeExtension on RecordType {
  /// A regular expression used to match positional field names.
  static final RegExp _positionalName = RegExp(r'^\$[1-9]\d*$');

  List<RecordTypeField> get fields {
    return [
      ...positionalFields,
      ...namedFields,
    ];
  }

  /// The [name] is either an actual name like `foo` in `({int foo})`, or
  /// the name of a positional field like `$1` in `(int, String)`.
  RecordTypeFieldImpl? fieldByName(String name) {
    return namedField(name) ?? positionalField(name);
  }

  RecordTypeNamedFieldImpl? namedField(String name) {
    for (var field in namedFields) {
      if (field.name == name) {
        // TODO(paulberry): eliminate this cast by changing the extension to
        // only apply to `RecordTypeImpl`.
        return field as RecordTypeNamedFieldImpl;
      }
    }
    return null;
  }

  RecordTypePositionalFieldImpl? positionalField(String name) {
    var index = positionalFieldIndex(name);
    if (index != null && index < positionalFields.length) {
      // TODO(paulberry): eliminate this cast by changing the extension to only
      // apply to `RecordTypeImpl`.
      return positionalFields[index] as RecordTypePositionalFieldImpl;
    }
    return null;
  }

  /// Attempt to parse `$1`, `$2`, etc.
  static int? positionalFieldIndex(String name) {
    if (_positionalName.hasMatch(name)) {
      var positionString = name.substring(1);
      // Use `tryParse` instead of `parse`
      // even though the numeral matches the pattern `[1-9]\d*`,
      // to reject numerals too big to fit in an `int`.
      var position = int.tryParse(positionString);
      if (position != null) return position - 1;
    }
    return null;
  }
}

extension TypeParameterElementImplExtension on TypeParameterElementImpl {
  bool get isWildcardVariable {
    return name == '_' && library.hasWildcardVariablesFeatureEnabled;
  }
}
