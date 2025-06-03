import 'package:googleapis/calendar/v3.dart' as cal;
import 'package:googleapis_auth/auth_io.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';

class CalendarSyncService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  CalendarSyncService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  static const _scopes = [cal.CalendarApi.calendarScope];

  /// Launches OAuth consent and saves credentials in memory (or persistent storage in next phase)
  Future<AutoRefreshingAuthClient?> _authorize(BuildContext context) async {
    final clientId =
        ClientId('<YOUR_GOOGLE_CLIENT_ID>', null); // Web App OAuth Client
    try {
      return await clientViaUserConsent(clientId, _scopes, (url) async {
        if (await canLaunchUrl(Uri.parse(url))) {
          await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
        } else {
          throw Exception('Could not launch consent URL');
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Calendar sync failed: $e')),
      );
      return null;
    }
  }

  /// Called after user accepts invite to sync it to their calendar
  Future<void> syncMeetingToGoogleCalendar({
    required String meetingId,
    required BuildContext context,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    final meetingDoc =
        await _firestore.collection('meetings').doc(meetingId).get();
    if (!meetingDoc.exists) throw Exception('Meeting not found');

    if (meetingDoc['syncedToCalendar'] == true) {
      print('🟡 Already synced');
      return;
    }

    final title = meetingDoc['title'] ?? 'Meeting';
    final start = (meetingDoc['startTime'] as Timestamp).toDate();
    final end = (meetingDoc['endTime'] as Timestamp).toDate();

    final authClient = await _authorize(context);
    if (authClient == null) return;

    final calendar = cal.CalendarApi(authClient);
    final event = cal.Event()
      ..summary = title
      ..start = cal.EventDateTime(dateTime: start, timeZone: 'UTC')
      ..end = cal.EventDateTime(dateTime: end, timeZone: 'UTC');

    await calendar.events.insert(event, "primary");
    await _firestore.collection('meetings').doc(meetingId).update({
      'syncedToCalendar': true,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Meeting synced to Google Calendar')),
    );
  }
}
