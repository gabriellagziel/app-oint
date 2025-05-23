import 'package:flutter/material.dart';
import 'app_localizations.dart';

extension L10nX on AppLocalizations {
  /// Dynamic lookup for chat-flow keys.
  String translate(String key) =>
      {
        'chatWhatDoYouWant': chatWhatDoYouWant,
        'chatOptionScheduleMeeting': chatOptionScheduleMeeting,
      }[key] ??
      key;
}

extension LocalizedBuildContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
