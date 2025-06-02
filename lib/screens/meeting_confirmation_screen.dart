import 'package:flutter/material.dart';
import '../utils/localizations_helper.dart';

class MeetingConfirmationScreen extends StatelessWidget {
  final String appointmentId;

  const MeetingConfirmationScreen({
    super.key,
    required this.appointmentId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocalizationsHelper.getString(
            context, 'meeting_confirmation_title')),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 96,
            ),
            const SizedBox(height: 16),
            Text(
              LocalizationsHelper.getString(
                  context, 'meeting_confirmation_success'),
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '${LocalizationsHelper.getString(context, 'meeting_confirmation_id')}: $appointmentId',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Implement sharing functionality
              },
              icon: const Icon(Icons.share),
              label: Text(LocalizationsHelper.getString(
                  context, 'meeting_confirmation_share')),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: Text(LocalizationsHelper.getString(
                  context, 'meeting_confirmation_back_home')),
            ),
          ],
        ),
      ),
    );
  }
}
