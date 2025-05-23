import 'package:flutter/material.dart';
import 'app_localizations_en.dart';

abstract class AppLocalizations {
  const AppLocalizations();

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  String get chatWhatDoYouWant;
  String get chatOptionScheduleMeeting;
  String get chatSelectDate;
  String get chatSelectTime;
  String get chatFinishButton;
  String get chatCompleteRequired;
  String get chatSummaryTitle;
  String get chatSummaryType;
  String get chatSummaryWith;
  String get chatSummaryWhen;
  String get chatSummaryWhere;
  String get chatSummaryBusiness;
  String get chatSummaryReminder;
  String get chatSummaryNotes;
  String get chatSignInRequired;
  String get chatSuccessMessage;
  String get chatErrorMessage;
  String get chatTypeMessage;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    switch (locale.languageCode) {
      case 'en':
        return const AppLocalizationsEn();
      default:
        return const AppLocalizationsEn();
    }
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
