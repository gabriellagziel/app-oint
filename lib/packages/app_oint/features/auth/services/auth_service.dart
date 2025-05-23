import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import '../models/app_user.dart';
import '../models/user_role.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:logging/logging.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

final _logger = Logger('APP-OINT');

void setupLogger() {
  Logger.root.level = Level.INFO;
  Logger.root.onRecord.listen((record) {
    logInfo('${record.level.name}: ${record.time}: ${record.message}');
  });
}

void logInfo(String message) => _logger.info(message);
void logWarning(String message) => _logger.warning(message);
void logError(String message) => _logger.severe(message);

/// Service class for handling authentication operations
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FacebookAuth _facebookAuth = FacebookAuth.instance;

  /// Stream of the current user
  Stream<AppUser?> get currentUser {
    return _auth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (!doc.exists) return null;
      return AppUser.fromFirestore(doc);
    });
  }

  /// Signs in with email and password
  Future<AppUser> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final doc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();
      return AppUser.fromFirestore(doc);
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Signs in with Google
  Future<AppUser> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        throw Exception('Web Google Sign-In is handled by GIS.');
      } else {
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        if (googleUser == null) throw Exception('Google sign in aborted');
        return await _handleGoogleSignIn(googleUser);
      }
    } catch (e) {
      logError('Error signing in with Google: $e');
      throw _handleAuthException(e);
    }
  }

  /// Handles the Google Sign-In process
  Future<AppUser> _handleGoogleSignIn(GoogleSignInAccount googleUser) async {
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await _auth.signInWithCredential(credential);
    return await _getOrCreateUser(userCredential.user!);
  }

  /// Signs in with Google token (for web, called from main.dart)
  Future<AppUser> signInWithGoogleToken(String idToken) async {
    try {
      final credential = GoogleAuthProvider.credential(idToken: idToken);
      final userCredential = await _auth.signInWithCredential(credential);
      return await _getOrCreateUser(userCredential.user!);
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Signs in with Facebook
  Future<AppUser> signInWithFacebook() async {
    try {
      await _facebookAuth.logOut();
      final LoginResult result = await _facebookAuth.login();
      if (result.status != LoginStatus.success) {
        logError('Facebook Sign-In Error: ${result.status}');
        throw Exception('Facebook login failed: ${result.status}');
      }

      final AccessToken accessToken = result.accessToken!;
      logInfo('Facebook Sign-In Success: \\${accessToken.toJson()}');

      final fbToken = accessToken.toJson()['token'];
      final credential = FacebookAuthProvider.credential(fbToken);
      final userCredential = await _auth.signInWithCredential(credential);
      return await _getOrCreateUser(userCredential.user!);
    } catch (e) {
      logError('Facebook Sign-In Error: $e');
      throw _handleAuthException(e);
    }
  }

  /// Signs out the current user
  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
        _facebookAuth.logOut(),
      ]);
      logInfo('Successfully signed out from all providers');
    } catch (e) {
      logError('Error during sign out: $e');
      throw Exception('Failed to sign out: $e');
    }
  }

  /// Creates a new user with email and password
  Future<AppUser> createUserWithEmailAndPassword(
    String email,
    String password,
    String displayName,
    UserRole role,
  ) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user!;
      await user.updateDisplayName(displayName);

      final appUser = AppUser(
        id: user.uid,
        email: email,
        displayName: displayName,
        photoUrl: user.photoURL,
        role: role,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isEmailVerified: user.emailVerified,
      );

      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(appUser.toFirestore());
      return appUser;
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Updates the user's role
  Future<void> updateUserRole(String userId, UserRole newRole) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'role': newRole.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update user role: $e');
    }
  }

  /// Gets or creates a user in Firestore
  Future<AppUser> _getOrCreateUser(User user) async {
    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (doc.exists) {
      return AppUser.fromFirestore(doc);
    }

    final appUser = AppUser(
      id: user.uid,
      email: user.email!,
      displayName: user.displayName ?? user.email!.split('@')[0],
      photoUrl: user.photoURL,
      role: UserRole.personal, // Default role for new users
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isEmailVerified: user.emailVerified,
    );

    await _firestore
        .collection('users')
        .doc(user.uid)
        .set(appUser.toFirestore());
    return appUser;
  }

  /// Handles authentication exceptions
  Exception _handleAuthException(dynamic e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'user-not-found':
          return Exception('No user found with this email.');
        case 'wrong-password':
          return Exception('Wrong password provided.');
        case 'email-already-in-use':
          return Exception('Email is already in use.');
        case 'invalid-email':
          return Exception('Invalid email address.');
        case 'weak-password':
          return Exception('Password is too weak.');
        case 'user-disabled':
          return Exception('This user has been disabled.');
        case 'operation-not-allowed':
          return Exception('Operation not allowed.');
        default:
          return Exception('Authentication failed: ${e.message}');
      }
    }
    return Exception('An unexpected error occurred: $e');
  }

  Future<User?> signInWithApple() async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: credential.identityToken,
        accessToken: credential.authorizationCode,
      );

      final userCredential = await _auth.signInWithCredential(oauthCredential);
      _logger.info(
        'Successfully signed in with Apple: ${userCredential.user?.email}',
      );
      return userCredential.user;
    } catch (e) {
      _logger.severe('Error signing in with Apple: $e');
      rethrow;
    }
  }
}
