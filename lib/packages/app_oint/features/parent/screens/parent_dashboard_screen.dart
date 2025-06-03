import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_providers.dart';
import '../screens/parent_supervision_panel.dart';

class ParentDashboardScreen extends ConsumerWidget {
  const ParentDashboardScreen({super.key});

  void _navigateToNotifications(BuildContext context) {
    Navigator.pushNamed(context, '/notifications');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final parentId = ref.watch(currentUserProvider).value?.uid;

    final childrenStream =
        FirebaseFirestore.instance
            .collection('users')
            .where('linkedParentId', isEqualTo: parentId)
            .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Parent Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () => _navigateToNotifications(context),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: childrenStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final children = snapshot.data?.docs ?? [];
          if (children.isEmpty) {
            return const Center(child: Text('No linked children found.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: children.length,
            itemBuilder: (context, index) {
              final child = children[index];
              return Card(
                child: ListTile(
                  title: Text(child['displayName'] ?? 'Unnamed'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Email: ${child['email'] ?? ''}'),
                      Text('Total meetings: ${child['totalMeetings'] ?? 0}'),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.supervised_user_circle),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => ParentSupervisionPanel(childId: child.id),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
