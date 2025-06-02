import '../services/appointments_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Implementation of the appointments service
class AppointmentsServiceImpl extends AppointmentsService {
  AppointmentsServiceImpl()
      : super(
          firestore: FirebaseFirestore.instance,
          authService: FirebaseAuthService(FirebaseAuth.instance),
        );
}
