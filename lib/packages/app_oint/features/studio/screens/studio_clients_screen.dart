import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/smart_tag_providers.dart';
import '../providers/client_stats_providers.dart';
import '../widgets/client_card.dart';

class StudioClientsScreen extends ConsumerWidget {
  const StudioClientsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(child: Text('Please sign in to view clients'));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clients'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(smartTagServiceProvider).checkAndUpdateTags();
            },
          ),
        ],
      ),
      body: ref
          .watch(clientStatsProvider)
          .when(
            data: (clients) {
              if (clients.isEmpty) {
                return const Center(child: Text('No clients yet'));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: clients.length,
                itemBuilder: (context, index) {
                  final client = clients[index];
                  return ClientCard(client: client);
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text('Error: $error')),
          ),
    );
  }
}
