// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// @docImport 'package:analyzer/dart/element/element2.dart';
library;

import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/listener.dart';
import 'package:analyzer/src/dart/ast/ast.dart';
import 'package:analyzer/src/dart/element/element.dart';
import 'package:analyzer/src/dart/element/member.dart';
import 'package:analyzer/src/dart/element/type.dart';
import 'package:analyzer/src/dart/element/type_constraint_gatherer.dart';
import 'package:analyzer/src/dart/element/type_system.dart';
import 'package:analyzer/src/dart/resolver/invocation_inferrer.dart';
import 'package:analyzer/src/generated/resolver.dart';
import 'package:analyzer/src/utilities/extensions/element.dart';

/// Information about a constructor element to instantiate.
///
/// If the target is a [ClassElement2], the [element] is a raw
/// [ConstructorElement2] from the class, and [typeParameters] are the
/// type parameters of the class.
///
/// If the target is a [TypeAliasElement2] with an [InterfaceType] as the
/// aliased type, the [element] is a [ConstructorMember] created from the
/// [ConstructorElement2] of the corresponding class, and substituting
/// the class type parameters with the type arguments specified in the alias,
/// explicit types or the type parameters of the alias. The [typeParameters]
/// are the type parameters of the alias.
class ConstructorElementToInfer {
  /// The type parameters used in [element].
  final List<TypeParameterElementImpl2> typeParameters2;

  /// The element, might be [ConstructorMember].
  final ConstructorElementMixin2 element2;

  ConstructorElementToInfer(this.typeParameters2, this.element2);

  /// Return the equivalent generic function type that we could use to
  /// forward to the constructor, or for a non-generic type simply returns
  /// the constructor type.
  ///
  /// For example given the type `class C<T> { C(T arg); }`, the generic
  /// function type is `<T>(T) -> C<T>`.
  FunctionType get asType {
    return typeParameters.isEmpty
        ? element.type
        : FunctionTypeImpl(
            typeFormals: typeParameters,
            parameters: element.parameters,
            returnType: element.returnType,
            nullabilitySuffix: NullabilitySuffix.none,
          );
  }

  ConstructorElementMixin get element => element2.asElement;

  List<TypeParameterElementImpl> get typeParameters {
    return typeParameters2.map((e) => e.asElement).toList();
  }
}

class InvocationInferenceHelper {
  final ResolverVisitor _resolver;
  final ErrorReporter _errorReporter;
  final TypeSystemImpl _typeSystem;
  final bool _genericMetadataIsEnabled;
  final TypeConstraintGenerationDataForTesting? dataForTesting;

  InvocationInferenceHelper({
    required ResolverVisitor resolver,
    required ErrorReporter errorReporter,
    required TypeSystemImpl typeSystem,
    required this.dataForTesting,
  })  : _resolver = resolver,
        _errorReporter = errorReporter,
        _typeSystem = typeSystem,
        _genericMetadataIsEnabled = resolver.definingLibrary.featureSet
            .isEnabled(Feature.generic_metadata);

  /// If the constructor referenced by the [constructorName] is generic,
  /// and the [constructorName] does not have explicit type arguments,
  /// return the element and type parameters to infer. Otherwise return `null`.
  ConstructorElementToInfer? constructorElementToInfer({
    required ConstructorName constructorName,
    required LibraryElementImpl definingLibrary,
  }) {
    List<TypeParameterElementImpl2> typeParameters;
    ConstructorElementMixin2? rawElement;

    var typeName = constructorName.type;
    var typeElement = typeName.element2;
    if (typeElement is InterfaceElementImpl2) {
      typeParameters = typeElement.typeParameters2;
      var constructorIdentifier = constructorName.name;
      if (constructorIdentifier == null) {
        rawElement = typeElement.unnamedConstructor2;
      } else {
        var name = constructorIdentifier.name;
        rawElement = typeElement.getNamedConstructor2(name);
        if (rawElement != null &&
            !rawElement.isAccessibleIn2(definingLibrary)) {
          rawElement = null;
        }
      }
    } else if (typeElement is TypeAliasElementImpl2) {
      typeParameters = typeElement.typeParameters2;
      var aliasedType = typeElement.aliasedType;
      if (aliasedType is InterfaceTypeImpl) {
        var constructorIdentifier = constructorName.name;
        rawElement = aliasedType.lookUpConstructor2(
          constructorIdentifier?.name,
          definingLibrary,
        );
      }
    } else {
      return null;
    }

    if (rawElement == null) {
      return null;
    }
    return ConstructorElementToInfer(typeParameters, rawElement);
  }

  /// Given an uninstantiated generic function type, referenced by the
  /// [identifier] in the tear-off [expression], try to infer the instantiated
  /// generic function type from the surrounding context.
  DartType inferTearOff(ExpressionImpl expression,
      SimpleIdentifierImpl identifier, DartType tearOffType,
      {required DartType contextType}) {
    if (contextType is FunctionTypeImpl && tearOffType is FunctionTypeImpl) {
      var typeArguments = _typeSystem.inferFunctionTypeInstantiation(
        contextType,
        tearOffType,
        errorReporter: _errorReporter,
        errorNode: expression,
        genericMetadataIsEnabled: _genericMetadataIsEnabled,
        inferenceUsingBoundsIsEnabled: _resolver.inferenceUsingBoundsIsEnabled,
        strictInference: _resolver.analysisOptions.strictInference,
        strictCasts: _resolver.analysisOptions.strictCasts,
        typeSystemOperations: _resolver.flowAnalysis.typeOperations,
        dataForTesting: dataForTesting,
        nodeForTesting: expression,
      );
      identifier.tearOffTypeArgumentTypes = typeArguments;
      if (typeArguments.isNotEmpty) {
        return tearOffType.instantiate(typeArguments);
      }
    }
    return tearOffType;
  }

  /// Finish resolution of the [DotShorthandInvocation].
  ///
  /// We have already found the invoked [ExecutableElement2], and the [rawType]
  /// is its not yet instantiated type. Here we perform downwards inference,
  /// resolution of arguments, and upwards inference.
  void resolveDotShorthandInvocation({
    required DotShorthandInvocationImpl node,
    required FunctionTypeImpl rawType,
    required List<WhyNotPromotedGetter> whyNotPromotedArguments,
    required TypeImpl contextType,
  }) {
    var returnType = DotShorthandInvocationInferrer(
      resolver: _resolver,
      node: node,
      argumentList: node.argumentList,
      contextType: contextType,
      whyNotPromotedArguments: whyNotPromotedArguments,
    ).resolveInvocation(rawType: rawType);
    node.recordStaticType(returnType, resolver: _resolver);
  }

  /// Finish resolution of the [MethodInvocation].
  ///
  /// We have already found the invoked [ExecutableElement2], and the [rawType]
  /// is its not yet instantiated type. Here we perform downwards inference,
  /// resolution of arguments, and upwards inference.
  void resolveMethodInvocation({
    required MethodInvocationImpl node,
    required FunctionTypeImpl rawType,
    required List<WhyNotPromotedGetter> whyNotPromotedArguments,
    required TypeImpl contextType,
  }) {
    var returnType = MethodInvocationInferrer(
      resolver: _resolver,
      node: node,
      argumentList: node.argumentList,
      contextType: contextType,
      whyNotPromotedArguments: whyNotPromotedArguments,
    ).resolveInvocation(rawType: rawType);
    node.recordStaticType(returnType, resolver: _resolver);
  }
}
