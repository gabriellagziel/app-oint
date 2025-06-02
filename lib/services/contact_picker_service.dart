import 'package:flutter_contacts/flutter_contacts.dart';

/// Types of errors that can occur in the contact picker service
enum ContactPickerErrorType {
  permissionDenied,
  permissionPermanentlyDenied,
  contactNotFound,
  contactLoadFailed,
  searchFailed,
  invalidInput,
  unknown
}

/// Custom exception for contact picker service with structured error information
class ContactPickerError implements Exception {
  final String message;
  final String? details;
  final ContactPickerErrorType type;
  final dynamic originalError;

  ContactPickerError(
    this.message,
    this.type, {
    this.details,
    this.originalError,
  });

  @override
  String toString() {
    final errorInfo = [
      'Type: $type',
      if (details != null) 'Details: $details',
      if (originalError != null) 'Original Error: $originalError',
    ].join('\n');
    return '$message\n$errorInfo';
  }
}

/// Service for picking and managing contacts
abstract class ContactPickerService {
  /// Picks a contact from the device's contact list
  Future<Contact?> pickContact();

  /// Fetches all contacts from the device
  Future<List<Contact>> getContacts();

  /// Searches contacts based on the provided query
  Future<List<Contact>> searchContacts(String query);

  /// Fetches a specific contact by ID
  Future<Contact> getContact(String id);
}
