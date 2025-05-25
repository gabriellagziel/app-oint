import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends ConsumerState<NotificationSettingsScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  bool _isLoading = true;
  Map<String, bool> _settings = {};

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('settings')
          .doc('notifications')
          .get();

      if (doc.exists) {
        setState(() {
          _settings = Map<String, bool>.from(doc.data() ?? {});
          _isLoading = false;
        });
      } else {
        // Set default values
        setState(() {
          _settings = {
            'pre_meeting_reminders': true,
            'late_notifications': true,
            'meeting_updates': true,
            'daily_digest': false,
          };
          _isLoading = false;
        });
        await _saveSettings();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading settings: $e')),
        );
      }
    }
  }

  Future<void> _saveSettings() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('settings')
          .doc('notifications')
          .set(_settings);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Settings saved')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving settings: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Pre-meeting Reminders'),
            subtitle: const Text('Get notified before meetings start'),
            value: _settings['pre_meeting_reminders'] ?? true,
            onChanged: (value) {
              setState(() {
                _settings['pre_meeting_reminders'] = value;
              });
              _saveSettings();
            },
          ),
          SwitchListTile(
            title: const Text('Late Notifications'),
            subtitle: const Text('Get notified when participants are late'),
            value: _settings['late_notifications'] ?? true,
            onChanged: (value) {
              setState(() {
                _settings['late_notifications'] = value;
              });
              _saveSettings();
            },
          ),
          SwitchListTile(
            title: const Text('Meeting Updates'),
            subtitle: const Text('Get notified about meeting changes'),
            value: _settings['meeting_updates'] ?? true,
            onChanged: (value) {
              setState(() {
                _settings['meeting_updates'] = value;
              });
              _saveSettings();
            },
          ),
          SwitchListTile(
            title: const Text('Daily Digest'),
            subtitle: const Text('Get a daily summary of your meetings'),
            value: _settings['daily_digest'] ?? false,
            onChanged: (value) {
              setState(() {
                _settings['daily_digest'] = value;
              });
              _saveSettings();
            },
          ),
        ],
      ),
    );
  }
}
