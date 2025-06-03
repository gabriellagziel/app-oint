import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logging/logging.dart';

class ParentalConsentService {
  final _firestore = FirebaseFirestore.instance;
  final _logger = Logger('ParentalConsentService');

  /// Links a child user to a parent phone number and updates Firestore.
  Future<void> linkChildToParent({
    required String childUid,
    required String parentPhone,
  }) async {
    final parentUser = await _findUserByPhone(parentPhone);

    // Step 1: Save parentPhone in child's metadata
    await _firestore.collection('users').doc(childUid).update({
      'accountStatus': 'pending_parent',
      'meta': {'parentPhone': parentPhone, 'parentLinked': parentUser != null},
    });

    // Step 2: If parent exists, store child under their profile too
    if (parentUser != null) {
      final parentUid = parentUser.id;
      await _firestore
          .collection('users')
          .doc(parentUid)
          .collection('children')
          .doc(childUid)
          .set({
            'linkedAt': FieldValue.serverTimestamp(),
            'status': 'waiting_approval',
          });

      // Placeholder: Send internal notification to parent for approval
      _logger.info(
        '🟡 Send in-app notification to $parentUid to approve $childUid',
      );
    } else {
      // Step 3: Parent not found – trigger SMS/WhatsApp invite flow
      _logger.info(
        '🔵 Parent not in system — trigger SMS/WA invite to $parentPhone',
      );
      // You will implement this via your SMS/WA system
    }
  }

  /// Looks for a user in Firestore by phone number
  Future<DocumentSnapshot?> _findUserByPhone(String phone) async {
    final query =
        await _firestore
            .collection('users')
            .where('phone', isEqualTo: phone)
            .limit(1)
            .get();
    if (query.docs.isEmpty) return null;
    return query.docs.first;
  }

  /// Approves a child account by parent (called from parent side)
  Future<void> approveChild(String parentUid, String childUid) async {
    // 1. Mark child account as approved
    await _firestore.collection('users').doc(childUid).update({
      'accountStatus': 'approved',
    });

    // 2. Update child record in parent subcollection
    await _firestore
        .collection('users')
        .doc(parentUid)
        .collection('children')
        .doc(childUid)
        .update({
          'status': 'approved',
          'approvedAt': FieldValue.serverTimestamp(),
        });

    _logger.info('✅ Child $childUid approved by parent $parentUid');
  }

  /// Denies or blocks child account
  Future<void> denyChild(String parentUid, String childUid) async {
    await _firestore.collection('users').doc(childUid).update({
      'accountStatus': 'denied',
    });

    await _firestore
        .collection('users')
        .doc(parentUid)
        .collection('children')
        .doc(childUid)
        .update({'status': 'denied', 'deniedAt': FieldValue.serverTimestamp()});

    _logger.info('❌ Child $childUid denied by parent $parentUid');
  }
}
