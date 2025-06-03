// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:typed_data';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element2.dart';
import 'package:analyzer/src/dart/ast/ast.dart';
import 'package:analyzer/src/dart/element/element.dart';
import 'package:analyzer/src/fine/manifest_context.dart';
import 'package:analyzer/src/summary2/data_reader.dart';
import 'package:analyzer/src/summary2/data_writer.dart';
import 'package:analyzer/src/utilities/extensions/collection.dart';
import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

@visibleForTesting
enum ManifestAstElementKind {
  null_,
  dynamic_,
  formalParameter,
  importPrefix,
  typeParameter,
  regular;

  static final _bitCount = values.length.bitLength;
  static final _bitMask = (1 << _bitCount) - 1;

  int encodeRawIndex(int rawIndex) {
    assert(rawIndex < (1 << 16));
    return (rawIndex << _bitCount) | index;
  }

  static (ManifestAstElementKind, int) decode(int index) {
    var kindIndex = index & _bitMask;
    var kind = ManifestAstElementKind.values[kindIndex];
    var rawIndex = index >> _bitCount;
    return (kind, rawIndex);
  }
}

/// Enough information to decide if the node is the same.
///
/// We don't store ASTs, instead we rely on the fact that the same tokens
/// are parsed into the same AST (when the same language features, which is
/// ensured outside).
///
/// In addition we record all referenced elements.
class ManifestNode {
  /// The concatenated lexemes of all tokens.
  final String tokenBuffer;

  /// The length of each token in [tokenBuffer].
  final Uint32List tokenLengthList;

  /// All unique elements referenced by this node.
  final List<ManifestElement> elements;

  /// For each property in the AST structure summarized by this manifest that
  /// might point to an element, [ManifestAstElementKind.encodeRawIndex]
  /// produces the corresponding value.
  ///
  /// The order of this list reflects the AST structure, according to the
  /// behavior of [_ElementCollector].
  final Uint32List elementIndexList;

  factory ManifestNode.encode(EncodeContext context, AstNode node) {
    var buffer = StringBuffer();
    var lengthList = <int>[];

    var token = node.beginToken;
    while (true) {
      buffer.write(token.lexeme);
      lengthList.add(token.lexeme.length);
      if (token == node.endToken) {
        break;
      }
      token = token.next ?? (throw StateError('endToken not found'));
    }

    var collector = _ElementCollector(
      indexOfTypeParameter: context.indexOfTypeParameter,
      indexOfFormalParameter: context.indexOfFormalParameter,
    );
    node.accept(collector);

    return ManifestNode._(
      tokenBuffer: buffer.toString(),
      tokenLengthList: Uint32List.fromList(lengthList),
      elements: collector.map.keys
          .map((element) => ManifestElement.encode(context, element))
          .toFixedList(),
      elementIndexList: Uint32List.fromList(collector.elementIndexList),
    );
  }

  factory ManifestNode.read(SummaryDataReader reader) {
    return ManifestNode._(
      tokenBuffer: reader.readStringUtf8(),
      tokenLengthList: reader.readUInt30List(),
      elements: ManifestElement.readList(reader),
      elementIndexList: reader.readUInt30List(),
    );
  }

  ManifestNode._({
    required this.tokenBuffer,
    required this.tokenLengthList,
    required this.elements,
    required this.elementIndexList,
  });

  bool match(MatchContext context, AstNode node) {
    var tokenIndex = 0;
    var tokenOffset = 0;
    var token = node.beginToken;
    while (true) {
      var tokenLength = token.lexeme.length;
      if (tokenLengthList[tokenIndex++] != tokenLength) {
        return false;
      }

      if (!tokenBuffer.startsWith(token.lexeme, tokenOffset)) {
        return false;
      }
      tokenOffset += tokenLength;

      if (token == node.endToken) {
        break;
      }
      token = token.next ?? (throw StateError('endToken not found'));
    }

    var collector = _ElementCollector(
      indexOfTypeParameter: context.indexOfTypeParameter,
      indexOfFormalParameter: context.indexOfFormalParameter,
    );
    node.accept(collector);

    // Must reference the same elements.
    if (collector.map.length != elements.length) {
      return false;
    }
    for (var (index, element) in collector.map.keys.indexed) {
      if (!elements[index].match(context, element)) {
        return false;
      }
    }

    // Must reference elements in the same order.
    if (!const ListEquality<int>().equals(
      collector.elementIndexList,
      elementIndexList,
    )) {
      return false;
    }

    return true;
  }

  void write(BufferedSink sink) {
    sink.writeStringUtf8(tokenBuffer);
    sink.writeUint30List(tokenLengthList);
    sink.writeList(elements, (e) => e.write(sink));
    sink.writeUint30List(elementIndexList);
  }

  static List<ManifestNode> readList(SummaryDataReader reader) {
    return reader.readTypedList(() => ManifestNode.read(reader));
  }

  static ManifestNode? readOptional(SummaryDataReader reader) {
    return reader.readOptionalObject(() => ManifestNode.read(reader));
  }
}

class _ElementCollector extends ThrowingAstVisitor<void> {
  final int Function(TypeParameterElementImpl2) indexOfTypeParameter;
  final int Function(FormalParameterElementImpl) indexOfFormalParameter;
  final Map<Element2, int> map = Map.identity();
  final List<int> elementIndexList = [];

  _ElementCollector({
    required this.indexOfTypeParameter,
    required this.indexOfFormalParameter,
  });

  @override
  void visitAdjacentStrings(AdjacentStrings node) {
    node.visitChildren(this);
  }

