import 'package:mockito/annotations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:app_oint/features/auth/services/apple_sign_in_service.dart';

@GenerateMocks([FirebaseAuth, UserCredential, AppleSignInService])
void main() {
  // Forces mock generation
}
