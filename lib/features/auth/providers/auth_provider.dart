<<<<<<< HEAD
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_provider.g.dart';

final firebaseAuthProvider =
    Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
});

@riverpod
class Auth extends _$Auth {
  final _auth = FirebaseAuth.instance;

  @override
  Stream<User?> build() {
    return _auth.authStateChanges();
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final googleProvider = GoogleAuthProvider();
      if (kIsWeb) {
        return await _auth.signInWithPopup(googleProvider);
      } else {
        return await _auth.signInWithCredential(
          await _auth
              .signInWithPopup(googleProvider)
              .then((result) => result.credential!),
        );
      }
    } catch (e) {
      debugPrint('Error signing in with Google: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
=======
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
>>>>>>> e7105b1f419548c2d80209a9eca410177f0a8a53
