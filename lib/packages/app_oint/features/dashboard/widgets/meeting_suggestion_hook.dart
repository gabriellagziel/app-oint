import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_oint/features/meetings/services/smart_suggestion_service.dart';
import 'package:logging/logging.dart';

class MeetingSuggestionHook extends ConsumerStatefulWidget {
  final String userId;
  const MeetingSuggestionHook({super.key, required this.userId});

  @override
  ConsumerState<MeetingSuggestionHook> createState() =>
      _MeetingSuggestionHookState();
}

class _MeetingSuggestionHookState extends ConsumerState<MeetingSuggestionHook> {
  final _logger = Logger('MeetingSuggestionHook');
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    _checkForSuggestions();
  }

  Future<void> _checkForSuggestions() async {
    if (_isChecking) return;
    _isChecking = true;

    try {
      await ref
          .read(smartSuggestionServiceProvider)
          .checkAndPromptSmartSuggestion(
            context: context,
            userId: widget.userId,
          );
    } catch (e, stackTrace) {
      _logger.severe('Error checking for meeting suggestions', e, stackTrace);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to check for meeting suggestions'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isChecking = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
