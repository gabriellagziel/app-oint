import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/reminder.dart';

class ReminderService {
  final _db = FirebaseFirestore.instance;
  final _collection = 'reminders';

  Stream<List<Reminder>> list() {
    return _db.collection(_collection).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Reminder.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  Future<Reminder?> get(String id) async {
    final doc = await _db.collection(_collection).doc(id).get();
    if (!doc.exists) return null;
    return Reminder.fromJson(doc.data() as Map<String, dynamic>);
  }

  Future<void> create(Reminder reminder) async {
    await _db.collection(_collection).doc(reminder.id).set(reminder.toJson());
  }

  Future<void> update(Reminder reminder) async {
    await _db
        .collection(_collection)
        .doc(reminder.id)
        .update(reminder.toJson());
  }

  Future<void> delete(String id) async {
    await _db.collection(_collection).doc(id).delete();
  }
}
