import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/meeting.dart';

class MeetingService {
  static final MeetingService _instance = MeetingService._internal();
  factory MeetingService() => _instance;
  MeetingService._internal();

  final _firestore = FirebaseFirestore.instance;

  Future<void> create(Meeting meeting) async {
    await _firestore
        .collection('meetings')
        .doc(meeting.id)
        .set(meeting.toJson());
  }

  Future<void> update(Meeting meeting) async {
    await _firestore
        .collection('meetings')
        .doc(meeting.id)
        .update(meeting.toJson());
  }

  Future<void> delete(String id) async {
    await _firestore.collection('meetings').doc(id).delete();
  }

  Stream<List<Meeting>> getMeetings(String userId) {
    return _firestore
        .collection('meetings')
        .where('creatorId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Meeting.fromJson(doc.data())).toList());
  }
}
