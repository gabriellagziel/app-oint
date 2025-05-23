import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/task.dart';

class TaskService {
  final _db = FirebaseFirestore.instance;
  final _collection = 'tasks';

  Stream<List<Task>> list() {
    return _db.collection(_collection).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Task.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  Future<Task?> get(String id) async {
    final doc = await _db.collection(_collection).doc(id).get();
    if (!doc.exists) return null;
    return Task.fromJson(doc.data() as Map<String, dynamic>);
  }

  Future<void> create(Task task) async {
    await _db.collection(_collection).doc(task.id).set(task.toJson());
  }

  Future<void> update(Task task) async {
    await _db.collection(_collection).doc(task.id).update(task.toJson());
  }

  Future<void> delete(String id) async {
    await _db.collection(_collection).doc(id).delete();
  }
}
