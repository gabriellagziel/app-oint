import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/meeting.dart';

class MeetingService {
  final _db = FirebaseFirestore.instance;
  final _collection = 'meetings';

  Stream<List<Meeting>> list() {
    return _db.collection(_collection).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Meeting.fromJson(doc.data() as Map<String, dynamic>)).toList();
    });
  }

  Future<Meeting?> get(String id) async {
    final doc = await _db.collection(_collection).doc(id).get();
    if (!doc.exists) return null;
    return Meeting.fromJson(doc.data() as Map<String, dynamic>);
  }

  Future<void> create(Meeting meeting) async {
    await _db.collection(_collection).doc(meeting.id).set(meeting.toJson());
  }

  Future<void> update(Meeting meeting) async {
    await _db.collection(_collection).doc(meeting.id).update(meeting.toJson());
  }

  Future<void> delete(String id) async {
    await _db.collection(_collection).doc(id).delete();
  }
}
