// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:_fe_analyzer_shared/src/type_inference/type_analyzer_operations.dart';
import 'package:analyzer/dart/element/element2.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/src/dart/ast/ast.dart';
import 'package:analyzer/src/dart/ast/extensions.dart';
import 'package:analyzer/src/dart/element/element.dart';
import 'package:analyzer/src/dart/element/replacement_visitor.dart';
import 'package:analyzer/src/dart/element/type.dart';
import 'package:analyzer/src/summary2/function_type_builder.dart';
import 'package:analyzer/src/summary2/link.dart';
import 'package:analyzer/src/summary2/named_type_builder.dart';
import 'package:analyzer/src/summary2/type_builder.dart';
import 'package:analyzer/src/util/graph.dart';

class DefaultTypesBuilder {
  final Linker _linker;

  DefaultTypesBuilder(this._linker);

  void build(List<AstNode> nodes) {
    for (var node in nodes) {
      if (node is ClassDeclarationImpl) {
        var element = node.declaredFragment!.element;
        _breakSelfCycles(node.typeParameters);
        _breakRawTypeCycles(element, node.typeParameters);
        _computeBounds(element, node.typeParameters);
      } else if (node is ClassTypeAliasImpl) {
        var element = node.declaredFragment!.element;
        _breakSelfCycles(node.typeParameters);
        _breakRawTypeCycles(element, node.typeParameters);
        _computeBounds(element, node.typeParameters);
      } else if (node is EnumDeclarationImpl) {
        var element = node.declaredFragment!.element;
        _breakSelfCycles(node.typeParameters);
        _breakRawTypeCycles(element, node.typeParameters);
        _computeBounds(element, node.typeParameters);
      } else if (node is ExtensionDeclarationImpl) {
        var element = node.declaredFragment!.element;
        _breakSelfCycles(node.typeParameters);
        _breakRawTypeCycles(element, node.typeParameters);
        _computeBounds(element, node.typeParameters);
      } else if (node is ExtensionTypeDeclarationImpl) {
        var element = node.declaredFragment!.element;
        _breakSelfCycles(node.typeParameters);
        _breakRawTypeCycles(element, node.typeParameters);
        _computeBounds(element, node.typeParameters);
      } else if (node is FunctionTypeAliasImpl) {
        var element = node.declaredFragment!.element;
        _breakSelfCycles(node.typeParameters);
        _breakRawTypeCycles(element, node.typeParameters);
        _computeBounds(element, node.typeParameters);
      } else if (node is GenericTypeAliasImpl) {
        var element = node.declaredFragment!.element;
        _breakSelfCycles(node.typeParameters);
        _breakRawTypeCycles(element, node.typeParameters);
        _computeBounds(element, node.typeParameters);
      } else if (node is MixinDeclarationImpl) {
        var element = node.declaredFragment!.element;
        _breakSelfCycles(node.typeParameters);
        _breakRawTypeCycles(element, node.typeParameters);
        _computeBounds(element, node.typeParameters);
      } else if (node is MethodDeclarationImpl) {
        var element = node.declaredFragment!.element;
        _breakSelfCycles(node.typeParameters);
        _breakRawTypeCycles(element, node.typeParameters);
        _computeBounds(element, node.typeParameters);
      } else if (node is FunctionDeclarationImpl) {
        var element = node.declaredFragment!.element;
        _breakSelfCycles(node.functionExpression.typeParameters);
        _breakRawTypeCycles(element, node.functionExpression.typeParameters);
        _computeBounds(element, node.functionExpression.typeParameters);
      }
    }
    for (var node in nodes) {
      if (node is ClassDeclarationImpl) {
        _build(node.typeParameters);
      } else if (node is ClassTypeAliasImpl) {
        _build(node.typeParameters);
      } else if (node is EnumDeclarationImpl) {
        _build(node.typeParameters);
      } else if (node is ExtensionDeclarationImpl) {
        _build(node.typeParameters);
      } else if (node is ExtensionTypeDeclarationImpl) {
        _build(node.typeParameters);
      } else if (node is FunctionTypeAliasImpl) {
        _build(node.typeParameters);
      } else if (node is GenericTypeAliasImpl) {
        _build(node.typeParameters);
      } else if (node is MixinDeclarationImpl) {
        _build(node.typeParameters);
      } else if (node is FunctionDeclarationImpl) {
        _build(node.functionExpression.typeParameters);
      } else if (node is MethodDeclarationImpl) {
        _build(node.typeParameters);
      }
    }
  }

  void _breakRawTypeCycles(
    Element2 declarationElement,
    TypeParameterList? parameterList,
  ) {
    if (parameterList == null) return;

    var allCycles = <List<_CycleElement>>[];
    for (var parameter in parameterList.typeParameters) {
      var boundNode = parameter.bound;
      if (boundNode == null) continue;

      var cycles = _findRawTypePathsToDeclaration(
        parameter,
        boundNode.typeOrThrow,
        declarationElement,
        Set<Element2>.identity(),
      );
      allCycles.addAll(cycles);
    }

    for (var cycle in allCycles) {
      for (var element in cycle) {
        var boundNode = element.parameter.bound;
        if (boundNode is GenericFunctionTypeImpl) {
          boundNode.type = DynamicTypeImpl.instance;
        } else if (boundNode is NamedTypeImpl) {
          boundNode.type = DynamicTypeImpl.instance;
        } else {
          throw UnimplementedError('(${boundNode.runtimeType}) $boundNode');
        }
      }
    }
  }

