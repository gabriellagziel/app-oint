import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/contact.dart';
import '../services/contacts_service.dart';

final contactsProvider = FutureProvider<List<Contact>>((ref) async {
  final contactsService = ref.watch(contactsServiceProvider);
  return contactsService.getContacts();
});

final contactsServiceProvider = Provider<ContactsService>((ref) {
  return ContactsService();
});
