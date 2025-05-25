import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import '../../personal/services/notification_service.dart';

class MeetingNotificationService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final NotificationService _notifications;
  final _logger = Logger('MeetingNotificationService');

  MeetingNotificationService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    NotificationService? notifications,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _notifications = notifications ?? NotificationService();

  /// Schedule a pre-meeting reminder notification
  Future<void> schedulePreMeetingReminder({
    required String meetingId,
    required String title,
    required DateTime meetingTime,
    required Duration reminderOffset,
  }) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    final reminderTime = meetingTime.subtract(reminderOffset);
    if (reminderTime.isBefore(DateTime.now())) {
      _logger.info('Skipping past reminder for meeting $meetingId');
      return;
    }

    await _notifications.scheduleReminder(
      id: meetingId.hashCode,
      title: 'Upcoming Meeting: $title',
      body: 'Your meeting starts in ${reminderOffset.inMinutes} minutes',
      scheduledTime: reminderTime,
    );

    // Log the scheduled reminder
    await _firestore
        .collection('meetings')
        .doc(meetingId)
        .collection('notifications')
        .add({
      'type': 'pre_meeting_reminder',
      'scheduledFor': Timestamp.fromDate(reminderTime),
      'offset': reminderOffset.inMinutes,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Send an "I'm Late" notification to meeting participants
  Future<void> sendLateNotification({
    required String meetingId,
    required String participantId,
  }) async {
    final meetingDoc =
        await _firestore.collection('meetings').doc(meetingId).get();
    if (!meetingDoc.exists) return;

    final data = meetingDoc.data() as Map<String, dynamic>;
    final participants = List<String>.from(data['participants'] ?? []);
    final creatorId = data['createdBy'] as String;

    // Notify all participants except the late one
    for (final participantId in participants) {
      if (participantId != _auth.currentUser?.uid) {
        await _firestore
            .collection('users')
            .doc(participantId)
            .collection('notifications')
            .add({
          'type': 'participant_late',
          'meetingId': meetingId,
          'lateUserId': _auth.currentUser?.uid,
          'message': 'A participant is running late',
          'timestamp': FieldValue.serverTimestamp(),
          'read': false,
        });
      }
    }

    // Also notify the meeting creator if they're not a participant
    if (creatorId != _auth.currentUser?.uid &&
        !participants.contains(creatorId)) {
      await _firestore
          .collection('users')
          .doc(creatorId)
          .collection('notifications')
          .add({
        'type': 'participant_late',
        'meetingId': meetingId,
        'lateUserId': _auth.currentUser?.uid,
        'message': 'A participant is running late',
        'timestamp': FieldValue.serverTimestamp(),
        'read': false,
      });
    }
  }

  /// Schedule a series of push reminders for a meeting
  Future<void> scheduleMeetingReminders({
    required String meetingId,
    required String title,
    required DateTime meetingTime,
  }) async {
    // Schedule reminders at different intervals
    final reminders = [
      const Duration(hours: 24), // 1 day before
      const Duration(hours: 1), // 1 hour before
      const Duration(minutes: 15), // 15 minutes before
    ];

    for (final offset in reminders) {
      await schedulePreMeetingReminder(
        meetingId: meetingId,
        title: title,
        meetingTime: meetingTime,
        reminderOffset: offset,
      );
    }
  }

  /// Cancel all notifications for a meeting
  Future<void> cancelMeetingNotifications(String meetingId) async {
    await _notifications.cancelReminder(meetingId.hashCode);

    // Mark all pending notifications as cancelled
    await _firestore
        .collection('meetings')
        .doc(meetingId)
        .collection('notifications')
        .where('status', isEqualTo: 'pending')
        .get()
        .then((snapshot) {
      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.update(doc.reference, {'status': 'cancelled'});
      }
      return batch.commit();
    });
  }
}
