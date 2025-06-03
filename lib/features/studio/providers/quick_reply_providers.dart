import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/quick_reply_service.dart';
import '../models/quick_reply_template.dart';

final quickReplyServiceProvider = Provider((ref) => QuickReplyService());

final quickReplyTemplatesProvider = StreamProvider<List<QuickReplyTemplate>>((
  ref,
) {
  final service = ref.watch(quickReplyServiceProvider);
  return service.getTemplates();
});
