import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/booking_link_providers.dart';
import '../widgets/booking_link_dialog.dart';
import '../widgets/booking_link_preview.dart';

class BookingLinksScreen extends ConsumerWidget {
  const BookingLinksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(child: Text('Please sign in to view booking links'));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Links'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const BookingLinkDialog(),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('bookingLinks')
                .where('studioId', isEqualTo: user.uid)
                .orderBy('createdAt', descending: true)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final links = snapshot.data?.docs ?? [];

          if (links.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('No booking links yet'),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => const BookingLinkDialog(),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Create Booking Link'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: links.length,
            itemBuilder: (context, index) {
              final link = links[index];
              final data = link.data() as Map<String, dynamic>;
              final title = data['title'] as String;
              final scheduledTime =
                  (data['scheduledTime'] as Timestamp).toDate();
              final location = data['location'] as String?;
              final notes = data['notes'] as String?;
              final status = data['status'] as String;

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    BookingLinkPreview(
                      title: title,
                      scheduledTime: scheduledTime,
                      location: location,
                      notes: notes,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Chip(
                            label: Text(status.toUpperCase()),
                            backgroundColor:
                                status == 'pending'
                                    ? Colors.blue.withAlpha((0.1 * 255).round())
                                    : status == 'confirmed'
                                    ? Colors.green.withAlpha(
                                      (0.1 * 255).round(),
                                    )
                                    : Colors.red.withAlpha((0.1 * 255).round()),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.share),
                                onPressed: () {
                                  ref
                                      .read(bookingLinkServiceProvider)
                                      .shareBookingLink(link.id);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.message),
                                onPressed: () {
                                  ref
                                      .read(bookingLinkServiceProvider)
                                      .shareViaWhatsApp(link.id);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => const BookingLinkDialog(),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
