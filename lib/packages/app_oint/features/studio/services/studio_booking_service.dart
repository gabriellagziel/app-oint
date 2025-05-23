import 'package:cloud_firestore/cloud_firestore.dart';

class StudioBookingService {
  final FirebaseFirestore _firestore;

  StudioBookingService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<bool> canCreateStudioBooking(String studioId) async {
    final doc = await _firestore.collection('studios').doc(studioId).get();
    final plan = doc.data()?['plan'] ?? 'basic';
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day);
    final end = start.add(const Duration(days: 1));

    final snapshot =
        await _firestore
            .collection('meetings')
            .where('studioId', isEqualTo: studioId)
            .where('timestamp', isGreaterThanOrEqualTo: start)
            .where('timestamp', isLessThan: end)
            .get();

    if (plan == 'pro') return true;
    return snapshot.docs.length < 20; // Basic plan limit
  }

  Future<int> getRemainingBookings(String studioId) async {
    final doc = await _firestore.collection('studios').doc(studioId).get();
    final plan = doc.data()?['plan'] ?? 'basic';
    if (plan == 'pro') return -1; // Unlimited

    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day);
    final end = start.add(const Duration(days: 1));

    final snapshot =
        await _firestore
            .collection('meetings')
            .where('studioId', isEqualTo: studioId)
            .where('timestamp', isGreaterThanOrEqualTo: start)
            .where('timestamp', isLessThan: end)
            .get();

    return 20 - snapshot.docs.length;
  }

  Future<void> createStudioBooking({
    required String studioId,
    required DateTime timestamp,
    required String clientName,
    required String clientEmail,
    String? notes,
  }) async {
    if (!await canCreateStudioBooking(studioId)) {
      throw Exception('Daily booking limit reached for basic plan');
    }

    await _firestore.collection('meetings').add({
      'studioId': studioId,
      'timestamp': timestamp,
      'clientName': clientName,
      'clientEmail': clientEmail,
      'notes': notes,
      'status': 'confirmed',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
