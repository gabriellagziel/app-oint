// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:_fe_analyzer_shared/src/base/errors.dart';
import 'package:_fe_analyzer_shared/src/deferred_function_literal_heuristic.dart';
import 'package:_fe_analyzer_shared/src/flow_analysis/flow_analysis.dart';
import 'package:_fe_analyzer_shared/src/types/shared_type.dart';
import 'package:analyzer/dart/ast/syntactic_entity.dart';
import 'package:analyzer/dart/element/element2.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/src/dart/ast/ast.dart';
import 'package:analyzer/src/dart/ast/extensions.dart';
import 'package:analyzer/src/dart/element/element.dart';
import 'package:analyzer/src/dart/element/generic_inferrer.dart';
import 'package:analyzer/src/dart/element/member.dart';
import 'package:analyzer/src/dart/element/type.dart';
import 'package:analyzer/src/dart/element/type_algebra.dart';
import 'package:analyzer/src/dart/element/type_schema.dart';
import 'package:analyzer/src/dart/element/type_system.dart';
import 'package:analyzer/src/error/codes.dart';
import 'package:analyzer/src/generated/inference_log.dart';
import 'package:analyzer/src/generated/resolver.dart';

Set<Object> _computeExplicitlyTypedParameterSet(
    FunctionExpression functionExpression) {
  List<FormalParameter> parameters =
      functionExpression.parameters?.parameters ?? const [];
  Set<Object> result = {};
  int unnamedParameterIndex = 0;
  for (var formalParameter in parameters) {
    var key = formalParameter.isNamed
        ? formalParameter.name?.lexeme ?? ''
        : unnamedParameterIndex++;
    if (formalParameter.isExplicitlyTyped) {
      result.add(key);
    }
  }
  return result;
}

/// Given an iterable of parameters, computes a map whose keys are either the
/// parameter name (for named parameters) or the zero-based integer index (for
/// unnamed parameters), and whose values are the parameters themselves.
Map<Object, FormalParameterElementMixin> _computeParameterMap(
    Iterable<FormalParameterElementMixin> parameters) {
  int unnamedParameterIndex = 0;
  return {
    for (var parameter in parameters)
      parameter.isNamed ? parameter.name3! : unnamedParameterIndex++: parameter
  };
}

/// Specialization of [InvocationInferrer] for performing type inference on AST
/// nodes of type [Annotation] that resolve to a constructor invocation.
class AnnotationInferrer extends FullInvocationInferrer<AnnotationImpl> {
  /// The identifier pointing to the constructor that's being invoked, or `null`
  /// if a constructor name couldn't be found (should only happen when
  /// recovering from errors).  If the constructor is generic, this identifier's
  /// static element will be updated to point to a [ConstructorMember] with type
  /// arguments filled in.
  final SimpleIdentifierImpl? constructorName;

  AnnotationInferrer(
      {required super.resolver,
      required super.node,
      required super.argumentList,
      required super.contextType,
      required super.whyNotPromotedArguments,
      required this.constructorName})
      : super._();

  @override
  bool get _isConst => true;

  @override
  bool get _isGenericInferenceDisabled => !resolver.genericMetadataIsEnabled;

  @override
  bool get _needsTypeArgumentBoundsCheck => true;

  @override
  TypeArgumentListImpl? get _typeArguments => node.typeArguments;

  @override
  ErrorCode get _wrongNumberOfTypeArgumentsErrorCode =>
      CompileTimeErrorCode.WRONG_NUMBER_OF_TYPE_ARGUMENTS;

  @override
  List<FormalParameterElement>? _storeResult(
      List<DartType>? typeArgumentTypes, FunctionType? invokeType) {
    if (invokeType != null) {
      var elementOrMember = node.element2 as ConstructorElementMixin2;
      var constructorElement = ConstructorMember.from2(
        elementOrMember.baseElement,
        invokeType.returnType as InterfaceType,
      );
      constructorName?.element = constructorElement;
      node.element2 = constructorElement;
      return constructorElement.formalParameters;
    }
    return null;
  }
}

