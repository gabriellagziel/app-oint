// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/element/element2.dart';
import 'package:analyzer/error/listener.dart';
import 'package:analyzer/src/dart/element/element.dart';
import 'package:analyzer/src/dart/element/inheritance_manager3.dart';
import 'package:analyzer/src/dart/element/type.dart';
import 'package:analyzer/src/dart/element/type_system.dart';
import 'package:analyzer/src/error/codes.dart';

/// Verifies that the return type of the getter matches the parameter type
/// of the corresponding setter. Where "match" means "subtype" in non-nullable,
/// and "assignable" in legacy.
class GetterSetterTypesVerifier {
  final LibraryElementImpl library;
  final TypeSystemImpl _typeSystem;
  final ErrorReporter _errorReporter;

  GetterSetterTypesVerifier({
    required this.library,
    required ErrorReporter errorReporter,
  })  : _typeSystem = library.typeSystem,
        _errorReporter = errorReporter;

  bool get _skipGetterSetterTypesCheck {
    return library.featureSet.isEnabled(Feature.getter_setter_error);
  }

  void checkExtension(ExtensionElementImpl2 element) {
    if (_skipGetterSetterTypesCheck) {
      return;
    }

    for (var getter in element.getters2) {
      _checkLocalGetter(getter);
    }
  }

  void checkExtensionType(
      ExtensionTypeElementImpl2 element, Interface interface) {
    if (_skipGetterSetterTypesCheck) {
      return;
    }

    checkInterface(element, interface);
    checkStaticGetters(element.getters2);
  }

  void checkInterface(InterfaceElementImpl2 element, Interface interface) {
    if (_skipGetterSetterTypesCheck) {
      return;
    }

    var libraryUri = element.library2.uri;

    var interfaceMap = interface.map2;
    for (var entry in interfaceMap.entries) {
      var getterName = entry.key;
      if (!getterName.isAccessibleFor(libraryUri)) continue;

      var getter = entry.value;
      if (getter.kind == ElementKind.GETTER) {
        var setter = interfaceMap[getterName.forSetter];
        if (setter != null && setter.formalParameters.length == 1) {
          var getterType = getter.returnType;
          var setterType = setter.formalParameters[0].type;
          if (!_typeSystem.isSubtypeOf(getterType, setterType)) {
            Element2 errorElement;
            if (getter.enclosingElement2 == element) {
              if (element is ExtensionTypeElementImpl2 &&
                  element.representation2.getter2 == getter) {
                errorElement = setter;
              } else {
                errorElement = getter;
              }
            } else if (setter.enclosingElement2 == element) {
              errorElement = setter;
            } else {
              errorElement = element;
            }

            var getterName = getter.displayName;
            if (getter.enclosingElement2 != element) {
              var getterClassName = getter.enclosingElement2!.displayName;
              getterName = '$getterClassName.$getterName';
            }

            var setterName = setter.displayName;
            if (setter.enclosingElement2 != element) {
              var setterClassName = setter.enclosingElement2!.displayName;
              setterName = '$setterClassName.$setterName';
            }

            _errorReporter.atElement2(
              errorElement,
              CompileTimeErrorCode.GETTER_NOT_SUBTYPE_SETTER_TYPES,
              arguments: [getterName, getterType, setterType, setterName],
            );
          }
        }
      }
    }
  }

  void checkStaticGetters(List<GetterElement2OrMember> getters) {
    if (_skipGetterSetterTypesCheck) {
      return;
    }

    for (var getter in getters) {
      if (getter.isStatic) {
        _checkLocalGetter(getter);
      }
    }
  }

  void _checkLocalGetter(GetterElement2OrMember getter) {
    var name = getter.name3;
    if (name == null) {
      return;
    }

    var setter = getter.variable3?.setter2;
    if (setter == null) {
      return;
    }

    var setterType = _getSetterType(setter);
    if (setterType == null) {
      return;
    }

    var getterType = _getGetterType(getter);
    if (!_typeSystem.isSubtypeOf(getterType, setterType)) {
      _errorReporter.atElement2(
        getter,
        CompileTimeErrorCode.GETTER_NOT_SUBTYPE_SETTER_TYPES,
        arguments: [name, getterType, setterType, name],
      );
    }
  }

  /// Return the return type of the [getter].
  static TypeImpl _getGetterType(GetterElement2OrMember getter) {
    return getter.returnType;
  }

  /// Return the type of the first parameter of the [setter].
  static TypeImpl? _getSetterType(SetterElement2OrMember setter) {
    var parameters = setter.formalParameters;
    if (parameters.isNotEmpty) {
      return parameters[0].type;
    } else {
      return null;
    }
  }
}
