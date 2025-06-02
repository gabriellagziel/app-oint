import 'package:flutter/material.dart';
import '../services/google_sign_in_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('APP-OINT Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => GoogleSignInService.signOut(),
          ),
        ],
      ),
      body: const Center(
        child: Text('Welcome! You are signed in.'),
      ),
    );
  }
}