/// Specialization of [InvocationInferrer] for performing type inference on AST
/// nodes of type [AugmentedInvocation].
class AugmentedInvocationInferrer
    extends FullInvocationInferrer<AugmentedInvocationImpl> {
  AugmentedInvocationInferrer({
    required super.resolver,
    required super.node,
    required super.argumentList,
    required super.contextType,
    required super.whyNotPromotedArguments,
  }) : super._();

  @override
  SyntacticEntity get _errorEntity {
    return node.augmentedKeyword;
  }

  @override
  bool get _needsTypeArgumentBoundsCheck => true;

  @override
  TypeArgumentListImpl? get _typeArguments => node.typeArguments;

  @override
  ErrorCode get _wrongNumberOfTypeArgumentsErrorCode =>
      CompileTimeErrorCode.WRONG_NUMBER_OF_TYPE_ARGUMENTS;
}

/// Specialization of [InvocationInferrer] for performing type inference on AST
/// nodes of type [DotShorthandInvocation].
class DotShorthandInvocationInferrer
    extends InvocationExpressionInferrer<DotShorthandInvocationImpl> {
  DotShorthandInvocationInferrer(
      {required super.resolver,
      required super.node,
      required super.argumentList,
      required super.contextType,
      required super.whyNotPromotedArguments})
      : super._();
}

