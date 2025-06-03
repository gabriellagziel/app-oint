import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SmartTagService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> updateClientTags(String clientId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    final clientRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('clients')
        .doc(clientId);

    await _firestore.runTransaction((transaction) async {
      final doc = await transaction.get(clientRef);
      if (!doc.exists) return;

      final data = doc.data() as Map<String, dynamic>;
      final tags = List<String>.from(data['tags'] ?? []);

      // Check for Frequent tag
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      final recentBookings =
          await _firestore
              .collection('bookings')
              .where('clientId', isEqualTo: clientId)
              .where(
                'scheduledTime',
                isGreaterThan: Timestamp.fromDate(thirtyDaysAgo),
              )
              .where('status', isEqualTo: 'confirmed')
              .get();

      if (recentBookings.docs.length >= 3 && !tags.contains('Frequent')) {
        tags.add('Frequent');
      }

      // Check for VIP tag
      final subscriptionDoc =
          await _firestore
              .collection('users')
              .doc(clientId)
              .collection('subscription')
              .doc('current')
              .get();

      if (subscriptionDoc.exists) {
        final subscriptionData = subscriptionDoc.data() as Map<String, dynamic>;
        if (subscriptionData['plan'] == 'pro' && !tags.contains('VIP')) {
          tags.add('VIP');
        }
      }

      // Update tags
      transaction.update(clientRef, {'tags': tags});
    });
  }

  Future<void> checkAndUpdateTags() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final clients =
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('clients')
            .get();

    for (final client in clients.docs) {
      await updateClientTags(client.id);
    }
  }

  Future<void> markClientLate(String clientId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    final clientRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('clients')
        .doc(clientId);

    await _firestore.runTransaction((transaction) async {
      final doc = await transaction.get(clientRef);
      if (!doc.exists) return;

      final data = doc.data() as Map<String, dynamic>;
      final lateCount = (data['joinedLateCount'] as int? ?? 0) + 1;
      final tags = List<String>.from(data['tags'] ?? []);

      if (lateCount >= 2 && !tags.contains('Late')) {
        tags.add('Late');
      }

      transaction.update(clientRef, {
        'joinedLateCount': lateCount,
        'tags': tags,
      });
    });
  }
}