  void _breakSelfCycles(TypeParameterList? parameterList) {
    if (parameterList == null) return;
    var typeParameters = parameterList.typeParameters;

    Map<String, TypeParameter>? typeParametersByName;
    for (var parameter in typeParameters) {
      parameter as TypeParameterImpl;
      var boundNode = parameter.bound;
      if (boundNode is NamedTypeImpl) {
        if (typeParametersByName == null) {
          typeParametersByName = {};
          for (var parameterNode in typeParameters) {
            var name = parameterNode.name.lexeme;
            typeParametersByName[name] = parameterNode;
          }
        }

        TypeParameter? current = parameter;
        for (var step = 0;
            current != null && step < typeParameters.length;
            ++step) {
          var bound = current.bound;
          if (bound is NamedType) {
            if (bound.importPrefix == null) {
              current = typeParametersByName[bound.name2.lexeme];
              continue;
            }
          }
          current = null;
          break;
        }

        if (current != null) {
          boundNode.type = DynamicTypeImpl.instance;
        }
      }
    }
  }

  /// Build actual default type [DartType]s from computed [TypeBuilder]s.
  void _build(TypeParameterListImpl? parameterList) {
    if (parameterList == null) return;

    for (var parameter in parameterList.typeParameters) {
      var element = parameter.declaredFragment!;
      var defaultType = element.defaultType;
      if (defaultType is TypeBuilder) {
        var builtType = defaultType.build();
        element.defaultType = builtType;
      }
    }
  }

  /// Compute bounds to be provided as type arguments in place of missing type
  /// arguments on raw types with the given type parameters.
  void _computeBounds(
    Element2 declarationElement,
    TypeParameterListImpl? parameterList,
  ) {
    if (parameterList == null) return;

    var dynamicType = DynamicTypeImpl.instance;
    var bottomType = NeverTypeImpl.instance;

    var nodes = parameterList.typeParameters;
    var length = nodes.length;
    var elements = <TypeParameterElementImpl2>[];
    var bounds = <TypeImpl>[];
    for (int i = 0; i < length; i++) {
      var node = nodes[i];
      elements.add(node.declaredFragment!.element);
      bounds.add(node.bound?.type ?? dynamicType);
    }

    var graph = _TypeParametersGraph(elements, bounds);
    var stronglyConnected = computeStrongComponents(graph);
    for (var component in stronglyConnected) {
      var dynamicSubstitution = <TypeParameterElement2, TypeImpl>{};
      var nullSubstitution = <TypeParameterElement2, TypeImpl>{};
      for (var i in component) {
        var element = elements[i];
        dynamicSubstitution[element] = dynamicType;
        nullSubstitution[element] = bottomType;
      }

      for (var i in component) {
        var variable = elements[i];
        var visitor = _UpperLowerReplacementVisitor(
          upper: dynamicSubstitution,
          lower: nullSubstitution,
          variance: variable.variance,
        );
        bounds[i] = visitor.run(bounds[i]);
      }
    }

    for (var i = 0; i < length; i++) {
      var thisSubstitution = <TypeParameterElement2, TypeImpl>{};
      var nullSubstitution = <TypeParameterElement2, TypeImpl>{};
      var element = elements[i];
      thisSubstitution[element] = bounds[i];
      nullSubstitution[element] = bottomType;

      for (var j = 0; j < length; j++) {
        var variable = elements[j];
        var visitor = _UpperLowerReplacementVisitor(
          upper: thisSubstitution,
          lower: nullSubstitution,
          variance: variable.variance,
        );
        bounds[j] = visitor.run(bounds[j]);
      }
    }

    // Set computed TypeBuilder(s) as default types.
    for (var i = 0; i < length; i++) {
      var element = nodes[i].declaredFragment!;
      element.defaultType = bounds[i];
    }
  }

