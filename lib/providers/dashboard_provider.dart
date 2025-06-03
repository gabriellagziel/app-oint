import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_oint9/models/client.dart';
import 'package:app_oint9/models/dashboard_stats.dart';

final dashboardStatsProvider = FutureProvider<DashboardStats>((ref) async {
  final now = DateTime.now();
  final lastMonth = now.subtract(const Duration(days: 30));

  // Get all clients
  final clientsSnapshot =
      await FirebaseFirestore.instance.collection('clients').get();

  final clients =
      clientsSnapshot.docs.map((doc) => Client.fromJson(doc.data())).toList();

  // Calculate statistics
  final totalMeetingsLastMonth = clients
      .where((client) => client.lastMeetingDate.isAfter(lastMonth))
      .length;

  final newClients =
      clients.where((client) => client.status == ClientStatus.new_).length;

  final returningClients =
      clients.where((client) => client.status == ClientStatus.active).length;

  final inactiveClients =
      clients.where((client) => client.status == ClientStatus.inactive).length;

  // Get weekly meetings data
  final weeklyMeetings = <WeeklyMeetingData>[];
  for (int i = 5; i >= 0; i--) {
    final weekStart = now.subtract(Duration(days: i * 7));
    final weekEnd = weekStart.add(const Duration(days: 7));

    final meetingsInWeek = clients
        .where((client) =>
            client.lastMeetingDate.isAfter(weekStart) &&
            client.lastMeetingDate.isBefore(weekEnd))
        .length;

    weeklyMeetings.add(WeeklyMeetingData(
      weekStart: weekStart,
      meetingCount: meetingsInWeek,
    ));
  }

  return DashboardStats(
    totalMeetingsLastMonth: totalMeetingsLastMonth,
    newClients: newClients,
    returningClients: returningClients,
    inactiveClients: inactiveClients,
    weeklyMeetings: weeklyMeetings,
  );
});

final inactiveClientsProvider = FutureProvider<List<Client>>((ref) async {
  final clientsSnapshot = await FirebaseFirestore.instance
      .collection('clients')
      .where('status', isEqualTo: 'inactive')
      .get();

  return clientsSnapshot.docs
      .map((doc) => Client.fromJson(doc.data()))
      .toList();
});

final topClientsProvider = FutureProvider<List<Client>>((ref) async {
  final clientsSnapshot = await FirebaseFirestore.instance
      .collection('clients')
      .orderBy('meetingCount', descending: true)
      .limit(10)
      .get();

  return clientsSnapshot.docs
      .map((doc) => Client.fromJson(doc.data()))
      .toList();
});
