import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:csv/csv.dart';
import '../models/client_stats.dart';

class ClientStatsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<List<ClientStats>> getClientStats() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('clients')
        .orderBy('lastSeen', descending: true)
        .limit(20)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ClientStats.fromFirestore(doc))
          .toList();
    });
  }

  Future<void> updateClientTags(String clientId, List<String> tags) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('clients')
        .doc(clientId)
        .update({'tags': tags});
  }

  Future<void> markClientLate(String clientId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    final clientRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('clients')
        .doc(clientId);

    await _firestore.runTransaction((transaction) async {
      final doc = await transaction.get(clientRef);
      if (!doc.exists) return;

      final data = doc.data() as Map<String, dynamic>;
      final lateCount = (data['joinedLateCount'] as int? ?? 0) + 1;
      final tags = List<String>.from(data['tags'] ?? []);

      if (lateCount >= 2 && !tags.contains('Late')) {
        tags.add('Late');
      }

      transaction.update(clientRef, {
        'joinedLateCount': lateCount,
        'tags': tags,
      });
    });
  }

  Future<void> shareBookingLink(String clientId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    final bookingLink = 'https://app-oint.web.app/book/$userId/$clientId';
    await SharePlus.instance.share(
      ShareParams(
        text: bookingLink,
      ),
    );
  }

  Future<void> sendWhatsApp(String phone) async {
    if (phone.isEmpty) throw Exception('Phone number is required');

    final whatsappUrl = Uri.parse('https://wa.me/$phone');
    if (await canLaunchUrl(whatsappUrl)) {
      await launchUrl(whatsappUrl);
    } else {
      throw Exception('Could not launch WhatsApp');
    }
  }

  Future<void> sendEmail(String email) async {
    if (email.isEmpty) throw Exception('Email is required');

    final emailUrl = Uri.parse('mailto:$email');
    if (await canLaunchUrl(emailUrl)) {
      await launchUrl(emailUrl);
    } else {
      throw Exception('Could not launch email client');
    }
  }

  Future<String> exportClientData(String clientId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    final doc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('clients')
        .doc(clientId)
        .get();

    if (!doc.exists) throw Exception('Client not found');

    final data = doc.data() as Map<String, dynamic>;
    final bookings = await _firestore
        .collection('bookings')
        .where('clientId', isEqualTo: clientId)
        .get();

    final csvData = [
      ['Client Information'],
      ['Name', data['name'] ?? ''],
      ['Email', data['email'] ?? ''],
      ['Phone', data['phone'] ?? ''],
      ['Tags', (data['tags'] as List<dynamic>?)?.join(', ') ?? ''],
      [''],
      ['Booking History'],
      ['Date', 'Time', 'Status', 'Notes'],
      ...bookings.docs.map((booking) {
        final bookingData = booking.data();
        final date = (bookingData['scheduledTime'] as Timestamp).toDate();
        return [
          '${date.year}-${date.month}-${date.day}',
          '${date.hour}:${date.minute}',
          bookingData['status'] ?? '',
          bookingData['notes'] ?? '',
        ];
      }),
    ];

    return const ListToCsvConverter().convert(csvData);
  }
}
