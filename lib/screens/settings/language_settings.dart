import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

class LanguageSettings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DropdownButton<Locale>(
      value: Localizations.localeOf(context),
      items: AppLocalizations.supportedLocales.map((locale) {
        return DropdownMenuItem(
          value: locale,
          child: Text(
            Intl.estimatedLocaleName(locale.languageCode),
          ),
        );
      }).toList(),
      onChanged: (locale) async {
        // Save override using SharedPreferences or Provider
      },
    );
  }
} 