// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/element/element2.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/listener.dart';
import 'package:analyzer/src/dart/ast/ast.dart';
import 'package:analyzer/src/dart/element/element.dart';
import 'package:analyzer/src/dart/element/type.dart';
import 'package:analyzer/src/dart/element/type_constraint_gatherer.dart';
import 'package:analyzer/src/dart/element/type_schema.dart';
import 'package:analyzer/src/dart/resolver/invocation_inference_helper.dart';
import 'package:analyzer/src/dart/resolver/invocation_inferrer.dart';
import 'package:analyzer/src/error/codes.dart';
import 'package:analyzer/src/generated/resolver.dart';

class AnnotationResolver {
  final ResolverVisitor _resolver;

  AnnotationResolver(this._resolver);

  LibraryElementImpl get _definingLibrary => _resolver.definingLibrary;

  ErrorReporter get _errorReporter => _resolver.errorReporter;

  void resolve(
      AnnotationImpl node, List<WhyNotPromotedGetter> whyNotPromotedArguments) {
    node.typeArguments?.accept(_resolver);
    _resolve(node, whyNotPromotedArguments);
  }

  void _classConstructorInvocation(
    AnnotationImpl node,
    InterfaceElementImpl2 classElement,
    SimpleIdentifierImpl? constructorName,
    ArgumentListImpl argumentList,
    List<WhyNotPromotedGetter> whyNotPromotedArguments,
  ) {
    ConstructorElementMixin2? constructorElement;
    if (constructorName != null) {
      constructorElement = classElement.getNamedConstructor2(
        constructorName.name,
      );
    } else {
      constructorElement = classElement.unnamedConstructor2;
    }

    _constructorInvocation(
      node,
      classElement.name3!,
      constructorName,
      classElement.typeParameters2,
      constructorElement,
      argumentList,
      (typeArguments) {
        return classElement.instantiateImpl(
          typeArguments: typeArguments,
          nullabilitySuffix: NullabilitySuffix.none,
        );
      },
      whyNotPromotedArguments,
    );
  }

  void _classGetter(
    AnnotationImpl node,
    InterfaceElement2 classElement,
    SimpleIdentifierImpl? getterName,
    List<WhyNotPromotedGetter> whyNotPromotedArguments,
  ) {
    ExecutableElement2? getter;
    if (getterName != null) {
      getter = classElement.getGetter2(getterName.name);
      // Recovery, try to find a constructor.
      getter ??= classElement.getNamedConstructor2(getterName.name);
    } else {
      getter = classElement.unnamedConstructor2;
    }

    getterName?.element = getter;
    node.element2 = getter;

    if (getterName != null && getter is PropertyAccessorElement2) {
      _propertyAccessorElement(
          node, getterName, getter, whyNotPromotedArguments);
      _resolveAnnotationElementGetter(node, getter);
    } else if (getter is! ConstructorElement2) {
      _errorReporter.atNode(
        node,
        CompileTimeErrorCode.INVALID_ANNOTATION,
      );
    }

    _visitArguments(node, whyNotPromotedArguments,
        dataForTesting: _resolver.inferenceHelper.dataForTesting);
  }

  void _constructorInvocation(
    AnnotationImpl node,
    String typeDisplayName,
    SimpleIdentifierImpl? constructorName,
    List<TypeParameterElementImpl2> typeParameters,
    ConstructorElementMixin2? constructorElement,
    ArgumentListImpl argumentList,
    InterfaceType Function(List<TypeImpl> typeArguments) instantiateElement,
    List<WhyNotPromotedGetter> whyNotPromotedArguments,
  ) {
    constructorName?.element = constructorElement;
    node.element2 = constructorElement;

    if (constructorElement == null) {
      _errorReporter.atNode(
        node,
        CompileTimeErrorCode.INVALID_ANNOTATION,
      );
      AnnotationInferrer(
              resolver: _resolver,
              node: node,
              argumentList: argumentList,
              contextType: UnknownInferredType.instance,
              whyNotPromotedArguments: whyNotPromotedArguments,
              constructorName: constructorName)
          .resolveInvocation(rawType: null);
      return;
    }

    var elementToInfer = ConstructorElementToInfer(
      typeParameters,
      constructorElement,
    );
    var constructorRawType = elementToInfer.asType;

    AnnotationInferrer(
            resolver: _resolver,
            node: node,
            argumentList: argumentList,
            contextType: UnknownInferredType.instance,
            whyNotPromotedArguments: whyNotPromotedArguments,
            constructorName: constructorName)
        .resolveInvocation(
            // TODO(paulberry): eliminate this cast by changing the type of
            // `ConstructorElementToInfer.asType`.
            rawType: constructorRawType as FunctionTypeImpl);
  }

