import 'package:cloud_firestore/cloud_firestore.dart';

class Reminder {
  final String id;
  final String title;
  final String description;
  final DateTime scheduledTime;
  final bool isCompleted;
  final String userId;
  final DateTime? completedAt;

  Reminder({
    required this.id,
    required this.title,
    required this.description,
    required this.scheduledTime,
    required this.isCompleted,
    required this.userId,
    this.completedAt,
  });

  factory Reminder.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Reminder(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      scheduledTime: (data['scheduledTime'] as Timestamp).toDate(),
      isCompleted: data['isCompleted'] ?? false,
      userId: data['userId'] ?? '',
      completedAt:
          data['completedAt'] != null
              ? (data['completedAt'] as Timestamp).toDate()
              : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'scheduledTime': Timestamp.fromDate(scheduledTime),
      'isCompleted': isCompleted,
      'userId': userId,
      if (completedAt != null) 'completedAt': Timestamp.fromDate(completedAt!),
    };
  }

  Reminder copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? scheduledTime,
    bool? isCompleted,
    String? userId,
    DateTime? completedAt,
  }) {
    return Reminder(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      isCompleted: isCompleted ?? this.isCompleted,
      userId: userId ?? this.userId,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Reminder &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          description == other.description &&
          scheduledTime == other.scheduledTime &&
          isCompleted == other.isCompleted &&
          userId == other.userId &&
          completedAt == other.completedAt;

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      description.hashCode ^
      scheduledTime.hashCode ^
      isCompleted.hashCode ^
      userId.hashCode ^
      completedAt.hashCode;
}
