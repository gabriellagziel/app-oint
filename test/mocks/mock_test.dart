import 'package:mockito/annotations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app_oint/features/auth/services/apple_sign_in_service.dart';

@GenerateMocks([
  FirebaseAuth,
  UserCredential,
  User,
  AppleSignInService,
  FirebaseFirestore,
  CollectionReference,
  Query,
  QuerySnapshot,
  DocumentSnapshot,
  DocumentReference,
  QueryDocumentSnapshot,
])
void main() {}
