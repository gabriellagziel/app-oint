import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
<<<<<<< HEAD
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
=======
import 'package:flutter/foundation.dart' show kIsWeb;
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
>>>>>>> e7105b1f419548c2d80209a9eca410177f0a8a53

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

<<<<<<< HEAD
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
=======
  Future<void> _signInWithEmailAndPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await ref
          .read(authServiceProvider)
          .signInWithEmailAndPassword(
            _emailController.text.trim(),
            _passwordController.text,
          );
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (kIsWeb) {
        // On web, the sign-in is handled by the GIS button and callback in main.dart
        throw Exception('Web Google Sign-In is handled by the Google button.');
      } else {
        // For non-web platforms, use the standard sign-in flow
        await ref.read(authServiceProvider).signInWithGoogle();
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _signInWithFacebook() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await ref.read(authServiceProvider).signInWithFacebook();
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Welcome to APP-OINT',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!value.contains('@')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _signInWithEmailAndPassword,
                    child:
                        _isLoading
                            ? const CircularProgressIndicator()
                            : const Text('Sign In'),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'OR',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  if (kIsWeb)
                    SizedBox(
                      height: 50,
                      child: HtmlElementView(viewType: 'google-signin-btn'),
                    )
                  else
                    OutlinedButton.icon(
                      onPressed: _isLoading ? null : _signInWithGoogle,
                      icon: const Icon(Icons.g_mobiledata, size: 24),
                      label: const Text('Sign in with Google'),
                    ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: _isLoading ? null : _signInWithFacebook,
                    icon: const Icon(Icons.facebook, size: 24),
                    label: const Text('Sign in with Facebook'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
>>>>>>> e7105b1f419548c2d80209a9eca410177f0a8a53
    );
  }
}
