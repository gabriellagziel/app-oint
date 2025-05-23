import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/studio_plan_service.dart';

final studioPlanServiceProvider = Provider((ref) => StudioPlanService());

final currentPlanProvider = FutureProvider<String>((ref) {
  final service = ref.watch(studioPlanServiceProvider);
  return service.getCurrentPlan();
});

final canAccessFeatureProvider = FutureProvider.family<bool, String>((
  ref,
  feature,
) {
  final service = ref.watch(studioPlanServiceProvider);
  return service.canAccessFeature(feature);
});
