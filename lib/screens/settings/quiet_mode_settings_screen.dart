import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:app_oint9/providers/quiet_mode_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class QuietModeSettingsScreen extends ConsumerWidget {
  const QuietModeSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quietMode = ref.watch(quietModeProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.quietModeTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: Text(l10n.quietModeTitle),
            subtitle: Text(l10n.quietModeDescription),
            value: quietMode.enabled,
            onChanged: (value) =>
                ref.read(quietModeProvider.notifier).setEnabled(value),
          ),
          if (quietMode.enabled) ...[
            const SizedBox(height: 16),
            DropdownButtonFormField<Duration>(
              decoration: InputDecoration(
                labelText: l10n.quietModeDuration,
                border: const OutlineInputBorder(),
              ),
              value: quietMode.duration,
              items: [
                DropdownMenuItem(
                  value: const Duration(minutes: 30),
                  child: Text(l10n.thirtyMinutes),
                ),
                DropdownMenuItem(
                  value: const Duration(hours: 1),
                  child: Text(l10n.oneHour),
                ),
                DropdownMenuItem(
                  value: const Duration(hours: 24),
                  child: Text(l10n.untilTomorrow),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  ref.read(quietModeProvider.notifier).setDuration(value);
                }
              },
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.quietModeEndsAt,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      DateFormat('HH:mm').format(quietMode.quietUntil),
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => ref.read(quietModeProvider.notifier).disable(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text(l10n.cancelQuietMode),
            ),
          ],
        ],
      ),
    );
  }
}
