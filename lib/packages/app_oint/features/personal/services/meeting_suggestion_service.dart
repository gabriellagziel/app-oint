import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MeetingSuggestionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> markSuggestionShown(String meetingId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('suggestions')
        .doc(meetingId)
        .set({'shown': true, 'timestamp': FieldValue.serverTimestamp()});
  }

  Future<bool> shouldShowSuggestion(String meetingId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return false;

    final doc =
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('suggestions')
            .doc(meetingId)
            .get();

    return !doc.exists;
  }

  Future<Map<String, dynamic>?> getMeetingDetails(String meetingId) async {
    final doc = await _firestore.collection('meetings').doc(meetingId).get();
    if (!doc.exists) return null;

    final data = doc.data() as Map<String, dynamic>;
    return {
      'title': data['title'],
      'description': data['description'],
      'location': data['location'],
      'invitees': data['invitees'],
      'duration': data['duration'],
    };
  }

  Future<void> duplicateMeeting(String meetingId) async {
    final details = await getMeetingDetails(meetingId);
    if (details == null) return;

    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    // Create a new meeting with the same details
    await _firestore.collection('meetings').add({
      ...details,
      'createdBy': userId,
      'createdAt': FieldValue.serverTimestamp(),
      'status': 'pending',
    });
  }

  Future<void> rescheduleMeeting(String meetingId, DateTime newTime) async {
    await _firestore.collection('meetings').doc(meetingId).update({
      'scheduledTime': Timestamp.fromDate(newTime),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
