import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:firebase_auth/firebase_auth.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
=======
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/age_verification_service.dart';
import '../services/parental_consent_service.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _birthdateController = TextEditingController();
  final _childEmailController = TextEditingController();
  final _childPasswordController = TextEditingController();
  final _parentalConsentService = ParentalConsentService();
  String? _parentPhone;
  bool _isLoading = false;
  final _auth = FirebaseAuth.instance;

  String? _validateBirthdate(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your birthdate';
    final parsed = AgeVerificationService.parseBirthDate(value);
    if (parsed == null) return 'Invalid date format (YYYY-MM-DD)';
    return null;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final birthdate =
        AgeVerificationService.parseBirthDate(_birthdateController.text)!;
    final status = AgeVerificationService.getAgeStatus(birthdate);

    switch (status) {
      case AgeStatus.underageBlocked:
        _showBlockedDialog();
        break;
      case AgeStatus.minorNeedsConsent:
        _promptParentPhone();
        break;
      case AgeStatus.legalUser:
        _proceedToNextStep();
        break;
    }
  }

  void _showBlockedDialog() {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Access Denied"),
            content: const Text("You must be 13 or older to use this app."),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("OK"),
              ),
            ],
          ),
    );
  }

  void _promptParentPhone() {
    showDialog(
      context: context,
      builder: (_) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text("Parental Consent Required"),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: "Parent's Phone Number",
              hintText: "+39 321 456 7890",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() => _parentPhone = controller.text.trim());
                Navigator.of(context).pop();
                _handleParentFlow();
              },
              child: const Text("Send Request"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleParentFlow() async {
    if (_parentPhone == null) return;

    setState(() => _isLoading = true);
    try {
      final childUserCredential = await _auth.createUserWithEmailAndPassword(
        email: _childEmailController.text,
        password: _childPasswordController.text,
      );
      final childUid = childUserCredential.user?.uid;

      if (childUid == null) {
        throw Exception('Failed to create child account');
      }

      await _parentalConsentService.linkChildToParent(
        childUid: childUid,
        parentPhone: _parentPhone!,
      );

      if (!mounted) return;
      showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: const Text("Request Sent"),
              content: Text(
                "We've sent a consent request to the parent at $_parentPhone.\nThey must approve via the APP-OINT app.",
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("OK"),
                ),
              ],
            ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _proceedToNextStep() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Birthdate accepted. Continuing...")),
    );
>>>>>>> e7105b1f419548c2d80209a9eca410177f0a8a53
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
<<<<<<< HEAD
      appBar: AppBar(title: const Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ElevatedButton(
              onPressed: () async {
                final navigator = Navigator.of(context);
                try {
                  await FirebaseAuth.instance.createUserWithEmailAndPassword(
                    email: _emailController.text,
                    password: _passwordController.text,
                  );
                  if (!mounted) return;
                  navigator.pushReplacementNamed('/home');
                } catch (e) {
                  if (!mounted) return;
                  setState(() => _error = e.toString());
                }
              },
              child: const Text('Register'),
            ),
          ],
        ),
=======
      appBar: AppBar(title: const Text("Register")),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _birthdateController,
                    decoration: const InputDecoration(
                      labelText: "Birthdate (YYYY-MM-DD)",
                    ),
                    keyboardType: TextInputType.datetime,
                    validator: _validateBirthdate,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    child: const Text("Continue"),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
>>>>>>> e7105b1f419548c2d80209a9eca410177f0a8a53
      ),
    );
  }
}
