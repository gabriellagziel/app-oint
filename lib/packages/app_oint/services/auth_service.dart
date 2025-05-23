import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import '../features/auth/services/apple_sign_in_service.dart';
import 'package:logging/logging.dart';

final _logger = Logger('AuthService');

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FacebookAuth _facebookAuth = FacebookAuth.instance;
  late final AppleSignInService _appleSignInService;

  AuthService() {
    _appleSignInService = AppleSignInService(_auth);
  }

  // Google Sign-In
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _logger.warning('Google sign in aborted');
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      _logger.info(
        'Successfully signed in with Google: ${userCredential.user?.email}',
      );
      return userCredential.user;
    } catch (e) {
      _logger.severe('Error signing in with Google: $e');
      rethrow;
    }
  }

  // Apple Sign-In (iOS only)
  Future<User?> signInWithApple() async {
    try {
      return await _appleSignInService.signIn();
    } catch (e) {
      _logger.severe('Apple sign-in failed: $e');
      rethrow;
    }
  }

  // Facebook Sign-In (Web & Android)
  Future<User?> signInWithFacebook() async {
    try {
      final LoginResult result = await _facebookAuth.login();
      if (result.status != LoginStatus.success) {
        _logger.warning('Facebook login failed: ${result.status}');
        return null;
      }

      final AccessToken accessToken = result.accessToken!;
      final credential =
          FacebookAuthProvider.credential(accessToken.toJson()['token']);
      final userCredential = await _auth.signInWithCredential(credential);
      _logger.info(
        'Successfully signed in with Facebook: ${userCredential.user?.email}',
      );
      return userCredential.user;
    } catch (e) {
      _logger.severe('Error signing in with Facebook: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
        _facebookAuth.logOut(),
      ]);
      _logger.info('Successfully signed out from all providers');
    } catch (e) {
      _logger.severe('Error during sign out: $e');
      rethrow;
    }
  }
}