  void _extensionGetter(
    AnnotationImpl node,
    ExtensionElement2 extensionElement,
    SimpleIdentifierImpl? getterName,
    List<WhyNotPromotedGetter> whyNotPromotedArguments,
  ) {
    ExecutableElement2? getter;
    if (getterName != null) {
      getter = extensionElement.getGetter2(getterName.name);
    }

    getterName?.element = getter;
    node.element2 = getter;

    if (getterName != null && getter is PropertyAccessorElement2) {
      _propertyAccessorElement(
          node, getterName, getter, whyNotPromotedArguments);
      _resolveAnnotationElementGetter(node, getter);
    } else {
      _errorReporter.atNode(
        node,
        CompileTimeErrorCode.INVALID_ANNOTATION,
      );
    }

    _visitArguments(node, whyNotPromotedArguments,
        dataForTesting: _resolver.inferenceHelper.dataForTesting);
  }

  void _localVariable(
    AnnotationImpl node,
    VariableElement2 element,
    List<WhyNotPromotedGetter> whyNotPromotedArguments,
  ) {
    if (!element.isConst || node.arguments != null) {
      _errorReporter.atNode(
        node,
        CompileTimeErrorCode.INVALID_ANNOTATION,
      );
    }

    _visitArguments(node, whyNotPromotedArguments,
        dataForTesting: _resolver.inferenceHelper.dataForTesting);
  }

  void _propertyAccessorElement(
    AnnotationImpl node,
    SimpleIdentifierImpl name,
    PropertyAccessorElement2 element,
    List<WhyNotPromotedGetter> whyNotPromotedArguments,
  ) {
    name.element = element;
    node.element2 = element;

    _resolveAnnotationElementGetter(node, element);
    _visitArguments(node, whyNotPromotedArguments,
        dataForTesting: _resolver.inferenceHelper.dataForTesting);
  }

  void _resolve(
      AnnotationImpl node, List<WhyNotPromotedGetter> whyNotPromotedArguments) {
    SimpleIdentifierImpl name1;
    SimpleIdentifierImpl? name2;
    SimpleIdentifierImpl? name3;
    var nameNode = node.name;
    if (nameNode is PrefixedIdentifierImpl) {
      name1 = nameNode.prefix;
      name2 = nameNode.identifier;
      name3 = node.constructorName;
    } else {
      name1 = nameNode as SimpleIdentifierImpl;
      name2 = node.constructorName;
    }
    var argumentList = node.arguments;

    var element1 = name1.scopeLookupResult!.getter2;
    name1.element = element1;

    if (element1 == null) {
      _errorReporter.atNode(
        node,
        CompileTimeErrorCode.UNDEFINED_ANNOTATION,
        arguments: [name1.name],
      );
      _visitArguments(node, whyNotPromotedArguments,
          dataForTesting: _resolver.inferenceHelper.dataForTesting);
      return;
    }

    // Class(args) or Class.CONST
    if (element1 is InterfaceElementImpl2) {
      if (argumentList != null) {
        _classConstructorInvocation(
            node, element1, name2, argumentList, whyNotPromotedArguments);
      } else {
        _classGetter(node, element1, name2, whyNotPromotedArguments);
      }
      return;
    }

    // Extension.CONST
    if (element1 is ExtensionElement2) {
      _extensionGetter(node, element1, name2, whyNotPromotedArguments);
      return;
    }

    // prefix.*
    if (element1 is PrefixElement2) {
      if (name2 != null) {
        var element = element1.scope.lookup(name2.name).getter2;
        name2.element = element;
        // prefix.Class(args) or prefix.Class.CONST
        if (element is InterfaceElementImpl2) {
          if (element is ClassElement2 && argumentList != null) {
            _classConstructorInvocation(
                node, element, name3, argumentList, whyNotPromotedArguments);
          } else {
            _classGetter(node, element, name3, whyNotPromotedArguments);
          }
          return;
        }
        // prefix.Extension.CONST
        if (element is ExtensionElement2) {
          _extensionGetter(node, element, name3, whyNotPromotedArguments);
          return;
        }
        // prefix.CONST
        if (element is PropertyAccessorElement2) {
          _propertyAccessorElement(
              node, name2, element, whyNotPromotedArguments);
          return;
        }

        // prefix.TypeAlias(args) or prefix.TypeAlias.CONST
        if (element is TypeAliasElementImpl2) {
          var aliasedType = element.aliasedType;
          var argumentList = node.arguments;
          if (aliasedType is InterfaceTypeImpl && argumentList != null) {
            _typeAliasConstructorInvocation(node, element, name3, aliasedType,
                argumentList, whyNotPromotedArguments,
                dataForTesting: _resolver.inferenceHelper.dataForTesting);
          } else {
            _typeAliasGetter(node, element, name3, whyNotPromotedArguments);
          }
          return;
        }
        // undefined
        if (element == null) {
          _errorReporter.atNode(
            node,
            CompileTimeErrorCode.UNDEFINED_ANNOTATION,
            arguments: [name2.name],
          );
          _visitArguments(node, whyNotPromotedArguments,
              dataForTesting: _resolver.inferenceHelper.dataForTesting);
          return;
        }
      }
    }

    // CONST
    if (element1 is PropertyAccessorElement2) {
      _propertyAccessorElement(node, name1, element1, whyNotPromotedArguments);
      return;
    }

    // TypeAlias(args) or TypeAlias.CONST
    if (element1 is TypeAliasElementImpl2) {
      var aliasedType = element1.aliasedType;
      var argumentList = node.arguments;
      if (aliasedType is InterfaceTypeImpl && argumentList != null) {
        _typeAliasConstructorInvocation(node, element1, name2, aliasedType,
            argumentList, whyNotPromotedArguments,
            dataForTesting: _resolver.inferenceHelper.dataForTesting);
      } else {
        _typeAliasGetter(node, element1, name2, whyNotPromotedArguments);
      }
      return;
    }

    if (element1 is VariableElement2) {
      _localVariable(node, element1, whyNotPromotedArguments);
      return;
    }

    _errorReporter.atNode(
      node,
      CompileTimeErrorCode.INVALID_ANNOTATION,
    );

    _visitArguments(node, whyNotPromotedArguments,
        dataForTesting: _resolver.inferenceHelper.dataForTesting);
  }

