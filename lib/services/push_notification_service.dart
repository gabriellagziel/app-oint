import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

class PushNotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // Request permissions
    await _fcm.requestPermission();
    final token = await _fcm.getToken();
    if (token == null) return;

    final uid = _auth.currentUser?.uid;
    if (uid != null) {
      await _firestore.collection('users').doc(uid).update({
        'fcmToken': token,
      });
    }

    // iOS / Android config
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const initSettings =
        InitializationSettings(android: androidSettings, iOS: iosSettings);

    await _localNotifications.initialize(initSettings);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      if (notification != null) {
        _localNotifications.show(
          notification.hashCode,
          notification.title,
          notification.body,
          const NotificationDetails(
            android: AndroidNotificationDetails('default_channel', 'Default',
                importance: Importance.high, priority: Priority.high),
          ),
        );
      }
    });
  }

  /// Sends a push notification to a specific user by UID
  Future<void> sendToUser({
    required String toUid,
    required String title,
    required String body,
  }) async {
    final doc = await _firestore.collection('users').doc(toUid).get();
    final token = doc.data()?['fcmToken'];
    if (token == null) return;

    final configDoc =
        await _firestore.collection('config').doc('notifications').get();
    if (configDoc.exists && configDoc.data()?['enabled'] == false) {
      print('🔕 Notifications disabled via config.');
      return;
    }

    await _firestore.collection('push_queue').add({
      'to': token,
      'title': title,
      'body': body,
      'sent': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
