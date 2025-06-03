import 'package:flutter/material.dart';
<<<<<<< HEAD
import '../services/google_sign_in_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _loading = false;
  String? _error;

  Future<void> _handleSignIn() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await GoogleSignInService.signInWithGoogle();
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
=======
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  Future<User?> signInWithGoogle() async {
    final authService = AuthService();
    return authService.signInWithGoogle();
>>>>>>> e7105b1f419548c2d80209a9eca410177f0a8a53
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
<<<<<<< HEAD
        child: _loading
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.g_mobiledata, size: 24),
                    label: const Text('Sign in with Google'),
                    onPressed: _handleSignIn,
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      _error!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
=======
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (kIsWeb)
              SizedBox(
                height: 50,
                child: HtmlElementView(viewType: 'google-signin-btn'),
              ),
            ElevatedButton(
              onPressed: () async {
                try {
                  final result = await signInWithGoogle();
                  if (result != null) {
                    // Handle successful sign in
                  }
                } catch (e) {
                  // Handle error
                }
              },
              child: const Text('Sign in with Google'),
            ),
          ],
        ),
>>>>>>> e7105b1f419548c2d80209a9eca410177f0a8a53
      ),
    );
  }
}
