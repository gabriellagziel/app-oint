import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app_oint9/models/quiet_mode.dart';

class UserPreferencesService {
  final FirebaseFirestore _firestore;
  final String userId;

  UserPreferencesService({
    required this.userId,
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> get _quietModeDoc => _firestore
      .collection('users')
      .doc(userId)
      .collection('settings')
      .doc('quietMode');

  Future<void> setQuietMode(QuietMode quietMode) async {
    await _quietModeDoc.set({
      'enabled': quietMode.enabled,
      'quietUntil': Timestamp.fromDate(quietMode.quietUntil),
      'duration': quietMode.duration.inMinutes,
    });
  }

  Stream<QuietMode> watchQuietMode() {
    return _quietModeDoc.snapshots().map((doc) {
      if (!doc.exists) return QuietMode.disabled();

      final data = doc.data()!;
      return QuietMode(
        enabled: data['enabled'] as bool,
        quietUntil: (data['quietUntil'] as Timestamp).toDate(),
        duration: Duration(minutes: data['duration'] as int),
      );
    });
  }
}
