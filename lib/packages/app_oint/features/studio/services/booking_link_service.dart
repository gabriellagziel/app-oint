import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class BookingLinkService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> generateBookingLink({
    required String title,
    required DateTime scheduledTime,
    String? location,
    String? notes,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final studioDoc = await _firestore
        .collection('studios')
        .where('userId', isEqualTo: user.uid)
        .get();

    if (studioDoc.docs.isEmpty) {
      throw Exception('Studio not found');
    }

    final studioId = studioDoc.docs.first.id;
    final bookingData = {
      'title': title,
      'scheduledTime': scheduledTime,
      'location': location,
      'notes': notes,
      'studioId': studioId,
      'createdAt': FieldValue.serverTimestamp(),
      'status': 'pending',
    };

    final docRef = await _firestore.collection('bookingLinks').add(bookingData);
    return docRef.id;
  }

  Future<void> shareBookingLink(String bookingId) async {
    final bookingDoc =
        await _firestore.collection('bookingLinks').doc(bookingId).get();

    if (!bookingDoc.exists) {
      throw Exception('Booking link not found');
    }

    final bookingData = bookingDoc.data()!;
    final title = bookingData['title'] as String;
    final scheduledTime = (bookingData['scheduledTime'] as Timestamp).toDate();
    final location = bookingData['location'] as String?;
    final notes = bookingData['notes'] as String?;

    final message = _generateShareMessage(
      title: title,
      scheduledTime: scheduledTime,
      location: location,
      notes: notes,
    );

    await SharePlus.instance.share(
      ShareParams(
        text: message,
      ),
    );
  }

  Future<void> shareViaWhatsApp(String bookingId) async {
    final bookingDoc =
        await _firestore.collection('bookingLinks').doc(bookingId).get();

    if (!bookingDoc.exists) {
      throw Exception('Booking link not found');
    }

    final bookingData = bookingDoc.data()!;
    final title = bookingData['title'] as String;
    final scheduledTime = (bookingData['scheduledTime'] as Timestamp).toDate();
    final location = bookingData['location'] as String?;
    final notes = bookingData['notes'] as String?;

    final message = _generateShareMessage(
      title: title,
      scheduledTime: scheduledTime,
      location: location,
      notes: notes,
    );

    final whatsappUrl = Uri.parse(
      'whatsapp://send?text=${Uri.encodeComponent(message)}',
    );

    if (await canLaunchUrl(whatsappUrl)) {
      await launchUrl(whatsappUrl);
    } else {
      throw Exception('Could not launch WhatsApp');
    }
  }

  String _generateShareMessage({
    required String title,
    required DateTime scheduledTime,
    String? location,
    String? notes,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('Booking Details:');
    buffer.writeln('Title: $title');
    buffer.writeln('Date: ${scheduledTime.toString().split(' ')[0]}');
    buffer.writeln(
      'Time: ${scheduledTime.toString().split(' ')[1].substring(0, 5)}',
    );

    if (location != null) {
      buffer.writeln('Location: $location');
    }

    if (notes != null) {
      buffer.writeln('Notes: $notes');
    }

    return buffer.toString();
  }
}
