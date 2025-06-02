import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authServiceProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});
