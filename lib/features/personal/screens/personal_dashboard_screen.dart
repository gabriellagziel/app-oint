import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:table_calendar/table_calendar.dart';
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
              _buildWeeklySummaryChart(context, meetings),
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
    final eventMap = <DateTime, List<Map<String, dynamic>>>{};
    for (final doc in meetings) {
      final data = doc.data() as Map<String, dynamic>;
      final ts = (data['timestamp'] as Timestamp).toDate();
      final day = DateTime(ts.year, ts.month, ts.day);
      eventMap.putIfAbsent(day, () => []).add(data);
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: DefaultTabController(
          length: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Upcoming Meetings',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              const TabBar(
                tabs: [
                  Tab(text: 'List'),
                  Tab(text: 'Calendar'),
                ],
              ),
              SizedBox(
                height: 300,
                child: TabBarView(
                  children: [
                    _UpcomingMeetingsList(meetings: meetings, onEmail: _launchEmail),
                    _UpcomingMeetingsCalendar(events: eventMap),
                  ],
                ),
              ),
            ],
          ),
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
              itemCount: topClients.take(5).length,
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

  Widget _buildWeeklySummaryChart(
    BuildContext context,
    List<QueryDocumentSnapshot> meetings,
  ) {
    final counts = List<int>.filled(7, 0);
    final now = DateTime.now();
    for (final doc in meetings) {
      final ts = (doc.data() as Map<String, dynamic>)['timestamp'] as Timestamp;
      final date = DateTime(ts.toDate().year, ts.toDate().month, ts.toDate().day);
      final diff = now.difference(date).inDays;
      if (diff >= 0 && diff < 7) {
        counts[6 - diff]++;
      }
    }

    final bars = [
      for (int i = 0; i < 7; i++)
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: counts[i].toDouble(),
              color: Theme.of(context).primaryColor,
              width: 12,
            ),
          ],
        )
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Meetings (Last 7 Days)',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: true),
                  barGroups: bars,
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

class _UpcomingMeetingsList extends StatelessWidget {
  final List<QueryDocumentSnapshot> meetings;
  final void Function(String email) onEmail;

  const _UpcomingMeetingsList({required this.meetings, required this.onEmail});

  @override
  Widget build(BuildContext context) {
    if (meetings.isEmpty) {
      return const Center(child: Text('No upcoming meetings'));
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: meetings.length,
      itemBuilder: (context, index) {
        final meeting = meetings[index].data() as Map<String, dynamic>;
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
            onPressed: () => onEmail(meeting['clientEmail'] ?? ''),
          ),
        );
      },
    );
  }
}

class _UpcomingMeetingsCalendar extends StatefulWidget {
  final Map<DateTime, List<Map<String, dynamic>>> events;

  const _UpcomingMeetingsCalendar({required this.events});

  @override
  State<_UpcomingMeetingsCalendar> createState() => _UpcomingMeetingsCalendarState();
}

class _UpcomingMeetingsCalendarState extends State<_UpcomingMeetingsCalendar> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TableCalendar<Map<String, dynamic>>(
          firstDay: DateTime.now().subtract(const Duration(days: 365)),
          lastDay: DateTime.now().add(const Duration(days: 365)),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          eventLoader: (day) => widget.events[DateTime(day.year, day.month, day.day)] ?? [],
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          },
        ),
        if (_selectedDay != null)
          ...?widget.events[DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day)]?.map(
            (e) => ListTile(
              title: Text(e['clientName'] ?? ''),
              subtitle: Text((e['timestamp'] as Timestamp).toDate().toString().substring(0, 16)),
            ),
          ),
      ],
    );
  }
}
