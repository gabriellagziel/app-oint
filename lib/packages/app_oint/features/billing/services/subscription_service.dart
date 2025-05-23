import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

class SubscriptionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String _stripePublishableKey;
  final String _functionsBaseUrl;

  SubscriptionService({
    required String stripePublishableKey,
    required String functionsBaseUrl,
  })  : _stripePublishableKey = stripePublishableKey,
        _functionsBaseUrl = functionsBaseUrl;

  Future<void> initialize() async {
    Stripe.publishableKey = _stripePublishableKey;
    await Stripe.instance.applySettings();
  }

  Future<String> createCheckoutSession({
    required String priceId,
    String? promoCode,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final response = await http.post(
      Uri.parse('$_functionsBaseUrl/createCheckoutSession'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': user.uid,
        'priceId': priceId,
        'promoCode': promoCode,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to create checkout session: ${response.body}');
    }

    final session = jsonDecode(response.body);
    return session['sessionId'];
  }

  Future<void> handleCheckoutSession(String sessionId) async {
    try {
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: sessionId,
          merchantDisplayName: 'APP-OINT',
        ),
      );
      await Stripe.instance.presentPaymentSheet();
    } catch (e) {
      throw Exception('Payment failed: $e');
    }
  }

  Future<void> openCustomerPortal() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final response = await http.post(
      Uri.parse('$_functionsBaseUrl/createPortalSession'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': user.uid}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to create portal session: ${response.body}');
    }

    final session = jsonDecode(response.body);
    final url = session['url'] as String?;
    if (url == null) {
      throw StateError('Stripe returned a null portal URL');
    }

    if (!await launchUrl(Uri.parse(url),
        mode: LaunchMode.externalApplication, webOnlyWindowName: '_blank')) {
      // ignore: only_throw_errors
      throw 'Could not launch $url';
    }
  }

  Stream<Map<String, dynamic>?> getSubscriptionStatus() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value(null);
    }

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('subscription')
        .doc('current')
        .snapshots()
        .map((doc) => doc.data());
  }

  Future<bool> isFeatureAvailable(String feature) async {
    final subscription = await getSubscriptionStatus().first;
    if (subscription == null) return false;

    final plan = subscription['plan'] as String?;
    if (plan == null) return false;

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

  Future<void> startCheckout(Map<String, dynamic> session) async {
    final url = session['url'] as String?;
    if (url == null) {
      throw StateError('Stripe returned a null checkout URL');
    }

    /// Uses url_launcher so the same code works on mobile, web and desktop.
    if (!await launchUrl(Uri.parse(url),
        mode: LaunchMode.externalApplication, webOnlyWindowName: '_blank')) {
      // ignore: only_throw_errors
      throw 'Could not launch $url';
    }
  }
}