  @override
  void visitAnnotation(Annotation node) {
    node.visitChildren(this);
    _addElement(node.element2);
  }

  @override
  void visitArgumentList(ArgumentList node) {
    node.visitChildren(this);
  }

  @override
  void visitAsExpression(AsExpression node) {
    node.visitChildren(this);
  }

  @override
  void visitAssertInitializer(AssertInitializer node) {
    node.visitChildren(this);
  }

  @override
  void visitBinaryExpression(BinaryExpression node) {
    node.visitChildren(this);
    _addElement(node.element);
  }

  @override
  void visitBooleanLiteral(BooleanLiteral node) {}

  @override
  void visitConditionalExpression(ConditionalExpression node) {
    node.visitChildren(this);
  }

  @override
  void visitConstructorFieldInitializer(ConstructorFieldInitializer node) {
    node.visitChildren(this);
  }

  @override
  void visitConstructorName(ConstructorName node) {
    node.visitChildren(this);
    _addElement(node.element);
  }

  @override
  void visitConstructorReference(ConstructorReference node) {
    node.visitChildren(this);
  }

  @override
  void visitDoubleLiteral(DoubleLiteral node) {}

  @override
  void visitFormalParameterList(FormalParameterList node) {
    node.visitChildren(this);
  }

  @override
  void visitGenericFunctionType(GenericFunctionType node) {
    node.visitChildren(this);
  }

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    node.visitChildren(this);
  }

  @override
  void visitIntegerLiteral(IntegerLiteral node) {}

  @override
  void visitInterpolationExpression(InterpolationExpression node) {
    node.visitChildren(this);
  }

  @override
  void visitInterpolationString(InterpolationString node) {}

  @override
  void visitIsExpression(IsExpression node) {
    node.visitChildren(this);
  }

  @override
  void visitListLiteral(ListLiteral node) {
    node.visitChildren(this);
  }

  @override
  void visitMapLiteralEntry(MapLiteralEntry node) {
    node.visitChildren(this);
  }

  @override
  void visitNamedExpression(NamedExpression node) {
    node.expression.accept(this);
  }

  @override
  void visitNamedType(NamedType node) {
    node.visitChildren(this);
    _addElement(node.element2);
  }

  @override
  void visitNullLiteral(NullLiteral node) {}

  @override
  void visitParenthesizedExpression(ParenthesizedExpression node) {
    node.visitChildren(this);
  }

  @override
  void visitPrefixedIdentifier(PrefixedIdentifier node) {
    node.prefix.accept(this);
    _addElement(node.element);
  }

  @override
  void visitPrefixExpression(PrefixExpression node) {
    node.visitChildren(this);
    _addElement(node.element);
  }

  @override
  void visitPropertyAccess(PropertyAccess node) {
    node.visitChildren(this);
  }

  @override
  void visitRedirectingConstructorInvocation(
      RedirectingConstructorInvocation node) {
    node.visitChildren(this);
  }

  @override
  void visitSetOrMapLiteral(SetOrMapLiteral node) {
    node.visitChildren(this);
  }

  @override
  void visitSimpleFormalParameter(SimpleFormalParameter node) {
    node.visitChildren(this);
  }

  @override
  void visitSimpleIdentifier(SimpleIdentifier node) {
    _addElement(node.element);
  }

  @override
  void visitSimpleStringLiteral(SimpleStringLiteral node) {}

  @override
  void visitSpreadElement(SpreadElement node) {
    node.visitChildren(this);
  }

  @override
  void visitStringInterpolation(StringInterpolation node) {
    node.visitChildren(this);
  }

  @override
  void visitSuperConstructorInvocation(SuperConstructorInvocation node) {
    node.visitChildren(this);
  }

  @override
  void visitTypeArgumentList(TypeArgumentList node) {
    node.visitChildren(this);
  }

  void _addElement(Element2? element) {
    ManifestAstElementKind kind;
    int rawIndex;
    switch (element) {
      case null:
        kind = ManifestAstElementKind.null_;
        rawIndex = 0;
      case DynamicElementImpl2():
        kind = ManifestAstElementKind.dynamic_;
        rawIndex = 0;
      case FormalParameterElementImpl():
        kind = ManifestAstElementKind.formalParameter;
        rawIndex = indexOfFormalParameter(element);
      case TypeParameterElementImpl2():
        kind = ManifestAstElementKind.typeParameter;
        rawIndex = indexOfTypeParameter(element);
      case PrefixElement2():
        kind = ManifestAstElementKind.importPrefix;
        rawIndex = 0;
      default:
        kind = ManifestAstElementKind.regular;
        rawIndex = map[element] ??= map.length;
    }

    var index = kind.encodeRawIndex(rawIndex);
    elementIndexList.add(index);
  }
}

extension ListOfManifestNodeExtension on List<ManifestNode> {
  bool match(MatchContext context, List<AstNode> nodes) {
    if (nodes.length != length) {
      return false;
    }
    for (var i = 0; i < length; i++) {
      if (!this[i].match(context, nodes[i])) {
        return false;
      }
    }
    return true;
  }

  void writeList(BufferedSink sink) {
    sink.writeList(this, (x) => x.write(sink));
  }
}

extension ManifestNodeOrNullExtension on ManifestNode? {
  bool match(MatchContext context, AstNode? node) {
    var self = this;
    if (self != null && node != null) {
      return self.match(context, node);
    } else {
      return self == null && node == null;
    }
  }

  void writeOptional(BufferedSink sink) {
    sink.writeOptionalObject(this, (it) => it.write(sink));
  }
}
