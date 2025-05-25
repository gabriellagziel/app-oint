import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';
import 'package:csv/csv.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'dart:async';

class StudioAnalyticsScreen extends StatefulWidget {
  const StudioAnalyticsScreen({super.key});

  @override
  State<StudioAnalyticsScreen> createState() => _StudioAnalyticsScreenState();
}

class _StudioAnalyticsScreenState extends State<StudioAnalyticsScreen> {
  List<DocumentSnapshot> _invites = [];
  String _selectedRange = 'Last 30 Days';

  final Map<String, Duration> _rangeMap = {
    'This Week': const Duration(days: 7),
    'Last 30 Days': const Duration(days: 30),
    'All Time': const Duration(days: 3650),
  };

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final now = DateTime.now();
    final cutoff = now.subtract(_rangeMap[_selectedRange]!);

    final query = await FirebaseFirestore.instance
        .collection('invites')
        .where('timestamp', isGreaterThan: Timestamp.fromDate(cutoff))
        .get();

    setState(() {
      _invites = query.docs;
    });
  }

  Map<String, int> _getStatusCounts() {
    final map = <String, int>{};
    for (final doc in _invites) {
      final status = doc['status'] ?? 'unknown';
      map[status] = (map[status] ?? 0) + 1;
    }
    return map;
  }

  int _getUniqueClientCount() {
    final clients = _invites.map((doc) => doc['toUid']).whereNotNull().toSet();
    return clients.length;
  }

  Future<void> _exportCsv() async {
    final rows = [
      ['Meeting ID', 'To UID', 'Phone', 'Status', 'Timestamp'],
      ..._invites.map((doc) => [
            doc['meetingId'],
            doc['toUid'],
            doc['phone'],
            doc['status'],
            DateFormat.yMd()
                .add_jm()
                .format((doc['timestamp'] as Timestamp).toDate()),
          ]),
    ];

    final csvData = const ListToCsvConverter().convert(rows);
    final file = File(
        '/tmp/invite_analytics_${DateTime.now().millisecondsSinceEpoch}.csv');
    await file.writeAsString(csvData);
    await Share.shareXFiles([XFile(file.path)],
        text: 'Studio Invite Analytics');
  }

  @override
  Widget build(BuildContext context) {
    final statusCounts = _getStatusCounts();

    return Scaffold(
      appBar: AppBar(title: const Text('Invite Analytics')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Time filter dropdown
            Row(
              children: [
                const Text('Range:'),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _selectedRange,
                  items: _rangeMap.keys
                      .map((label) =>
                          DropdownMenuItem(value: label, child: Text(label)))
                      .toList(),
                  onChanged: (val) {
                    if (val == null) return;
                    setState(() => _selectedRange = val);
                    _loadData();
                  },
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: _exportCsv,
                  icon: const Icon(Icons.download),
                  label: const Text('Export CSV'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Summary tiles
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _StatCard(
                    label: 'Total Invites', value: _invites.length.toString()),
                _StatCard(
                    label: 'Accepted',
                    value: '${statusCounts['accepted'] ?? 0}'),
                _StatCard(
                    label: 'Declined',
                    value: '${statusCounts['declined'] ?? 0}'),
                _StatCard(
                    label: 'Pending', value: '${statusCounts['pending'] ?? 0}'),
                _StatCard(
                    label: 'Unique Clients',
                    value: _getUniqueClientCount().toString()),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).colorScheme.surfaceVariant,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 4),
          Text(value, style: Theme.of(context).textTheme.headlineSmall),
        ],
      ),
    );
  }
}
