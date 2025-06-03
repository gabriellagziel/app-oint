import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logging/logging.dart';

class ParentInviteSender {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _logger = Logger('ParentInviteSender');

  /// Triggers a push notification or SMS/WA invite to the parent.
  Future<void> notifyParent({
    required String childId,
    required String parentPhone,
  }) async {
    final parentDoc = await _findUserByPhone(parentPhone);
    final message =
        "Your child wants to use the APP-OINT app. Please approve access.";

    if (parentDoc != null) {
      final parentUid = parentDoc.id;

      // Firestore-based in-app notification (can be extended to FCM)
      await _firestore
          .collection('users')
          .doc(parentUid)
          .collection('notifications')
          .add({
            'type': 'parent_approval_request',
            'from': childId,
            'message': message,
            'timestamp': FieldValue.serverTimestamp(),
            'seen': false,
          });

      _logger.info('📲 Sent in-app notification to parent: $parentUid');
    } else {
      // Parent not registered – trigger SMS/WhatsApp (you need backend for this)
      // Example Firestore entry for server-side function to pick up
      await _firestore.collection('outgoing_sms_invites').add({
        'phone': parentPhone,
        'childId': childId,
        'type': 'parental_consent',
        'message': message,
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'pending',
      });

      _logger.info('📤 Triggered SMS/WhatsApp invite for parent: $parentPhone');
    }
  }

  Future<DocumentSnapshot?> _findUserByPhone(String phone) async {
    final result =
        await _firestore
            .collection('users')
            .where('phone', isEqualTo: phone)
            .limit(1)
            .get();

    return result.docs.isNotEmpty ? result.docs.first : null;
  }
}
