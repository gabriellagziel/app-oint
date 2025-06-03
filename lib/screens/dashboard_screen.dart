import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:app_oint9/providers/dashboard_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:csv/csv.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  String _selectedTimeRange = 'this_week';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.dashboard),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: _exportToCsv,
            tooltip: l10n.exportToCsv,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            ref.refresh(dashboardStatsProvider.future),
            ref.refresh(inactiveClientsProvider.future),
            ref.refresh(topClientsProvider.future),
          ]);
        },
        child: const SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16),
              SizedBox(height: 24),
              SizedBox(height: 24),
              SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeRangeSelector(AppLocalizations l10n) {
    return SegmentedButton<String>(
      segments: const [
        ButtonSegment(
          value: 'this_week',
          label: Text('This Week'),
        ),
        ButtonSegment(
          value: 'last_30_days',
          label: Text('Last 30 Days'),
        ),
        ButtonSegment(
          value: 'all_time',
          label: Text('All Time'),
        ),
      ],
      selected: {_selectedTimeRange},
      onSelectionChanged: (Set<String> selection) {
        setState(() {
          _selectedTimeRange = selection.first;
        });
      },
    );
  }

  Widget _buildStatsCards(AppLocalizations l10n) {
    return Consumer(
      builder: (context, ref, child) {
        final statsAsync = ref.watch(dashboardStatsProvider);

        return statsAsync.when(
          data: (stats) => GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.5,
            children: [
              _StatCard(
                title: l10n.totalMeetingsLastMonth,
                value: stats.totalMeetingsLastMonth.toString(),
                icon: Icons.calendar_today,
              ),
              _StatCard(
                title: l10n.newClients,
                value: stats.newClients.toString(),
                icon: Icons.person_add,
              ),
              _StatCard(
                title: l10n.returningClients,
                value: stats.returningClients.toString(),
                icon: Icons.people,
              ),
              _StatCard(
                title: l10n.inactiveClients,
                value: stats.inactiveClients.toString(),
                icon: Icons.person_off,
              ),
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => const Center(
            child: Text('Error:'),
          ),
        );
      },
    );
  }

  Widget _buildMeetingsChart(AppLocalizations l10n) {
    return Consumer(
      builder: (context, ref, child) {
        final statsAsync = ref.watch(dashboardStatsProvider);

        return statsAsync.when(
          data: (stats) => Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.meetingsPerWeek,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: stats.weeklyMeetings
                                .map((e) => e.meetingCount.toDouble())
                                .reduce((a, b) => a > b ? a : b) *
                            1.2,
                        barGroups:
                            stats.weeklyMeetings.asMap().entries.map((entry) {
                          return BarChartGroupData(
                            x: entry.key,
                            barRods: [
                              BarChartRodData(
                                toY: entry.value.meetingCount.toDouble(),
                                color: Theme.of(context).colorScheme.primary,
                                width: 20,
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(4),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final date = stats
                                    .weeklyMeetings[value.toInt()].weekStart;
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    '${date.day}/${date.month}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                );
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                            ),
                          ),
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        gridData: FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => const Center(
            child: Text('Error:'),
          ),
        );
      },
    );
  }

  Widget _buildInactiveClientsTable(AppLocalizations l10n) {
    return Consumer(
      builder: (context, ref, child) {
        final inactiveClientsAsync = ref.watch(inactiveClientsProvider);

        return inactiveClientsAsync.when(
          data: (clients) => Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.inactiveClients,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  if (clients.isEmpty)
                    Center(
                      child: Text(l10n.noInactiveClients),
                    )
                  else
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: [
                          DataColumn(label: Text(l10n.name)),
                          DataColumn(label: Text(l10n.email)),
                          DataColumn(label: Text(l10n.phone)),
                          DataColumn(label: Text(l10n.actions)),
                        ],
                        rows: clients.map((client) {
                          return DataRow(
                            cells: [
                              DataCell(Text(client.name)),
                              DataCell(Text(client.email)),
                              DataCell(Text(client.phone)),
                              DataCell(Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.message),
                                    onPressed: () =>
                                        _launchWhatsApp(client.phone),
                                    tooltip: l10n.sendWhatsApp,
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.email),
                                    onPressed: () => _launchEmail(client.email),
                                    tooltip: l10n.sendEmail,
                                  ),
                                ],
                              )),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                ],
              ),
            ),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => const Center(
            child: Text('Error:'),
          ),
        );
      },
    );
  }

  Widget _buildTopClientsLeaderboard(AppLocalizations l10n) {
    return Consumer(
      builder: (context, ref, child) {
        final topClientsAsync = ref.watch(topClientsProvider);

        return topClientsAsync.when(
          data: (clients) => Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.topClients,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  if (clients.isEmpty)
                    Center(
                      child: Text(l10n.noClients),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: clients.length,
                      itemBuilder: (context, index) {
                        final client = clients[index];
                        return ListTile(
                          leading: const CircleAvatar(
                            child: Text(''),
                          ),
                          title: Text(client.name),
                          subtitle: Text(client.email),
                          trailing: Text(
                            '${client.meetingCount} ${l10n.meetings}',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => const Center(
            child: Text('Error:'),
          ),
        );
      },
    );
  }

  Future<void> _launchWhatsApp(String phone) async {
    final url = Uri.parse('https://wa.me/$phone');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  Future<void> _launchEmail(String email) async {
    final url = Uri.parse('mailto:$email');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  Future<void> _exportToCsv() async {
    final clientsAsync = ref.read(inactiveClientsProvider);
    final clients = clientsAsync.value;

    if (clients == null) return;

    final csvData = [
      const ['Name', 'Email', 'Phone', 'Meeting Count', 'Status'],
      ...clients.map((client) => [
            client.name,
            client.email,
            client.phone,
            client.meetingCount.toString(),
            client.status.toString(),
          ]),
    ];

    final csv = const ListToCsvConverter().convert(csvData);
    await Share.share(csv, subject: 'Dashboard Export');
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
