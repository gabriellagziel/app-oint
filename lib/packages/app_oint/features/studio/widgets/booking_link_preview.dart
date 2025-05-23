import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BookingLinkPreview extends StatelessWidget {
  final String title;
  final DateTime scheduledTime;
  final String? location;
  final String? notes;

  const BookingLinkPreview({
    super.key,
    required this.title,
    required this.scheduledTime,
    this.location,
    this.notes,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.1 * 255).round()),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 16),
              const SizedBox(width: 8),
              Text(
                DateFormat.yMMMd().format(scheduledTime),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.access_time, size: 16),
              const SizedBox(width: 8),
              Text(
                DateFormat.jm().format(scheduledTime),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          if (location != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    location!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ],
          if (notes != null) ...[
            const SizedBox(height: 16),
            Text('Notes:', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 4),
            Text(notes!, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }
}
