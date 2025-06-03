import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/client_stats_providers.dart';
import '../providers/studio_plan_providers.dart';
import '../models/client_stats.dart';
import 'package:intl/intl.dart';

class ClientCard extends ConsumerWidget {
  final ClientStats client;

  const ClientCard({super.key, required this.client});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Client ID: ${client.clientId}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Total Bookings: ${client.totalBookings}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      if (client.lastSeen != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Last Seen: ${DateFormat.yMMMd().format(client.lastSeen!)}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ],
                  ),
                ),
                _buildQuickActions(context, ref),
              ],
            ),
            if (client.tags.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children:
                    client.tags.map((tag) {
                      return Chip(
                        label: Text(tag),
                        backgroundColor: _getTagColor(tag),
                      );
                    }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      onSelected: (value) => _handleAction(context, ref, value),
      itemBuilder:
          (context) => [
            const PopupMenuItem(
              value: 'share',
              child: Row(
                children: [
                  Icon(Icons.share),
                  SizedBox(width: 8),
                  Text('Share Booking Link'),
                ],
              ),
            ),
            if (client.phone != null)
              const PopupMenuItem(
                value: 'whatsapp',
                child: Row(
                  children: [
                    Icon(Icons.message),
                    SizedBox(width: 8),
                    Text('Send WhatsApp'),
                  ],
                ),
              ),
            if (client.email != null)
              const PopupMenuItem(
                value: 'email',
                child: Row(
                  children: [
                    Icon(Icons.email),
                    SizedBox(width: 8),
                    Text('Send Email'),
                  ],
                ),
              ),
            PopupMenuItem(
              value: 'export',
              child: Row(
                children: [
                  const Icon(Icons.download),
                  const SizedBox(width: 8),
                  const Text('Export Data'),
                  const SizedBox(width: 8),
                  ref
                      .watch(canAccessFeatureProvider('export_csv'))
                      .when(
                        data: (canAccess) {
                          if (!canAccess) {
                            return const Tooltip(
                              message: 'Upgrade to Pro',
                              child: Icon(Icons.lock, size: 16),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                      ),
                ],
              ),
            ),
          ],
    );
  }

  Future<void> _handleAction(
    BuildContext context,
    WidgetRef ref,
    String action,
  ) async {
    final service = ref.read(clientStatsServiceProvider);

    try {
      switch (action) {
        case 'share':
          await service.shareBookingLink(client.clientId);
          break;
        case 'whatsapp':
          if (client.phone != null) {
            await service.sendWhatsApp(client.phone!);
          }
          break;
        case 'email':
          if (client.email != null) {
            await service.sendEmail(client.email!);
          }
          break;
        case 'export':
          final canExport = await ref.read(
            canAccessFeatureProvider('export_csv').future,
          );
          if (!canExport) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please upgrade to Pro to export data'),
                ),
              );
            }
            return;
          }
          final csvData = await service.exportClientData(client.clientId);
          if (context.mounted) {
            await showDialog(
              context: context,
              builder:
                  (context) => AlertDialog(
                    title: const Text('Export Data'),
                    content: SingleChildScrollView(child: Text(csvData)),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
            );
          }
          break;
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Color _getTagColor(String tag) {
    switch (tag.toLowerCase()) {
      case 'frequent':
        return Colors.green.withAlpha(25);
      case 'vip':
        return Colors.purple.withAlpha(25);
      case 'late':
        return Colors.red.withAlpha(25);
      default:
        return Colors.grey.withAlpha(25);
    }
  }
}
