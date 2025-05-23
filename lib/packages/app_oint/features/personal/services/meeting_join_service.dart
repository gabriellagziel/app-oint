import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MeetingJoinService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> joinMeeting({
    required String meetingId,
    required bool silent,
  }) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    final batch = _firestore.batch();

    // Update meeting participants
    final meetingRef = _firestore.collection('meetings').doc(meetingId);
    batch.update(meetingRef, {
      'participants': FieldValue.arrayUnion([userId]),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // Create join record
    final joinRef = _firestore
        .collection('meetings')
        .doc(meetingId)
        .collection('joins')
        .doc(userId);
    batch.set(joinRef, {
      'userId': userId,
      'timestamp': FieldValue.serverTimestamp(),
      'silent': silent,
    });

    await batch.commit();

    // If not silent, notify other participants
    if (!silent) {
      await _notifyParticipants(meetingId, userId);
    }
  }

  Future<void> leaveMeeting(String meetingId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final batch = _firestore.batch();

    // Update meeting participants
    final meetingRef = _firestore.collection('meetings').doc(meetingId);
    batch.update(meetingRef, {
      'participants': FieldValue.arrayRemove([userId]),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // Update join record
    final joinRef = _firestore
        .collection('meetings')
        .doc(meetingId)
        .collection('joins')
        .doc(userId);
    batch.update(joinRef, {'leftAt': FieldValue.serverTimestamp()});

    await batch.commit();
  }

  Future<void> _notifyParticipants(
    String meetingId,
    String joiningUserId,
  ) async {
    final meetingDoc =
        await _firestore.collection('meetings').doc(meetingId).get();
    if (!meetingDoc.exists) return;

    final data = meetingDoc.data() as Map<String, dynamic>;
    final participants = List<String>.from(data['participants'] ?? []);
    final creatorId = data['createdBy'] as String;

    // Notify all participants except the joining user
    for (final participantId in participants) {
      if (participantId != joiningUserId) {
        await _firestore
            .collection('users')
            .doc(participantId)
            .collection('notifications')
            .add({
              'type': 'meeting_join',
              'meetingId': meetingId,
              'userId': joiningUserId,
              'timestamp': FieldValue.serverTimestamp(),
              'read': false,
            });
      }
    }

    // Also notify the meeting creator if they're not a participant
    if (creatorId != joiningUserId && !participants.contains(creatorId)) {
      await _firestore
          .collection('users')
          .doc(creatorId)
          .collection('notifications')
          .add({
            'type': 'meeting_join',
            'meetingId': meetingId,
            'userId': joiningUserId,
            'timestamp': FieldValue.serverTimestamp(),
            'read': false,
          });
    }
  }
}