/// Specialization of [InvocationInferrer] for performing type inference on AST
/// nodes that require full downward and upward inference.
abstract class FullInvocationInferrer<Node extends AstNodeImpl>
    extends InvocationInferrer<Node> {
  FullInvocationInferrer._(
      {required super.resolver,
      required super.node,
      required super.argumentList,
      required super.contextType,
      required super.whyNotPromotedArguments});

  SyntacticEntity get _errorEntity => node;

  bool get _isConst => false;

  bool get _isGenericInferenceDisabled => false;

  bool get _needsTypeArgumentBoundsCheck => false;

  TypeArgumentListImpl? get _typeArguments;

  ErrorCode get _wrongNumberOfTypeArgumentsErrorCode =>
      CompileTimeErrorCode.WRONG_NUMBER_OF_TYPE_ARGUMENTS_METHOD;

  @override
  DartType resolveInvocation({required FunctionTypeImpl? rawType}) {
    var typeArgumentList = _typeArguments;
    var originalType = rawType;

    List<TypeImpl>? typeArgumentTypes;
    GenericInferrer? inferrer;
    Substitution? substitution;
    if (_isGenericInferenceDisabled) {
      if (rawType != null && rawType.typeFormals.isNotEmpty) {
        typeArgumentTypes = List.filled(
          rawType.typeFormals.length,
          DynamicTypeImpl.instance,
        );
        substitution =
            Substitution.fromPairs2(rawType.typeParameters, typeArgumentTypes);
      } else {
        typeArgumentTypes = const <TypeImpl>[];
      }
    } else if (typeArgumentList != null) {
      if (rawType != null &&
          typeArgumentList.arguments.length != rawType.typeFormals.length) {
        var typeParameters = rawType.typeParameters;
        _reportWrongNumberOfTypeArguments(
            typeArgumentList, rawType, typeParameters);
        typeArgumentTypes = List.filled(
          typeParameters.length,
          DynamicTypeImpl.instance,
        );
      } else {
        typeArgumentTypes = typeArgumentList.arguments
            .map((typeArgument) => typeArgument.typeOrThrow)
            .toList(growable: true);
        if (rawType != null && _needsTypeArgumentBoundsCheck) {
          var typeParameters = rawType.typeParameters;
          var substitution = Substitution.fromPairs2(
            typeParameters,
            typeArgumentTypes,
          );
          for (var i = 0; i < typeParameters.length; i++) {
            var typeParameter = typeParameters[i];
            var bound = typeParameter.bound;
            if (bound != null) {
              bound = substitution.substituteType(bound);
              var typeArgument = typeArgumentTypes[i];
              if (!resolver.typeSystem.isSubtypeOf(typeArgument, bound)) {
                resolver.errorReporter.atNode(
                  typeArgumentList.arguments[i],
                  CompileTimeErrorCode.TYPE_ARGUMENT_NOT_MATCHING_BOUNDS,
                  arguments: [typeArgument, typeParameter.name3!, bound],
                );
              }
            }
          }
        }
      }

      if (rawType != null) {
        substitution =
            Substitution.fromPairs2(rawType.typeParameters, typeArgumentTypes);
      }
    } else if (rawType == null || rawType.typeFormals.isEmpty) {
      typeArgumentTypes = const <TypeImpl>[];
    } else {
      var typeParameters = [for (var tp in rawType.typeFormals) tp.element];
      rawType =
          getFreshTypeParameters2(typeParameters).applyToFunctionType(rawType);
      inferenceLogWriter?.enterGenericInference(
          rawType.typeParameters, rawType);

      inferrer = resolver.typeSystem.setupGenericTypeInference(
        typeParameters: rawType.typeParameters,
        declaredReturnType: rawType.returnType,
        contextReturnType: contextType,
        isConst: _isConst,
        errorReporter: resolver.errorReporter,
        errorEntity: _errorEntity,
        genericMetadataIsEnabled: resolver.genericMetadataIsEnabled,
        inferenceUsingBoundsIsEnabled: resolver.inferenceUsingBoundsIsEnabled,
        strictInference: resolver.analysisOptions.strictInference,
        strictCasts: resolver.analysisOptions.strictCasts,
        typeSystemOperations: resolver.flowAnalysis.typeOperations,
        dataForTesting: resolver.inferenceHelper.dataForTesting,
        nodeForTesting: node,
      );

      substitution = Substitution.fromPairs2(
          rawType.typeParameters, inferrer.choosePreliminaryTypes());
    }

    List<_IdenticalArgumentInfo?>? identicalArgumentInfo =
        _isIdentical ? [] : null;
    var parameterMap =
        _computeParameterMap(rawType?.formalParameters ?? const []);
    var deferredFunctionLiterals = _visitArguments(
        parameterMap: parameterMap,
        identicalArgumentInfo: identicalArgumentInfo,
        substitution: substitution,
        inferrer: inferrer);
    if (deferredFunctionLiterals != null) {
      bool isFirstStage = true;
      for (var stage in _FunctionLiteralDependencies(
              resolver.typeSystem,
              deferredFunctionLiterals,
              rawType?.typeParameters.toSet() ?? const {},
              _computeUndeferredParamInfo(
                  rawType, parameterMap, deferredFunctionLiterals))
          .planReconciliationStages()) {
        if (inferrer != null && !isFirstStage) {
          substitution = Substitution.fromPairs2(
              rawType!.typeParameters, inferrer.choosePreliminaryTypes());
        }
        _resolveDeferredFunctionLiterals(
            deferredFunctionLiterals: stage,
            identicalArgumentInfo: identicalArgumentInfo,
            substitution: substitution,
            inferrer: inferrer);
        isFirstStage = false;
      }
    }

    if (inferrer != null) {
      typeArgumentTypes = inferrer.chooseFinalTypes();
    }
    FunctionTypeImpl? invokeType = typeArgumentTypes != null
        ? originalType?.instantiate(typeArgumentTypes)
        : originalType;

    var parameters = _storeResult(typeArgumentTypes, invokeType);
    if (parameters != null) {
      argumentList.correspondingStaticParameters2 =
          ResolverVisitor.resolveArgumentsToParameters(
        argumentList: argumentList,
        formalParameters: parameters,
        errorReporter: resolver.errorReporter,
      );
    }
    var returnType = _refineReturnType(
        InvocationInferrer.computeInvokeReturnType(invokeType));
    _recordIdenticalArgumentInfo(identicalArgumentInfo);
    return returnType;
  }

  /// Computes a list of [_ParamInfo] objects corresponding to the invocation
  /// parameters that were *not* deferred.
  List<_ParamInfo> _computeUndeferredParamInfo(
      FunctionType? rawType,
      Map<Object, FormalParameterElementMixin> parameterMap,
      List<_DeferredParamInfo> deferredFunctionLiterals) {
    if (rawType == null) return const [];
    var parameterKeysAlreadyCovered = {
      for (var functionLiteral in deferredFunctionLiterals)
        functionLiteral.parameterKey
    };
    return [
      for (var entry in parameterMap.entries)
        if (!parameterKeysAlreadyCovered.contains(entry.key))
          _ParamInfo(entry.value)
    ];
  }

  TypeImpl _refineReturnType(TypeImpl returnType) => returnType;

  void _reportWrongNumberOfTypeArguments(TypeArgumentList typeArgumentList,
      FunctionType rawType, List<TypeParameterElement2> typeParameters) {
    resolver.errorReporter.atNode(
      typeArgumentList,
      _wrongNumberOfTypeArgumentsErrorCode,
      arguments: [
        rawType,
        typeParameters.length,
        typeArgumentList.arguments.length,
      ],
    );
  }

  List<FormalParameterElement>? _storeResult(
      List<TypeImpl>? typeArgumentTypes, FunctionTypeImpl? invokeType) {
    return invokeType?.formalParameters;
  }
}

