import 'dart:convert';
import 'package:flutter_contacts/flutter_contacts.dart' as flutter_contacts;
import '../models/contact.dart' as app;
import 'package:flutter_contacts/flutter_contacts.dart' as fc;

class ContactsService {
  Future<List<app.Contact>> getContacts() async {
    final contacts = await flutter_contacts.FlutterContacts.getContacts(
      withProperties: true,
      withPhoto: true,
    );

    return contacts.map((contact) {
      return app.Contact(
        id: contact.id,
        displayName: contact.displayName,
        phone: contact.phones.isNotEmpty ? contact.phones.first.number : null,
        photoUrl: contact.photo != null ? base64Encode(contact.photo!) : null,
      );
    }).toList();
  }

  Future<List<app.Contact>> getContactsFromFlutterContacts() async {
    final contacts = await fc.FlutterContacts.getContacts();
    return contacts
        .map((c) => app.Contact(
              id: c.id,
              displayName: c.displayName,
              phone: c.phones.isNotEmpty ? c.phones.first.number : null,
              photoUrl: c.photo != null ? base64Encode(c.photo!) : null,
            ))
        .toList();
  }
}
