import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';

final smartSuggestionServiceProvider = Provider(
  (ref) => SmartSuggestionService(),
);

class SmartSuggestionService {
  final FirebaseFirestore firestore;
  final _logger = Logger('SmartSuggestionService');

  SmartSuggestionService({FirebaseFirestore? firestore})
    : firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> checkAndPromptSmartSuggestion({
    required BuildContext context,
    required String userId,
  }) async {
    try {
      final now = DateTime.now();
      final meetings =
          await firestore
              .collection('meetings')
              .where('creatorId', isEqualTo: userId)
              .where('endTime', isLessThan: now)
              .where('suggestionShown', isEqualTo: false)
              .orderBy('endTime', descending: true)
              .limit(1)
              .get();

      if (meetings.docs.isEmpty) {
        _logger.fine('No recent meetings found for suggestions');
        return;
      }

      final doc = meetings.docs.first;
      final meeting = doc.data();

      // Prevent re-showing
      await doc.reference.update({'suggestionShown': true});
      _logger.info('Marked meeting ${doc.id} as suggestion shown');

      // Prompt user
      if (!context.mounted) return;
      showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: const Text("Repeat this meeting?"),
              content: Text(
                "You just finished '${meeting['title']}'. Would you like to reschedule or duplicate it?",
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(
                      context,
                      '/new_meeting',
                      arguments: {'prefill': meeting},
                    );
                    _logger.info('User chose to duplicate meeting ${doc.id}');
                  },
                  child: const Text("Duplicate"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(
                      context,
                      '/new_meeting',
                      arguments: {
                        'prefill': {
                          ...meeting,
                          'startTime': DateTime.now().add(
                            const Duration(days: 7),
                          ),
                          'endTime': DateTime.now().add(
                            const Duration(days: 7, hours: 1),
                          ),
                        },
                      },
                    );
                    _logger.info('User chose to reschedule meeting ${doc.id}');
                  },
                  child: const Text("Reschedule"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _logger.info(
                      'User dismissed suggestion for meeting ${doc.id}',
                    );
                  },
                  child: const Text("Dismiss"),
                ),
              ],
            ),
      );
    } catch (e, stackTrace) {
      _logger.severe('Error checking for meeting suggestions', e, stackTrace);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to check for meeting suggestions'),
        ),
      );
    }
  }
}
