import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/client_stats_service.dart';
import '../models/client_stats.dart';

final clientStatsServiceProvider = Provider((ref) => ClientStatsService());

final clientStatsProvider = StreamProvider<List<ClientStats>>((ref) {
  final service = ref.watch(clientStatsServiceProvider);
  return service.getClientStats();
});
