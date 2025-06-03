import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ChildAppointmentsScreen extends StatelessWidget {
  final String childUid;

  const ChildAppointmentsScreen({super.key, required this.childUid});

  @override
  Widget build(BuildContext context) {
    final appointmentsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(childUid)
        .collection('appointments')
        .orderBy('startTime');

    return Scaffold(
      appBar: AppBar(title: const Text('Child\'s Appointments')),
      body: StreamBuilder<QuerySnapshot>(
        stream: appointmentsRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Error loading appointments."));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No appointments found."));
          }

          final appointments = snapshot.data!.docs;

          return ListView.builder(
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              final data = appointments[index].data() as Map<String, dynamic>;
              final title = data['title'] ?? 'Untitled';
              final startTime = (data['startTime'] as Timestamp).toDate();
              final endTime =
                  data['endTime'] != null
                      ? (data['endTime'] as Timestamp).toDate()
                      : null;
              final status = data['status'] ?? 'scheduled';
              final location = data['location'] ?? 'No location specified';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: _getStatusIcon(status),
                  title: Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${DateFormat('MMM d, y').format(startTime)} at ${DateFormat('h:mm a').format(startTime)}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      if (endTime != null)
                        Text(
                          'Ends: ${DateFormat('h:mm a').format(endTime)}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      Text(location, style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                  trailing: _getStatusChip(status),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _getStatusIcon(String status) {
    IconData iconData;
    Color color;

    switch (status.toLowerCase()) {
      case 'completed':
        iconData = Icons.check_circle;
        color = Colors.green;
        break;
      case 'cancelled':
        iconData = Icons.cancel;
        color = Colors.red;
        break;
      case 'rescheduled':
        iconData = Icons.update;
        color = Colors.orange;
        break;
      default:
        iconData = Icons.event;
        color = Colors.blue;
    }

    return Icon(iconData, color: color);
  }

  Widget _getStatusChip(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'completed':
        color = Colors.green;
        break;
      case 'cancelled':
        color = Colors.red;
        break;
      case 'rescheduled':
        color = Colors.orange;
        break;
      default:
        color = Colors.blue;
    }

    return Chip(
      label: Text(
        status.toUpperCase(),
        style: const TextStyle(color: Colors.white, fontSize: 10),
      ),
      backgroundColor: color,
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
