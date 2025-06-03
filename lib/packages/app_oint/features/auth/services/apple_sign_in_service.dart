import 'dart:io' show Platform;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:logging/logging.dart';

final _logger = Logger('AppleSignInService');

class AppleSignInService {
  final FirebaseAuth _auth;

  AppleSignInService(this._auth);

  /// Signs in with Apple and returns a Firebase User
  Future<User?> signIn() async {
    if (!Platform.isIOS) {
      throw UnsupportedError('Apple Sign In is only supported on iOS');
    }

    try {
      final credential = await getCredentials();
      if (credential == null) return null;

      final userCredential = await _auth.signInWithCredential(credential);
      _logger.info(
        'Successfully signed in with Apple: ${userCredential.user?.email}',
      );
      return userCredential.user;
    } catch (e) {
      _logger.severe('Error signing in with Apple: $e');
      throw FirebaseAuthException(
        code: 'sign-in-failed',
        message: 'Failed to sign in with Apple: $e',
      );
    }
  }

  /// Returns Apple Sign-In credentials for custom handling
  Future<OAuthCredential?> getCredentials() async {
    if (!Platform.isIOS) {
      _logger.warning('Apple Sign-In is only available on iOS');
      return null;
    }

    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      return OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );
    } catch (e) {
      _logger.severe('Error getting Apple Sign-In credentials: $e');
      return null;
    }
  }
}
