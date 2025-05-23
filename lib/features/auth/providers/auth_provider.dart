import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../models/app_user.dart';
import '../models/user_role.dart';

/// Provider for the AuthService instance
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

/// Provider for the current user stream
final currentUserProvider = StreamProvider<AppUser?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.currentUser;
});

/// Provider for checking if the user is an admin
final isAdminProvider = Provider<bool>((ref) {
  final userAsync = ref.watch(currentUserProvider);
  return userAsync.when(
    data: (user) => user?.role == UserRole.admin,
    loading: () => false,
    error: (_, __) => false,
  );
});

/// Provider for checking if the user is a studio user
final isStudioProvider = Provider<bool>((ref) {
  final userAsync = ref.watch(currentUserProvider);
  return userAsync.when(
    data: (user) => user?.role == UserRole.studio,
    loading: () => false,
    error: (_, __) => false,
  );
});

/// Provider for checking if the user is a personal user
final isPersonalProvider = Provider<bool>((ref) {
  final userAsync = ref.watch(currentUserProvider);
  return userAsync.when(
    data: (user) => user?.role == UserRole.personal,
    loading: () => false,
    error: (_, __) => false,
  );
});

/// Provider for tracking loading state
final isLoadingProvider = StateProvider<bool>((ref) => false);

/// Provider for tracking error state
final errorProvider = StateProvider<String?>((ref) => null);
