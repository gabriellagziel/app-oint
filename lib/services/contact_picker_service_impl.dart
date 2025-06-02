import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:logger/logger.dart';
import 'contact_picker_service.dart';

/// Implementation of the ContactPickerService
class ContactPickerServiceImpl implements ContactPickerService {
  final _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );

  final String Function(String key) getLocalizedString;

  ContactPickerServiceImpl(this.getLocalizedString);

  @override
  Future<Contact?> pickContact() async {
    try {
      await _checkPermission();
      final contacts = await FlutterContacts.getContacts(
        withProperties: true,
        withPhoto: true,
      );
      if (contacts.isEmpty) {
        return null;
      }
      // In a real implementation, this would show a contact picker UI
      return contacts.first;
    } catch (e, stackTrace) {
      _logger.e(
        'Failed to pick contact',
        error: e,
        stackTrace: stackTrace,
      );
      throw ContactPickerError(
        getLocalizedString('contactNotFound'),
        ContactPickerErrorType.contactLoadFailed,
        details: 'An unexpected error occurred while picking contact',
        originalError: e,
      );
    }
  }

  void _validateInput(String? id, String? query) {
    if (id != null && id.isEmpty) {
      throw ContactPickerError(
        getLocalizedString('invalidContactId'),
        ContactPickerErrorType.invalidInput,
        details: getLocalizedString('invalidContactId'),
      );
    }
    if (query != null && query.isEmpty) {
      throw ContactPickerError(
        getLocalizedString('invalidSearchQuery'),
        ContactPickerErrorType.invalidInput,
        details: getLocalizedString('invalidSearchQuery'),
      );
    }
  }

  Future<void> _checkPermission() async {
    try {
      _logger.d('Checking contacts permission...');
      final status = await Permission.contacts.request();

      if (status.isDenied) {
        _logger.w('Contacts permission denied');
        throw ContactPickerError(
          getLocalizedString('contactsPermissionRequired'),
          ContactPickerErrorType.permissionDenied,
          details: getLocalizedString('contactsPermissionDenied'),
        );
      }

      if (status.isPermanentlyDenied) {
        _logger.w('Contacts permission permanently denied');
        throw ContactPickerError(
          getLocalizedString('contactsPermissionRequired'),
          ContactPickerErrorType.permissionPermanentlyDenied,
          details: getLocalizedString('contactsPermissionPermanentlyDenied'),
        );
      }

      _logger.d('Contacts permission granted');
    } catch (e, stackTrace) {
      _logger.e(
        'Error checking contacts permission',
        error: e,
        stackTrace: stackTrace,
      );
      throw ContactPickerError(
        getLocalizedString('contactsPermissionRequired'),
        ContactPickerErrorType.unknown,
        details: 'An unexpected error occurred while checking permission',
        originalError: e,
      );
    }
  }

  @override
  Future<List<Contact>> getContacts() async {
    try {
      _logger.d('Starting to fetch contacts...');
      await _checkPermission();

      final contacts = await FlutterContacts.getContacts(
        withProperties: true,
        withPhoto: true,
      );

      if (contacts.isEmpty) {
        _logger.w('No contacts found on device');
      } else {
        _logger.i('Successfully fetched ${contacts.length} contacts');
      }

      return contacts;
    } on ContactPickerError {
      rethrow;
    } catch (e, stackTrace) {
      _logger.e(
        'Failed to load contacts',
        error: e,
        stackTrace: stackTrace,
      );
      throw ContactPickerError(
        getLocalizedString('contactNotFound'),
        ContactPickerErrorType.contactLoadFailed,
        details: 'An unexpected error occurred while loading contacts',
        originalError: e,
      );
    }
  }

  @override
  Future<List<Contact>> searchContacts(String query) async {
    try {
      _validateInput(null, query);
      await _checkPermission();

      final contacts = await FlutterContacts.getContacts(
        withProperties: true,
        withPhoto: true,
      );

      return contacts
          .where((contact) =>
              contact.displayName.toLowerCase().contains(query.toLowerCase()))
          .toList();
    } catch (e, stackTrace) {
      _logger.e(
        'Failed to search contacts',
        error: e,
        stackTrace: stackTrace,
      );
      throw ContactPickerError(
        getLocalizedString('searchFailed'),
        ContactPickerErrorType.searchFailed,
        details: 'An unexpected error occurred while searching contacts',
        originalError: e,
      );
    }
  }

  @override
  Future<Contact> getContact(String id) async {
    try {
      _validateInput(id, null);
      await _checkPermission();

      final contact = await FlutterContacts.getContact(id);
      if (contact == null) {
        throw ContactPickerError(
          getLocalizedString('contactNotFound'),
          ContactPickerErrorType.contactNotFound,
          details:
              getLocalizedString('noContactFoundWithId').replaceAll('{id}', id),
        );
      }

      return contact;
    } catch (e, stackTrace) {
      _logger.e(
        'Failed to get contact',
        error: e,
        stackTrace: stackTrace,
      );
      throw ContactPickerError(
        getLocalizedString('contactNotFound'),
        ContactPickerErrorType.contactNotFound,
        details: 'An unexpected error occurred while getting contact',
        originalError: e,
      );
    }
  }
}
