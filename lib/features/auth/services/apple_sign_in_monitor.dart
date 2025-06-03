import 'dart:io';
import 'package:logging/logging.dart';

class AppleSignInMonitor {
  static final _logger = Logger('AppleSignInMonitor');
  static const _maxFailures = 3;
  static const _failureWindowMinutes = 5;
  final List<Map<String, dynamic>> _recentFailures = [];

  AppleSignInMonitor();

  void logSignInAttempt({
    required String userId,
    required bool success,
    String? errorMessage,
  }) {
    final platform = Platform.isIOS ? 'iOS' : 'Other';
    final status = success ? 'Success' : 'Failure';

    _logger.info(
      'Sign-In Attempt - Platform: $platform, User: $userId, Status: $status${errorMessage != null ? ', Error: $errorMessage' : ''}',
    );

    if (!success) {
      _handleFailure(userId, errorMessage);
    }
  }

  void _handleFailure(String userId, String? errorMessage) {
    final now = DateTime.now();
    _recentFailures.add({
      'timestamp': now,
      'userId': userId,
      'error': errorMessage,
    });

    // Remove failures older than the window
    _recentFailures.removeWhere(
      (failure) =>
          now.difference(failure['timestamp']).inMinutes >
          _failureWindowMinutes,
    );

    // Check if we need to trigger an alert
    if (_recentFailures.length >= _maxFailures) {
      _triggerAlert();
    }
  }

  void _triggerAlert() {
    _logger.warning(
      'Multiple Apple Sign-In failures detected in the last $_failureWindowMinutes minutes',
    );
  }

  List<Map<String, dynamic>> getRecentFailures() {
    return List.unmodifiable(_recentFailures);
  }

  void clearFailures() {
    _recentFailures.clear();
  }
}
