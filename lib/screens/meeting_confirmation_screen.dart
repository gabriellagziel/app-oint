import 'package:flutter/material.dart';

class MeetingConfirmationScreen extends StatelessWidget {
  final String appointmentId;

  const MeetingConfirmationScreen({
    Key? key,
    required this.appointmentId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm Meeting'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Appointment ID: $appointmentId'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // TODO: Save meeting and navigate back
                Navigator.of(context).pop();
              },
              child: const Text('Confirm & Save'),
            ),
          ],
        ),
      ),
    );
  }
}