/// Specialization of [InvocationInferrer] for performing type inference on AST
/// nodes of type [FunctionExpressionInvocation].
class FunctionExpressionInvocationInferrer
    extends InvocationExpressionInferrer<FunctionExpressionInvocationImpl> {
  FunctionExpressionInvocationInferrer(
      {required super.resolver,
      required super.node,
      required super.argumentList,
      required super.contextType,
      required super.whyNotPromotedArguments})
      : super._();

  @override
  ExpressionImpl get _errorEntity => node.function;
}

/// Specialization of [InvocationInferrer] for performing type inference on AST
/// nodes of type [InstanceCreationExpression].
class InstanceCreationInferrer
    extends FullInvocationInferrer<InstanceCreationExpressionImpl> {
  InstanceCreationInferrer(
      {required super.resolver,
      required super.node,
      required super.argumentList,
      required super.contextType,
      required super.whyNotPromotedArguments})
      : super._();

  @override
  ConstructorNameImpl get _errorEntity => node.constructorName;

  @override
  bool get _isConst => node.isConst;

  @override
  bool get _needsTypeArgumentBoundsCheck => true;

  @override
  TypeArgumentListImpl? get _typeArguments {
    // For an instance creation expression the type arguments are on the
    // constructor name.
    return node.constructorName.type.typeArguments;
  }

  @override
  void _reportWrongNumberOfTypeArguments(TypeArgumentList typeArgumentList,
      FunctionType rawType, List<TypeParameterElement2> typeParameters) {
    // Error reporting for instance creations is done elsewhere.
  }

  @override
  List<FormalParameterElement>? _storeResult(
      List<DartType>? typeArgumentTypes, FunctionTypeImpl? invokeType) {
    if (invokeType != null) {
      var constructedType = invokeType.returnType;
      node.constructorName.type.type = constructedType;
      var constructorElement = ConstructorMember.from2(
        node.constructorName.element!.baseElement,
        constructedType as InterfaceType,
      );
      node.constructorName.element = constructorElement;
      return constructorElement.formalParameters;
    }
    return null;
  }
}

/// Specialization of [InvocationInferrer] for performing type inference on AST
/// nodes derived from [InvocationExpression].
abstract class InvocationExpressionInferrer<
        Node extends InvocationExpressionImpl>
    extends FullInvocationInferrer<Node> {
  InvocationExpressionInferrer._(
      {required super.resolver,
      required super.node,
      required super.argumentList,
      required super.contextType,
      required super.whyNotPromotedArguments})
      : super._();

  @override
  Expression get _errorEntity => node.function;

  @override
  TypeArgumentListImpl? get _typeArguments => node.typeArguments;

  @override
  List<FormalParameterElement>? _storeResult(
      List<TypeImpl>? typeArgumentTypes, FunctionTypeImpl? invokeType) {
    node.typeArgumentTypes = typeArgumentTypes;
    node.staticInvokeType = invokeType ?? DynamicTypeImpl.instance;
    return super._storeResult(typeArgumentTypes, invokeType);
  }
}

