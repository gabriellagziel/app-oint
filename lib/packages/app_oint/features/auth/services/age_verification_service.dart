import 'package:intl/intl.dart';

/// Enum representing the age status of a user
enum AgeStatus {
  /// User is under 13 years old and blocked from registration
  underageBlocked,

  /// User is between 13-17 years old and requires parental consent
  minorNeedsConsent,

  /// User is 18 or older and can register without restrictions
  legalUser,
}

/// Service for handling age verification and parental consent requirements
class AgeVerificationService {
  /// Returns [AgeStatus] based on user's birthdate
  static AgeStatus getAgeStatus(DateTime birthDate) {
    final now = DateTime.now();
    final age =
        now.year -
        birthDate.year -
        ((now.month < birthDate.month ||
                (now.month == birthDate.month && now.day < birthDate.day))
            ? 1
            : 0);

    if (age < 13) return AgeStatus.underageBlocked;
    if (age < 18) return AgeStatus.minorNeedsConsent;
    return AgeStatus.legalUser;
  }

  /// Converts string (YYYY-MM-DD) to DateTime safely
  static DateTime? parseBirthDate(String birthdateString) {
    try {
      return DateFormat('yyyy-MM-dd').parseStrict(birthdateString);
    } catch (_) {
      return null;
    }
  }

  /// Validates if a birthdate string is in the correct format (YYYY-MM-DD)
  static bool isValidBirthdateFormat(String birthdateString) {
    return parseBirthDate(birthdateString) != null;
  }

  /// Formats a DateTime to YYYY-MM-DD string
  static String formatBirthdate(DateTime birthdate) {
    return DateFormat('yyyy-MM-dd').format(birthdate);
  }
}
