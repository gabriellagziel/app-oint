import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StudioPlanService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> getCurrentPlan() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    final studioDoc =
        await _firestore
            .collection('studios')
            .where('userId', isEqualTo: user.uid)
            .get();

    if (studioDoc.docs.isEmpty) {
      throw Exception('Studio not found');
    }

    return studioDoc.docs.first.data()['plan'] as String? ?? 'basic';
  }

  bool isFeatureAvailable(String plan, String feature) {
    switch (feature) {
      case 'month_view':
      case 'export_csv':
      case 'smart_tags':
        return plan == 'pro';
      case 'quick_replies':
      case 'booking_links':
        return true; // Available in all plans
      default:
        return false;
    }
  }

  Future<bool> canAccessFeature(String feature) async {
    final plan = await getCurrentPlan();
    return isFeatureAvailable(plan, feature);
  }
}
