import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StudioDashboardScreen extends ConsumerWidget {
  const StudioDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Studio Dashboard')),
      body: const Center(child: Text('Welcome to Studio Dashboard')),
    );
  }
}