/// Base class containing functionality for performing type inference on AST
/// nodes that invoke a method, function, or constructor.
///
/// This class may be used directly for inference of [ExtensionOverride],
/// [RedirectingConstructorInvocation], or [SuperConstructorInvocation].
class InvocationInferrer<Node extends AstNodeImpl> {
  final ResolverVisitor resolver;
  final Node node;
  final ArgumentListImpl argumentList;
  final TypeImpl contextType;
  final List<WhyNotPromotedGetter> whyNotPromotedArguments;

  /// Prepares to perform type inference on an invocation expression of type
  /// [Node].
  InvocationInferrer(
      {required this.resolver,
      required this.node,
      required this.argumentList,
      required this.contextType,
      required this.whyNotPromotedArguments});

  /// Determines whether [node] is an invocation of the core function
  /// `identical` (which needs special flow analysis treatment).
  bool get _isIdentical => false;

  /// Performs type inference on the invocation expression.  [rawType] should be
  /// the type of the function the invocation is resolved to (with type
  /// arguments not applied yet).
  void resolveInvocation({required FunctionTypeImpl? rawType}) {
    var deferredFunctionLiterals = _visitArguments(
        parameterMap:
            _computeParameterMap(rawType?.formalParameters ?? const []));
    if (deferredFunctionLiterals != null) {
      _resolveDeferredFunctionLiterals(
          deferredFunctionLiterals: deferredFunctionLiterals);
    }
  }

  /// Computes the type context that should be used when evaluating a particular
  /// argument of the invocation.  Usually this is just the type of the
  /// corresponding parameter, but it can be different for certain primitive
  /// numeric operations.
  TypeImpl _computeContextForArgument(TypeImpl parameterType) => parameterType;

  /// If the invocation being processed is a call to `identical`, informs flow
  /// analysis about it, so that it can do appropriate promotions.
  void _recordIdenticalArgumentInfo(
      List<_IdenticalArgumentInfo?>? identicalArgumentInfo) {
    var flow = resolver.flowAnalysis.flow;
    if (identicalArgumentInfo != null) {
      var leftOperandInfo = identicalArgumentInfo[0]!;
      var rightOperandInfo = identicalArgumentInfo[1]!;
      flow?.equalityOperation_end(
          argumentList.parent as ExpressionImpl,
          leftOperandInfo.expressionInfo,
          SharedTypeView(leftOperandInfo.staticType),
          rightOperandInfo.expressionInfo,
          SharedTypeView(rightOperandInfo.staticType));
    }
  }

  /// Resolves any function literals that were deferred by [_visitArguments].
  void _resolveDeferredFunctionLiterals(
      {required List<_DeferredParamInfo> deferredFunctionLiterals,
      List<_IdenticalArgumentInfo?>? identicalArgumentInfo,
      Substitution? substitution,
      GenericInferrer? inferrer}) {
    var flow = resolver.flowAnalysis.flow;
    var arguments = argumentList.arguments;
    for (var deferredArgument in deferredFunctionLiterals) {
      var parameter = deferredArgument.parameter;
      TypeImpl parameterContextType;
      if (parameter != null) {
        var parameterType = parameter.type;
        if (substitution != null) {
          parameterType = substitution.substituteType(parameterType);
        }
        parameterContextType = _computeContextForArgument(parameterType);
      } else {
        parameterContextType = UnknownInferredType.instance;
      }
      var argument = arguments[deferredArgument.index];
      resolver.analyzeExpression(
          argument, SharedTypeSchemaView(parameterContextType));
      argument = resolver.popRewrite()!;
      if (flow != null) {
        identicalArgumentInfo?[deferredArgument.index] = _IdenticalArgumentInfo(
            expressionInfo: flow.equalityOperand_end(argument),
            staticType: argument.typeOrThrow);
      }
      if (parameter != null) {
        inferrer?.constrainArgument(
            argument.typeOrThrow, parameter.type, parameter.name3!,
            nodeForTesting: node);
      }
    }
  }

