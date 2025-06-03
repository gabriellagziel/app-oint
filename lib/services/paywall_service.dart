import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PaywallService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  PaywallService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  Future<bool> isProUser() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    final doc = await _firestore.collection('users').doc(user.uid).get();
    return (doc.data()?['isPro'] ?? false) == true;
  }

  Future<int> getUserMeetingCount() async {
    final user = _auth.currentUser;
    if (user == null) return 0;

    final query = await _firestore
        .collection('meetings')
        .where('creatorId', isEqualTo: user.uid)
        .get();

    return query.docs.length;
  }

  Future<bool> canCreateMoreMeetings() async {
    if (await isProUser()) return true;
    final count = await getUserMeetingCount();
    return count < 5;
  }
}
