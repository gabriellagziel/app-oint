import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_oint9/models/quiet_mode.dart';
import 'package:app_oint9/features/user_settings/services/user_preferences_service.dart';
import 'package:app_oint9/services/auth_service.dart';

final quietModeProvider =
    StateNotifierProvider<QuietModeNotifier, QuietMode>((ref) {
  final auth = ref.watch(authServiceProvider);
  final userId = auth.currentUser?.uid;
  if (userId == null) {
    return QuietModeNotifier.disabled();
  }

  final service = UserPreferencesService(userId: userId);
  return QuietModeNotifier(QuietMode.disabled(), service);
});

class QuietModeNotifier extends StateNotifier<QuietMode> {
  final UserPreferencesService _service;

  QuietModeNotifier(QuietMode initial, this._service) : super(initial) {
    _service.watchQuietMode().listen((quietMode) {
      state = quietMode;
    });
  }

  static QuietModeNotifier disabled() {
    return QuietModeNotifier._mock();
  }

  QuietModeNotifier._mock()
      : _service = _MockUserPreferencesService(),
        super(QuietMode.disabled());

  Future<void> setEnabled(bool enabled) async {
    if (enabled) {
      final newState = state.copyWith(
        enabled: true,
        quietUntil: DateTime.now().add(state.duration),
      );
      await _service.setQuietMode(newState);
    } else {
      await disable();
    }
  }

  Future<void> setDuration(Duration duration) async {
    final newState = state.copyWith(
      duration: duration,
      quietUntil: DateTime.now().add(duration),
    );
    await _service.setQuietMode(newState);
  }

  Future<void> disable() async {
    await _service.setQuietMode(QuietMode.disabled());
  }
}

class _MockUserPreferencesService extends UserPreferencesService {
  _MockUserPreferencesService() : super(userId: 'mock');

  @override
  Future<void> setQuietMode(QuietMode quietMode) async {}

  @override
  Stream<QuietMode> watchQuietMode() {
    return Stream.value(QuietMode.disabled());
  }
}
