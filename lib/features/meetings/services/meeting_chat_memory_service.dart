import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logging/logging.dart';

final _logger = Logger('MeetingChatMemoryService');

final meetingChatMemoryServiceProvider = Provider((ref) {
  return MeetingChatMemoryService();
});

class MeetingChatMemoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Map<String, String> _previousChoices = {};

  Future<void> saveChoice(String userId, String stepId, String value) async {
    _previousChoices[stepId] = value;

    try {
      await _firestore
          .collection('user_preferences')
          .doc(userId)
          .collection('meeting_choices')
          .doc(stepId)
          .set({'value': value, 'updatedAt': FieldValue.serverTimestamp()});
    } catch (e) {
      // Log error but don't throw - we still have in-memory cache
      _logger.info('Failed to persist choice: $e');
    }
  }

  Future<String?> getSuggestedValue(String userId, String stepId) async {
    // Return cached value if available
    if (_previousChoices.containsKey(stepId)) {
      return _previousChoices[stepId];
    }

    try {
      final doc =
          await _firestore
              .collection('user_preferences')
              .doc(userId)
              .collection('meeting_choices')
              .doc(stepId)
              .get();

      if (doc.exists) {
        final value = doc.data()?['value'] as String?;
        if (value != null) {
          _previousChoices[stepId] = value;
        }
        return value;
      }
    } catch (e) {
      _logger.info('Failed to fetch suggested value: $e');
    }

    return null;
  }

  Future<void> clearMemory(String userId) async {
    _previousChoices.clear();

    try {
      final batch = _firestore.batch();
      final choices =
          await _firestore
              .collection('user_preferences')
              .doc(userId)
              .collection('meeting_choices')
              .get();

      for (var doc in choices.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      _logger.info('Failed to clear memory: $e');
    }
  }
}
