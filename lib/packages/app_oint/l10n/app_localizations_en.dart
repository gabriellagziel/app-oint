// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  const AppLocalizationsEn();

  @override
  String get chatWhatDoYouWant => 'What would you like to do?';

  @override
  String get chatOptionScheduleMeeting => 'Schedule a meeting';

  @override
  String get chatSelectDate => 'Select a date';

  @override
  String get chatSelectTime => 'Select a time';

  @override
  String get chatFinishButton => 'Finish';

  @override
  String get chatCompleteRequired => 'Please complete all required fields';

  @override
  String get chatSummaryTitle => 'Meeting Summary';

  @override
  String get chatSummaryType => 'Type';

  @override
  String get chatSummaryWith => 'With';

  @override
  String get chatSummaryWhen => 'When';

  @override
  String get chatSummaryWhere => 'Where';

  @override
  String get chatSummaryBusiness => 'Business';

  @override
  String get chatSummaryReminder => 'Reminder';

  @override
  String get chatSummaryNotes => 'Notes';

  @override
  String get chatSignInRequired => 'Please sign in to continue';

  @override
  String get chatSuccessMessage => 'Meeting scheduled successfully';

  @override
  String get chatErrorMessage => 'An error occurred';

  @override
  String get chatTypeMessage => 'Type your message...';

  String translate(String key) {
    switch (key) {
      case 'chatWhatDoYouWant':
        return 'What would you like to do?';
      case 'chatOptionScheduleMeeting':
        return 'Schedule a Meeting';
      case 'chatSelectDate':
        return 'Select Date';
      case 'chatSelectTime':
        return 'Select Time';
      case 'chatTypeMessage':
        return 'Type your message...';
      case 'chatSignInRequired':
        return 'Please sign in to continue';
      case 'chatSuccessMessage':
        return 'Meeting created successfully';
      case 'chatErrorMessage':
        return 'Failed to create meeting';
      case 'chatFinishButton':
        return 'Finish';
      case 'chatCompleteRequired':
        return 'Please complete all required fields';
      case 'chatSummaryTitle':
        return 'Meeting Summary';
      case 'chatSummaryType':
        return 'Type';
      case 'chatSummaryWith':
        return 'With';
      case 'chatSummaryWhen':
        return 'When';
      case 'chatSummaryWhere':
        return 'Where';
      case 'chatSummaryBusiness':
        return 'Business';
      case 'chatSummaryReminder':
        return 'Reminder';
      case 'chatSummaryNotes':
        return 'Notes';
      default:
        return key;
    }
  }
}
