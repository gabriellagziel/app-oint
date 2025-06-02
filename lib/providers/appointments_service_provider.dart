import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/appointments_service.dart';
import '../services/appointments_service_impl.dart';

/// Provider for the appointments service
final appointmentsServiceProvider = Provider<AppointmentsService>((ref) {
  return AppointmentsServiceImpl();
});
