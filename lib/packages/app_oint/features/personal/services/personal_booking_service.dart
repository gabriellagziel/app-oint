import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PersonalBookingService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  PersonalBookingService({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  Future<bool> canCreateFreePersonalMeeting() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return false;

    final snapshot =
        await _firestore
            .collection('meetings')
            .where('createdBy', isEqualTo: userId)
            .get();

    return snapshot.docs.length < 5;
  }

  Future<void> createPersonalMeeting({
    required DateTime timestamp,
    required String clientName,
    required String clientEmail,
    String? notes,
  }) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    if (!await canCreateFreePersonalMeeting()) {
      throw Exception(
        'Free meeting limit reached. Please upgrade to create more meetings.',
      );
    }

    await _firestore.collection('meetings').add({
      'createdBy': userId,
      'timestamp': timestamp,
      'clientName': clientName,
      'clientEmail': clientEmail,
      'notes': notes,
      'status': 'confirmed',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<int> getRemainingFreeMeetings() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return 0;

    final snapshot =
        await _firestore
            .collection('meetings')
            .where('createdBy', isEqualTo: userId)
            .get();

    return 5 - snapshot.docs.length;
  }
}