  /// Finds raw type paths starting with the [startParameter] and a
  /// [startType] that is used in its bound, and ending with [end].
  List<List<_CycleElement>> _findRawTypePathsToDeclaration(
    TypeParameter startParameter,
    DartType startType,
    Element2 end,
    Set<Element2> visited,
  ) {
    var paths = <List<_CycleElement>>[];
    if (startType is NamedTypeBuilder) {
      var declaration = startType.element3;
      if (startType.arguments.isEmpty) {
        if (startType.element3 == end) {
          paths.add([
            _CycleElement(startParameter, startType),
          ]);
        } else if (visited.add(startType.element3)) {
          void recurseParameters(List<TypeParameterElement2> parameters) {
            for (var parameter in parameters) {
              var parameterNode =
                  _linker.getLinkingNode2(parameter.firstFragment);
              if (parameterNode is TypeParameter) {
                var bound = parameterNode.bound;
                if (bound != null) {
                  var tails = _findRawTypePathsToDeclaration(
                    parameterNode,
                    bound.typeOrThrow,
                    end,
                    visited,
                  );
                  for (var tail in tails) {
                    paths.add(<_CycleElement>[
                      _CycleElement(startParameter, startType),
                      ...tail,
                    ]);
                  }
                }
              }
            }
          }

          if (declaration is InterfaceElement2) {
            recurseParameters(declaration.typeParameters2);
          } else if (declaration is TypeAliasElement2) {
            recurseParameters(declaration.typeParameters2);
          }
          visited.remove(startType.element3);
        }
      } else {
        for (var argument in startType.arguments) {
          paths.addAll(
            _findRawTypePathsToDeclaration(
              startParameter,
              argument,
              end,
              visited,
            ),
          );
        }
      }
    } else if (startType is FunctionTypeBuilder) {
      paths.addAll(
        _findRawTypePathsToDeclaration(
          startParameter,
          startType.returnType,
          end,
          visited,
        ),
      );
      for (var typeParameter in startType.typeParameters) {
        var bound = typeParameter.bound;
        if (bound != null) {
          paths.addAll(
            _findRawTypePathsToDeclaration(
              startParameter,
              bound,
              end,
              visited,
            ),
          );
        }
      }
      for (var formalParameter in startType.formalParameters) {
        paths.addAll(
          _findRawTypePathsToDeclaration(
            startParameter,
            formalParameter.type,
            end,
            visited,
          ),
        );
      }
    }
    return paths;
  }
}

class _CycleElement {
  final TypeParameter parameter;
  final DartType type;

  _CycleElement(this.parameter, this.type);
}

/// Graph of mutual dependencies of type parameters from the same declaration.
/// Type parameters are represented by their indices in the corresponding
/// declaration.
class _TypeParametersGraph implements Graph<int> {
  @override
  final List<int> vertices = [];

  // Each `edges[i]` is the list of indices of type parameters that reference
  // the type parameter with the index `i` in their bounds.
  final List<List<int>> _edges = [];

  final Map<TypeParameterElement2, int> _parameterToIndex = Map.identity();

  _TypeParametersGraph(
    List<TypeParameterElement2> parameters,
    List<DartType> bounds,
  ) {
    assert(parameters.length == bounds.length);

    for (int i = 0; i < parameters.length; i++) {
      vertices.add(i);
      _edges.add(<int>[]);
      _parameterToIndex[parameters[i]] = i;
    }

    for (int i = 0; i < vertices.length; i++) {
      _collectReferencesFrom(i, bounds[i]);
    }
  }

  /// Return type parameters that depend on the [index]th type parameter.
  @override
  Iterable<int> neighborsOf(int index) {
    return _edges[index];
  }

  /// Collect references to the [index]th type parameter from the [type].
  void _collectReferencesFrom(int index, DartType? type) {
    if (type is FunctionTypeBuilder) {
      for (var parameter in type.typeParameters) {
        _collectReferencesFrom(index, parameter.bound);
      }
      for (var parameter in type.formalParameters) {
        _collectReferencesFrom(index, parameter.type);
      }
      _collectReferencesFrom(index, type.returnType);
    } else if (type is NamedTypeBuilder) {
      for (var argument in type.arguments) {
        _collectReferencesFrom(index, argument);
      }
    } else if (type is TypeParameterType) {
      var typeIndex = _parameterToIndex[type.element3];
      if (typeIndex != null) {
        _edges[typeIndex].add(index);
      }
    }
  }
}

class _UpperLowerReplacementVisitor extends ReplacementVisitor {
  final Map<TypeParameterElement2, TypeImpl> _upper;
  final Map<TypeParameterElement2, TypeImpl> _lower;
  Variance _variance;

  _UpperLowerReplacementVisitor({
    required Map<TypeParameterElement2, TypeImpl> upper,
    required Map<TypeParameterElement2, TypeImpl> lower,
    required Variance variance,
  })  : _upper = upper,
        _lower = lower,
        _variance = variance;

  @override
  void changeVariance() {
    if (_variance == Variance.covariant) {
      _variance = Variance.contravariant;
    } else if (_variance == Variance.contravariant) {
      _variance = Variance.covariant;
    }
  }

  TypeImpl run(TypeImpl type) {
    return type.accept(this) ?? type;
  }

  @override
  TypeImpl? visitTypeArgument(
    TypeParameterElementImpl2 parameter,
    TypeImpl argument,
  ) {
    var savedVariance = _variance;
    try {
      _variance = _variance.combine(parameter.variance);
      return super.visitTypeArgument(parameter, argument);
    } finally {
      _variance = savedVariance;
    }
  }

  @override
  TypeImpl? visitTypeParameterType(TypeParameterType type) {
    if (_variance == Variance.contravariant) {
      return _lower[type.element3];
    } else {
      return _upper[type.element3];
    }
  }
}