  /// Visits [argumentList], resolving each argument.  If any arguments need to
  /// be deferred due to the `inference-update-1` feature, a list of them is
  /// returned.
  List<_DeferredParamInfo>? _visitArguments(
      {required Map<Object, FormalParameterElementMixin> parameterMap,
      List<_IdenticalArgumentInfo?>? identicalArgumentInfo,
      Substitution? substitution,
      GenericInferrer? inferrer}) {
    assert(whyNotPromotedArguments.isEmpty);
    List<_DeferredParamInfo>? deferredFunctionLiterals;
    resolver.checkUnreachableNode(argumentList);
    var flow = resolver.flowAnalysis.flow;
    var unnamedArgumentIndex = 0;
    var arguments = argumentList.arguments;
    for (int i = 0; i < arguments.length; i++) {
      var argument = arguments[i];
      Expression value;
      FormalParameterElementMixin? parameter;
      Object parameterKey;
      if (argument is NamedExpressionImpl) {
        value = argument.expression;
        parameterKey = argument.name.label.name;
      } else {
        value = argument;
        parameterKey = unnamedArgumentIndex++;
      }
      value = value.unParenthesized;
      parameter = parameterMap[parameterKey];
      if (resolver.isInferenceUpdate1Enabled &&
          value is FunctionExpressionImpl) {
        (deferredFunctionLiterals ??= [])
            .add(_DeferredParamInfo(parameter, value, i, parameterKey));
        identicalArgumentInfo?.add(null);
        // The "why not promoted" arguments list isn't really relevant for
        // function literals because promoting a function literal doesn't even
        // make sense.  So we store an innocuous value in the list.
        whyNotPromotedArguments.add(() => const {});
      } else {
        TypeImpl parameterContextType;
        if (parameter != null) {
          var parameterType = parameter.type;
          if (substitution != null) {
            parameterType = substitution.substituteType(parameterType);
          }
          parameterContextType = _computeContextForArgument(parameterType);
        } else {
          parameterContextType = UnknownInferredType.instance;
        }
        resolver.analyzeExpression(
            argument, SharedTypeSchemaView(parameterContextType));
        argument = resolver.popRewrite()!;
        if (flow != null) {
          identicalArgumentInfo?.add(_IdenticalArgumentInfo(
              expressionInfo: flow.equalityOperand_end(argument),
              staticType: argument.typeOrThrow));
          whyNotPromotedArguments.add(flow.whyNotPromoted(argument));
        }
        if (parameter != null) {
          inferrer?.constrainArgument(
              argument.typeOrThrow, parameter.type, parameter.name3!,
              nodeForTesting: node);
        }
      }
    }
    return deferredFunctionLiterals;
  }

  /// Computes the return type of the method or function represented by the
  /// given type that is being invoked.
  static TypeImpl computeInvokeReturnType(DartType? type) {
    if (type is FunctionTypeImpl) {
      return type.returnType;
    } else {
      return DynamicTypeImpl.instance;
    }
  }
}

