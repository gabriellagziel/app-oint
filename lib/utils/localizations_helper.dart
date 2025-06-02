import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

/// Helper class for handling localizations throughout the app
class LocalizationsHelper {
  /// Get the current [AppLocalizations] instance from the context
  static AppLocalizations of(BuildContext context) {
    return AppLocalizations.of(context)!;
  }

  /// Get a localized string for a given key
  static String getString(BuildContext context, String key) {
    final localizations = of(context);
    // Add your localization keys here
    switch (key) {
      case 'contacts_permission_required':
        return localizations.contactsPermissionRequired;
      case 'contacts_permission_denied':
        return localizations.contactsPermissionDenied;
      case 'contacts_permission_permanently_denied':
        return localizations.contactsPermissionPermanentlyDenied;
      case 'contact_not_found':
        return localizations.contactNotFound;
      case 'invalid_contact_id':
        return localizations.invalidContactId;
      case 'invalid_search_query':
        return localizations.invalidSearchQuery;
      default:
        return key;
    }
  }

  /// Format a date using the current locale
  static String formatDate(BuildContext context, DateTime date) {
    return DateFormat.yMMMd().format(date);
  }

  /// Format a time using the current locale
  static String formatTime(BuildContext context, DateTime time) {
    return DateFormat.jm().format(time);
  }
}
