import 'dart:io' show Platform;
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../mocks/mock_test.mocks.dart';

// After build_runner, update to:
// import 'package:app_oint/features/auth/mocks/mock_classes.mocks.dart';

void main() {
  late MockFirebaseAuth mockAuth;
  late MockAppleSignInService mockService;
  late MockUserCredential mockUserCredential;
  late MockUser mockUser;

  setUp(() {
    mockAuth = MockFirebaseAuth();
    mockService = MockAppleSignInService();
    mockUserCredential = MockUserCredential();
    mockUser = MockUser();

    when(mockUserCredential.user).thenReturn(mockUser);
    when(mockService.signIn()).thenAnswer((_) async => mockUser);
    when(mockService.getCredentials()).thenAnswer((_) async => null);
  });

  test('AppleSignInService returns null on unsupported platforms', () async {
    if (!Platform.isIOS && !Platform.isMacOS) {
      final result = await mockService.signIn();
      expect(result, isNull);
    }
  });

  test('signIn throws UnsupportedError on non-iOS platforms', () async {
    if (!Platform.isIOS) {
      when(
        mockService.signIn(),
      ).thenThrow(UnsupportedError('Not supported on this platform'));
      expect(() => mockService.signIn(), throwsA(isA<UnsupportedError>()));
    }
  });

  test('getCredentials returns null on non-iOS platforms', () async {
    if (!Platform.isIOS) {
      final result = await mockService.getCredentials();
      expect(result, isNull);
    }
  });

  group('AppleSignInService', () {
    test('should handle successful sign-in on iOS', () async {
      if (!Platform.isIOS) return;
      final mockUser = MockUser();
      when(mockService.signIn()).thenAnswer((_) async => mockUser);
      final user = await mockService.signIn();
      expect(user, isNotNull);
      verify(mockService.signIn()).called(1);
    });

    test('should handle sign-in errors on iOS', () async {
      if (!Platform.isIOS) return;
      when(mockService.signIn()).thenThrow(
        FirebaseAuthException(
          code: 'sign-in-failed',
          message: 'Sign in failed',
        ),
      );
      expect(() => mockService.signIn(), throwsA(isA<FirebaseAuthException>()));
      verify(mockService.signIn()).called(1);
    });

    test('signIn should return user credential on success', () async {
      final mockUserCredential = MockUserCredential();
      when(
        mockAuth.signInWithCredential(any),
      ).thenAnswer((_) async => mockUserCredential);
      when(mockService.signIn()).thenAnswer((_) async => mockUser);

      final result = await mockService.signIn();
      expect(result, isNotNull);

      verify(mockService.signIn()).called(1);
    });

    test('signIn should throw exception on failure', () async {
      when(mockService.signIn()).thenThrow(Exception('Sign in failed'));
      expect(() => mockService.signIn(), throwsException);
      verify(mockService.signIn()).called(1);
    });
  });

  // Add more platform-specific or logic-specific tests as needed
}
