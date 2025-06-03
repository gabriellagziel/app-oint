import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/quick_reply_template.dart';

class QuickReplyService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<List<QuickReplyTemplate>> getTemplates() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return Stream.value([]);

    return _firestore
        .collection('quick_replies')
        .where('studioId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => QuickReplyTemplate.fromFirestore(doc))
              .toList();
        });
  }

  Future<void> createTemplate({
    required String title,
    required String content,
  }) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    final template = QuickReplyTemplate(
      id: '', // Will be set by Firestore
      title: title,
      content: content,
      studioId: userId,
      createdAt: DateTime.now(),
    );

    await _firestore.collection('quick_replies').add(template.toFirestore());
  }

  Future<void> updateTemplate(QuickReplyTemplate template) async {
    final updatedTemplate = template.copyWith(updatedAt: DateTime.now());

    await _firestore
        .collection('quick_replies')
        .doc(template.id)
        .update(updatedTemplate.toFirestore());
  }

  Future<void> deleteTemplate(String templateId) async {
    await _firestore.collection('quick_replies').doc(templateId).delete();
  }

  Future<String> getTemplateContent(String templateId) async {
    final doc =
        await _firestore.collection('quick_replies').doc(templateId).get();
    if (!doc.exists) throw Exception('Template not found');

    final template = QuickReplyTemplate.fromFirestore(doc);
    return template.content;
  }
}
