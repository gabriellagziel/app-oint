import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MeetingActionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<bool> isCreator(String meetingId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return false;

    final doc = await _firestore.collection('meetings').doc(meetingId).get();
    if (!doc.exists) return false;

    final data = doc.data() as Map<String, dynamic>;
    return data['createdBy'] == userId;
  }

  Future<void> duplicateMeeting(String meetingId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    final doc = await _firestore.collection('meetings').doc(meetingId).get();
    if (!doc.exists) throw Exception('Meeting not found');

    final data = doc.data() as Map<String, dynamic>;
    final newMeeting = {
      ...data,
      'createdBy': userId,
      'createdAt': FieldValue.serverTimestamp(),
      'status': 'pending',
      'participants': [],
    };
    delete(newMeeting, 'id');
    delete(newMeeting, 'createdAt');
    delete(newMeeting, 'updatedAt');

    await _firestore.collection('meetings').add(newMeeting);
  }

  Future<void> rescheduleMeeting(String meetingId, DateTime newTime) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    if (!await isCreator(meetingId)) {
      throw Exception('Only the creator can reschedule the meeting');
    }

    await _firestore.collection('meetings').doc(meetingId).update({
      'scheduledTime': Timestamp.fromDate(newTime),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // Notify participants
    await _notifyParticipants(
      meetingId,
      'meeting_rescheduled',
      'Meeting has been rescheduled',
    );
  }

  Future<void> cancelMeeting(String meetingId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    if (!await isCreator(meetingId)) {
      throw Exception('Only the creator can cancel the meeting');
    }

    await _firestore.collection('meetings').doc(meetingId).update({
      'status': 'cancelled',
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // Notify participants
    await _notifyParticipants(
      meetingId,
      'meeting_cancelled',
      'Meeting has been cancelled',
    );
  }

  Future<void> sendReminder(String meetingId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    if (!await isCreator(meetingId)) {
      throw Exception('Only the creator can send reminders');
    }

    // Notify participants
    await _notifyParticipants(
      meetingId,
      'meeting_reminder',
      'Reminder: You have a meeting coming up',
    );
  }

  Future<void> _notifyParticipants(
    String meetingId,
    String type,
    String message,
  ) async {
    final doc = await _firestore.collection('meetings').doc(meetingId).get();
    if (!doc.exists) return;

    final data = doc.data() as Map<String, dynamic>;
    final participants = List<String>.from(data['participants'] ?? []);
    final creatorId = data['createdBy'] as String;

    // Notify all participants
    for (final participantId in participants) {
      await _firestore
          .collection('users')
          .doc(participantId)
          .collection('notifications')
          .add({
            'type': type,
            'meetingId': meetingId,
            'message': message,
            'timestamp': FieldValue.serverTimestamp(),
            'read': false,
          });
    }

    // Also notify the meeting creator if they're not a participant
    if (!participants.contains(creatorId)) {
      await _firestore
          .collection('users')
          .doc(creatorId)
          .collection('notifications')
          .add({
            'type': type,
            'meetingId': meetingId,
            'message': message,
            'timestamp': FieldValue.serverTimestamp(),
            'read': false,
          });
    }
  }
}

void delete(Map<String, dynamic> map, String key) {
  if (map.containsKey(key)) {
    map.remove(key);
  }
}
