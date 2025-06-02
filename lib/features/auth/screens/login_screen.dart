import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('התחברות'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                try {
                  final userCredential =
                      await ref.read(authProvider.notifier).signInWithGoogle();
                  if (userCredential != null) {
                    // Navigate to home screen or handle successful login
                    if (context.mounted) {
                      Navigator.of(context).pushReplacementNamed('/home');
                    }
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('שגיאה בהתחברות: ${e.toString()}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('התחבר עם Google'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmailPasswordForm extends StatefulWidget {
  const _EmailPasswordForm({required this.auth});

  final FirebaseAuth auth;

  @override
  State<_EmailPasswordForm> createState() => _EmailPasswordFormState();
}

class _EmailPasswordFormState extends State<_EmailPasswordForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _emailController,
          decoration: const InputDecoration(labelText: 'אימייל'),
        ),
        TextField(
          controller: _passwordController,
          decoration: const InputDecoration(labelText: 'סיסמה'),
          obscureText: true,
        ),
        if (_error != null)
          Text(_error!, style: const TextStyle(color: Colors.red)),
        ElevatedButton(
          onPressed: () async {
            try {
              await widget.auth.signInWithEmailAndPassword(
                email: _emailController.text,
                password: _passwordController.text,
              );
            } catch (e) {
              if (!mounted) return;
              setState(() => _error = e.toString());
            }
          },
          child: const Text('התחבר'),
        ),
      ],
    );
  }
}
