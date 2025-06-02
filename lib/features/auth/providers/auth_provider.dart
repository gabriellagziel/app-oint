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