  void _resolveAnnotationElementGetter(
      Annotation annotation, PropertyAccessorElement2 accessorElement) {
    // The accessor should be synthetic, the variable should be constant, and
    // there should be no arguments.
    var variableElement = accessorElement.variable3;
    if (variableElement == null) {
      return;
    }

    if (!accessorElement.isSynthetic ||
        !variableElement.isConst ||
        annotation.arguments != null) {
      _errorReporter.atNode(
        annotation,
        CompileTimeErrorCode.INVALID_ANNOTATION,
      );
    }
  }

  void _typeAliasConstructorInvocation(
      AnnotationImpl node,
      TypeAliasElementImpl2 typeAliasElement,
      SimpleIdentifierImpl? constructorName,
      InterfaceTypeImpl aliasedType,
      ArgumentListImpl argumentList,
      List<WhyNotPromotedGetter> whyNotPromotedArguments,
      {required TypeConstraintGenerationDataForTesting? dataForTesting}) {
    var constructorElement = aliasedType.lookUpConstructor2(
      constructorName?.name,
      _definingLibrary,
    );

    _constructorInvocation(
      node,
      typeAliasElement.name3!,
      constructorName,
      typeAliasElement.typeParameters2,
      constructorElement,
      argumentList,
      (typeArguments) {
        return typeAliasElement.instantiateImpl(
          typeArguments: typeArguments,
          nullabilitySuffix: NullabilitySuffix.none,
        ) as InterfaceType;
      },
      whyNotPromotedArguments,
    );
  }

  void _typeAliasGetter(
    AnnotationImpl node,
    TypeAliasElement2 typeAliasElement,
    SimpleIdentifierImpl? getterName,
    List<WhyNotPromotedGetter> whyNotPromotedArguments,
  ) {
    ExecutableElement2? getter;
    var aliasedType = typeAliasElement.aliasedType;
    if (aliasedType is InterfaceType) {
      var classElement = aliasedType.element3;
      if (getterName != null) {
        getter = classElement.getGetter2(getterName.name);
      }
    }

    getterName?.element = getter;
    node.element2 = getter;

    if (getterName != null && getter is PropertyAccessorElement2) {
      _propertyAccessorElement(
          node, getterName, getter, whyNotPromotedArguments);
      _resolveAnnotationElementGetter(node, getter);
    } else if (getter is! ConstructorElement2) {
      _errorReporter.atNode(
        node,
        CompileTimeErrorCode.INVALID_ANNOTATION,
      );
    }

    _visitArguments(node, whyNotPromotedArguments,
        dataForTesting: _resolver.inferenceHelper.dataForTesting);
  }

  void _visitArguments(
      AnnotationImpl node, List<WhyNotPromotedGetter> whyNotPromotedArguments,
      {required TypeConstraintGenerationDataForTesting? dataForTesting}) {
    var arguments = node.arguments;
    if (arguments != null) {
      AnnotationInferrer(
              resolver: _resolver,
              node: node,
              argumentList: arguments,
              contextType: UnknownInferredType.instance,
              whyNotPromotedArguments: whyNotPromotedArguments,
              constructorName: null)
          .resolveInvocation(rawType: null);
    }
  }
}
