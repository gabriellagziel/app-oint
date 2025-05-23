import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../../../models/reminder.dart';
import 'notification_service.dart';

class ReminderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final NotificationService _notifications = NotificationService();
  final _remindersRef = FirebaseFirestore.instance.collection('reminders');

  Stream<List<Reminder>> getReminders() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      debugPrint('User not authenticated');
      return Stream.value([]);
    }

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('reminders')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Reminder.fromFirestore(doc))
              .toList();
        });
  }

  Future<void> createReminder({
    required String title,
    required String description,
    required DateTime scheduledTime,
  }) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    final reminder = Reminder(
      id: '', // Will be set by Firestore
      title: title,
      description: description,
      scheduledTime: scheduledTime,
      isCompleted: false,
      userId: userId,
    );

    final docRef = await _firestore
        .collection('users')
        .doc(userId)
        .collection('reminders')
        .add(reminder.toFirestore());

    // Schedule local notification
    await _notifications.scheduleReminder(
      id: docRef.id.hashCode,
      title: title,
      body: description,
      scheduledTime: scheduledTime,
    );
  }

  Future<void> updateReminder(Reminder reminder) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      debugPrint('User not authenticated');
      return;
    }

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('reminders')
        .doc(reminder.id)
        .update(reminder.toFirestore());

    // Update local notification
    await _notifications.cancelReminder(reminder.id.hashCode);
    if (!reminder.isCompleted) {
      await _notifications.scheduleReminder(
        id: reminder.id.hashCode,
        title: reminder.title,
        body: reminder.title,
        scheduledTime: reminder.scheduledTime,
      );
    }
  }

  Future<void> deleteReminder(String reminderId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      debugPrint('User not authenticated');
      return;
    }

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('reminders')
        .doc(reminderId)
        .delete();
    await _notifications.cancelReminder(reminderId.hashCode);
  }

  Future<void> markAsCompleted(String reminderId) async {
    final now = DateTime.now();
    await _firestore.collection('reminders').doc(reminderId).update({
      'isCompleted': true,
      'completedAt': Timestamp.fromDate(now),
    });
    await _notifications.cancelReminder(reminderId.hashCode);
  }

  Future<void> markAsIncomplete(String reminderId) async {
    final doc = await _firestore.collection('reminders').doc(reminderId).get();
    if (!doc.exists) return;

    final reminder = Reminder.fromFirestore(doc);
    await _firestore.collection('reminders').doc(reminderId).update({
      'isCompleted': false,
      'completedAt': null,
    });

    // Reschedule notification
    await _notifications.scheduleReminder(
      id: reminderId.hashCode,
      title: reminder.title,
      body: reminder.title,
      scheduledTime: reminder.scheduledTime,
    );
  }

  Stream<List<Reminder>> watchUpcomingReminders() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      debugPrint('User not authenticated');
      return Stream.value([]);
    }

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('reminders')
        .where('isCompleted', isEqualTo: false)
        .orderBy('dueDate')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Reminder.fromFirestore(doc))
              .toList();
        });
  }

  Future<void> addReminder(Reminder reminder) async {
    await _remindersRef.add(reminder.toFirestore());
  }

  Stream<List<Reminder>> getPendingRemindersStream() {
    return _remindersRef
        .where('isCompleted', isEqualTo: false)
        .orderBy('scheduledTime')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Reminder.fromFirestore(doc)).toList(),
        );
  }

  Stream<List<Reminder>> getCompletedRemindersStream() {
    return _remindersRef
        .where('isCompleted', isEqualTo: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Reminder.fromFirestore(doc)).toList(),
        );
  }
}
