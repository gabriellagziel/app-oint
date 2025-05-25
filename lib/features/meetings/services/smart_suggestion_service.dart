import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:clock/clock.dart';
import 'package:firebase_auth/firebase_auth.dart';

final smartSuggestionServiceProvider = Provider(
  (ref) => SmartSuggestionService(firestore: FirebaseFirestore.instance),
);

class SmartSuggestionService {
  final FirebaseFirestore _firestore;
  final Clock _clock;
  final _logger = Logger('SmartSuggestionService');

  SmartSuggestionService({
    required FirebaseFirestore firestore,
    Clock? clock,
  })  : _firestore = firestore,
        _clock = clock ?? const Clock();

  Future<void> maybeShowRepeatMeetingDialog(
      BuildContext context, User user) async {
    final now = _clock.now();
    final threshold = now.subtract(const Duration(days: 1));
    print('🔍 Service triggered at $now for user: ${user.uid}');

    try {
      final snapshot = await _firestore
          .collection('meetings')
          .where('creatorId', isEqualTo: user.uid)
          .where('endTime', isLessThan: now)
          .where('suggestionShown', isEqualTo: false)
          .orderBy('endTime', descending: true)
          .limit(5)
          .get();

      print('📦 Firestore query returned ${snapshot.docs.length} docs');

      for (final doc in snapshot.docs) {
        final data = doc.data();
        print('📝 Meeting doc data: $data');

        final title = data['title'] as String? ?? '';
        final endTime = (data['endTime'] as Timestamp).toDate();
        print('🕒 Parsed endTime: $endTime (threshold: $threshold)');

        if (endTime.isBefore(threshold)) {
          print('⏳ Skipped: meeting too old');
          continue;
        }
        if (title.isEmpty) {
          print('⚠️ Skipping — no title');
          continue;
        }

        final suggestionId = '${user.uid}::${doc.id}';
        final logDoc = await _firestore
            .collection('suggestion_logs')
            .doc(suggestionId)
            .get();
        print('📄 Suggestion log exists: ${logDoc.exists}');

        if (logDoc.exists) {
          print('🚫 Skipped: suggestion already shown');
          continue;
        }

        try {
          await doc.reference.update({'suggestionShown': true});
          await _firestore
              .collection('suggestion_logs')
              .doc(suggestionId)
              .set({'timestamp': now});
          print('✅ Marked suggestion as shown for $suggestionId');
        } catch (e) {
          print('🛑 Firestore update failed: $e');
        }

        if (!context.mounted) {
          print('❌ Context not mounted — aborting');
          return;
        }

        print('🟡 Showing dialog for title: $title');

        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Repeat this meeting?'),
            content: Text('You met recently for "$title". Want to repeat it?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Dismiss'),
              )
            ],
          ),
        );

        print('🟢 Dialog displayed successfully');
        break; // show only one suggestion
      }
    } catch (e, stack) {
      print('❗ Unexpected failure: $e');
      print(stack);
    }
  }
}
