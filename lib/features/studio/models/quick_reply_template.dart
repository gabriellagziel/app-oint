import 'package:cloud_firestore/cloud_firestore.dart';

class QuickReplyTemplate {
  final String id;
  final String title;
  final String content;
  final String studioId;
  final DateTime createdAt;
  final DateTime? updatedAt;

  QuickReplyTemplate({
    required this.id,
    required this.title,
    required this.content,
    required this.studioId,
    required this.createdAt,
    this.updatedAt,
  });

  factory QuickReplyTemplate.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return QuickReplyTemplate(
      id: doc.id,
      title: data['title'] as String,
      content: data['content'] as String,
      studioId: data['studioId'] as String,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt:
          data['updatedAt'] != null
              ? (data['updatedAt'] as Timestamp).toDate()
              : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'content': content,
      'studioId': studioId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  QuickReplyTemplate copyWith({
    String? id,
    String? title,
    String? content,
    String? studioId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return QuickReplyTemplate(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      studioId: studioId ?? this.studioId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