/// Specialization of [InvocationInferrer] for performing type inference on AST
/// nodes of type [MethodInvocation].
class MethodInvocationInferrer
    extends InvocationExpressionInferrer<MethodInvocationImpl> {
  MethodInvocationInferrer(
      {required super.resolver,
      required super.node,
      required super.argumentList,
      required super.contextType,
      required super.whyNotPromotedArguments})
      : super._();

  @override
  bool get _isIdentical {
    var invokedMethod = node.methodName.element;
    return invokedMethod is TopLevelFunctionElement &&
        invokedMethod.isDartCoreIdentical &&
        node.argumentList.arguments.length == 2;
  }

  @override
  TypeImpl _computeContextForArgument(TypeImpl parameterType) {
    var argumentContextType = super._computeContextForArgument(parameterType);
    var targetType = node.realTarget?.staticType;
    if (targetType != null) {
      argumentContextType = resolver.typeSystem.refineNumericInvocationContext2(
          targetType, node.methodName.element, contextType, parameterType);
    }
    return argumentContextType;
  }

  @override
  TypeImpl _refineReturnType(TypeImpl returnType) {
    var targetType = node.realTarget?.staticType;
    if (targetType != null) {
      returnType = resolver.typeSystem.refineNumericInvocationType(
        targetType,
        node.methodName.element,
        [
          for (var argument in node.argumentList.arguments) argument.typeOrThrow
        ],
        returnType,
      );
    }
    return returnType;
  }
}

/// Information about an invocation argument that needs to be resolved later due
/// to the fact that it's a function literal and the `inference-update-1`
/// feature is enabled.
class _DeferredParamInfo extends _ParamInfo {
  /// The function literal expression.
  final FunctionExpression value;

  /// The index into the argument list of the function literal expression.
  final int index;

  final Object parameterKey;

  _DeferredParamInfo(
      super.parameter, this.value, this.index, this.parameterKey);
}

class _FunctionLiteralDependencies extends FunctionLiteralDependencies<
    TypeParameterElement2, _ParamInfo, _DeferredParamInfo> {
  final TypeSystemImpl _typeSystem;

  final Set<TypeParameterElement2> _typeVariables;

  _FunctionLiteralDependencies(
      this._typeSystem,
      Iterable<_DeferredParamInfo> deferredParamInfo,
      this._typeVariables,
      List<_ParamInfo> undeferredParamInfo)
      : super(deferredParamInfo, _typeVariables, undeferredParamInfo);

  @override
  Iterable<TypeParameterElement2> typeVarsFreeInParamParams(
      _DeferredParamInfo paramInfo) {
    var type = paramInfo.parameter?.type;
    if (type is FunctionTypeImpl) {
      var parameterMap = _computeParameterMap(type.formalParameters);
      var explicitlyTypedParameters =
          _computeExplicitlyTypedParameterSet(paramInfo.value);
      Set<TypeParameterElement2> result = {};
      for (var entry in parameterMap.entries) {
        if (explicitlyTypedParameters.contains(entry.key)) continue;
        result.addAll(_typeSystem.getFreeParameters2(entry.value.type,
                candidates: _typeVariables) ??
            const []);
      }
      return result;
    } else {
      return const [];
    }
  }

  @override
  Iterable<TypeParameterElement2> typeVarsFreeInParamReturns(
      _ParamInfo paramInfo) {
    var type = paramInfo.parameter?.type;
    if (type is FunctionTypeImpl) {
      return _typeSystem.getFreeParameters2(type.returnType,
              candidates: _typeVariables) ??
          const [];
    } else if (type != null) {
      return _typeSystem.getFreeParameters2(type, candidates: _typeVariables) ??
          const [];
    } else {
      return const [];
    }
  }
}

/// Information tracked by [InvocationInferrer] about an argument passed to the
/// `identical` function in `dart:core`.
class _IdenticalArgumentInfo {
  /// The [ExpressionInfo] returned by [FlowAnalysis.equalityOperand_end] for
  /// the argument.
  final ExpressionInfo<SharedTypeView>? expressionInfo;

  /// The static type of the argument.
  final TypeImpl staticType;

  _IdenticalArgumentInfo(
      {required this.expressionInfo, required this.staticType});
}

/// Information about an invocation argument that may or may not have already
/// been resolved, as part of the deferred resolution mechanism for the
/// `inference-update-1` feature.
class _ParamInfo {
  /// The function parameter corresponding to the argument, or `null` if we are
  /// resolving a dynamic invocation.
  final FormalParameterElementMixin? parameter;

  _ParamInfo(this.parameter);
}
