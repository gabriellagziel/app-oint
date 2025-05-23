import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_oint/config/env.dart';
import '../services/subscription_service.dart';

final stripePkProvider = Provider((_) => Env.stripePk);

final subscriptionServiceProvider = Provider<SubscriptionService>((ref) {
  return SubscriptionService(
    stripePublishableKey: ref.watch(stripePkProvider),
    functionsBaseUrl: Env.functionsBaseUrl,
  );
});

final subscriptionStatusProvider = StreamProvider<Map<String, dynamic>?>((ref) {
  final service = ref.watch(subscriptionServiceProvider);
  return service.getSubscriptionStatus();
});

final canAccessFeatureProvider = FutureProvider.family<bool, String>((
  ref,
  feature,
) {
  final service = ref.watch(subscriptionServiceProvider);
  return service.isFeatureAvailable(feature);
});
