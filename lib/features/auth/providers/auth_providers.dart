import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for the current Firebase user
final currentUserProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

/// Provider for the current user's role
final userRoleProvider = StreamProvider<String?>((ref) {
  final userStream = ref.watch(currentUserProvider);

  return userStream.when(
    data: (user) {
      if (user == null) return Stream.value(null);

      return FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots()
          .map((doc) => doc.data()?['role'] as String?);
    },
    loading: () => Stream.value(null),
    error: (_, __) => Stream.value(null),
  );
});
