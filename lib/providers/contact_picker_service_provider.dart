import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/contact_picker_service.dart';
import '../services/contact_picker_service_impl.dart' as impl;

/// Provider for the ContactPickerService
final contactPickerServiceProvider = Provider<ContactPickerService>((ref) {
  return impl.ContactPickerServiceImpl(
      (key) => key); // Default to key if no localization is available
});
