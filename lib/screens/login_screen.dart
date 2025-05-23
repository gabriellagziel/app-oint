import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  Future<User?> signInWithGoogle() async {
    final authService = AuthService();
    return authService.signInWithGoogle();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
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
      ),
    );
  }
}
