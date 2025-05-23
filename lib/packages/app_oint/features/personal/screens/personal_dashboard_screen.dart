import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:csv/csv.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher_string.dart';

Future<void> openUrl(Uri url) async {
  if (!await launchUrlString(
    url.toString(),
    mode: LaunchMode.externalApplication,
  )) {
    debugPrint('Could not launch $url');
  }
}

final recentPersonalMeetingsProvider = StreamProvider.autoDispose((ref) {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  final start = DateTime.now().subtract(const Duration(days: 30));
  return FirebaseFirestore.instance
      .collection('meetings')
      .where('createdBy', isEqualTo: uid)
      .where('timestamp', isGreaterThan: start)
      .snapshots();
});

class PersonalDashboardScreen extends ConsumerWidget {
  const PersonalDashboardScreen({super.key});

  Future<void> _exportToCSV(List<QueryDocumentSnapshot> meetings) async {
    final csvData = [
      ['Date', 'Client', 'Email', 'Status', 'Notes'], // Headers
      ...meetings.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return [
          (data['timestamp'] as Timestamp).toDate().toString(),
          data['clientName'] ?? '',
          data['clientEmail'] ?? '',
          data['status'] ?? '',
          data['notes'] ?? '',
        ];
      }),
    ];

    final csvString = const ListToCsvConverter().convert(csvData);
    await SharePlus.instance.share(
      ShareParams(
        text: csvString,
        subject: 'Meetings Export',
      ),
    );
  }

  Future<void> _launchWhatsApp(String phone) async {
    final url = Uri.parse('https://wa.me/$phone');
    await openUrl(url);
  }

  Future<void> _launchEmail(String email) async {
    final url = Uri.parse('mailto:$email');
    await openUrl(url);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meetingsAsync = ref.watch(recentPersonalMeetingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Personal Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              meetingsAsync.whenData((snapshot) {
                _exportToCSV(snapshot.docs);
              });
            },
          ),
        ],
      ),
      body: meetingsAsync.when(
        data: (snapshot) {
          final meetings = snapshot.docs;
          final upcomingMeetings = meetings
              .where(
                (doc) => doc.data()['timestamp'].toDate().isAfter(
                      DateTime.now(),
                    ),
              )
              .toList();

          final clientStats = _calculateClientStats(meetings);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildUpcomingMeetings(context, upcomingMeetings),
              const SizedBox(height: 24),
              _buildClientStats(context, clientStats),
              const SizedBox(height: 24),
              _buildAppointmentChart(context, meetings),
              const SizedBox(height: 24),
              _buildInactiveClients(context, clientStats),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildUpcomingMeetings(
    BuildContext context,
    List<QueryDocumentSnapshot> meetings,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Upcoming Meetings',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            if (meetings.isEmpty)
              const Text('No upcoming meetings')
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: meetings.length,
                itemBuilder: (context, index) {
                  final meeting =
                      meetings[index].data() as Map<String, dynamic>;
                  return ListTile(
                    title: Text(meeting['clientName'] ?? 'Unnamed Client'),
                    subtitle: Text(
                      (meeting['timestamp'] as Timestamp)
                          .toDate()
                          .toString()
                          .substring(0, 16),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.message),
                      onPressed: () {
                        _launchEmail(meeting['clientEmail'] ?? '');
                      },
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Map<String, Map<String, dynamic>> _calculateClientStats(
    List<QueryDocumentSnapshot> meetings,
  ) {
    final stats = <String, Map<String, dynamic>>{};
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));

    for (final doc in meetings) {
      final data = doc.data() as Map<String, dynamic>;
      final clientEmail = data['clientEmail'] as String? ?? '';
      if (clientEmail.isEmpty) continue;

      if (!stats.containsKey(clientEmail)) {
        stats[clientEmail] = {
          'name': data['clientName'] ?? 'Unnamed Client',
          'totalMeetings': 0,
          'lastMeeting': null,
          'isActive': false,
        };
      }

      final timestamp = (data['timestamp'] as Timestamp).toDate();
      stats[clientEmail]!['totalMeetings'] =
          (stats[clientEmail]!['totalMeetings'] as int) + 1;
      stats[clientEmail]!['lastMeeting'] = timestamp;
      stats[clientEmail]!['isActive'] = timestamp.isAfter(thirtyDaysAgo);
    }

    return stats;
  }

  Widget _buildClientStats(
    BuildContext context,
    Map<String, Map<String, dynamic>> stats,
  ) {
    final topClients = stats.entries.toList()
      ..sort(
        (a, b) =>
            (b.value['totalMeetings'] as int) -
            (a.value['totalMeetings'] as int),
      );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Top Clients', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: topClients.take(3).length,
              itemBuilder: (context, index) {
                final client = topClients[index];
                return ListTile(
                  title: Text(client.value['name'] as String),
                  subtitle: Text(
                    '${client.value['totalMeetings']} meetings total',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.message),
                    onPressed: () => _launchEmail(client.key),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentChart(
    BuildContext context,
    List<QueryDocumentSnapshot> meetings,
  ) {
    final dailyCounts = <DateTime, int>{};
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));

    for (final doc in meetings) {
      final timestamp =
          (doc.data() as Map<String, dynamic>)['timestamp'] as Timestamp;
      final date = DateTime(
        timestamp.toDate().year,
        timestamp.toDate().month,
        timestamp.toDate().day,
      );
      if (date.isAfter(thirtyDaysAgo)) {
        dailyCounts[date] = (dailyCounts[date] ?? 0) + 1;
      }
    }

    final spots = dailyCounts.entries.map((entry) {
      return FlSpot(
        entry.key.millisecondsSinceEpoch.toDouble(),
        entry.value.toDouble(),
      );
    }).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Appointments (Last 30 Days)',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: const FlTitlesData(show: true),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: Theme.of(context).primaryColor,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInactiveClients(
    BuildContext context,
    Map<String, Map<String, dynamic>> stats,
  ) {
    final inactiveClients = stats.entries
        .where((entry) => !(entry.value['isActive'] as bool))
        .toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Inactive Clients',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            if (inactiveClients.isEmpty)
              const Text('No inactive clients')
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: inactiveClients.length,
                itemBuilder: (context, index) {
                  final client = inactiveClients[index];
                  return ListTile(
                    title: Text(client.value['name'] as String),
                    subtitle: Text(
                      'Last meeting: ${(client.value['lastMeeting'] as DateTime).toString().substring(0, 10)}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.message),
                          onPressed: () => _launchEmail(client.key),
                        ),
                        IconButton(
                          icon: const Icon(Icons.phone),
                          onPressed: () => _launchWhatsApp(client.key),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
