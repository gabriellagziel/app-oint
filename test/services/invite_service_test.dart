import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:app_oint/services/invite_service.dart';

@GenerateMocks([
  FirebaseFirestore,
  FirebaseAuth,
  User,
], customMocks: [
  MockSpec<CollectionReference<Map<String, dynamic>>>(
      as: #MockFirestoreCollectionReference),
  MockSpec<Query<Map<String, dynamic>>>(as: #MockFirestoreQuery),
  MockSpec<QuerySnapshot<Map<String, dynamic>>>(
      as: #MockFirestoreQuerySnapshot),
  MockSpec<QueryDocumentSnapshot<Map<String, dynamic>>>(
      as: #MockFirestoreQueryDocumentSnapshot),
  MockSpec<DocumentSnapshot<Map<String, dynamic>>>(
      as: #MockFirestoreDocumentSnapshot),
  MockSpec<DocumentReference<Map<String, dynamic>>>(
      as: #MockFirestoreDocumentReference),
])
import 'invite_service_test.mocks.dart';

void main() {
  late MockFirebaseFirestore mockFirestore;
  late MockFirebaseAuth mockAuth;
  late MockUser mockUser;
  late MockFirestoreCollectionReference mockInvitesCollection;
  late MockFirestoreCollectionReference mockUsersCollection;
  late MockFirestoreQuery mockUsersQuery;
  late MockFirestoreQuerySnapshot mockQuerySnapshot;
  late InviteService inviteService;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockAuth = MockFirebaseAuth();
    mockUser = MockUser();
    mockInvitesCollection = MockFirestoreCollectionReference();
    mockUsersCollection = MockFirestoreCollectionReference();
    mockUsersQuery = MockFirestoreQuery();
    mockQuerySnapshot = MockFirestoreQuerySnapshot();

    when(mockAuth.currentUser).thenReturn(mockUser);
    when(mockUser.uid).thenReturn('test-user-id');
    when(mockFirestore.collection('invites')).thenReturn(mockInvitesCollection);
    when(mockFirestore.collection('users')).thenReturn(mockUsersCollection);
    when(mockUsersCollection.where('phone', isEqualTo: anyNamed('isEqualTo')))
        .thenReturn(mockUsersQuery);
    when(mockUsersQuery.limit(1)).thenReturn(mockUsersQuery);
    when(mockUsersQuery.get()).thenAnswer((_) async => mockQuerySnapshot);

    inviteService = InviteService(
      firestore: mockFirestore,
      auth: mockAuth,
    );
  });

  group('sendInvites', () {
    test('sends internal invite when user exists', () async {
      // Arrange
      final mockDoc = MockFirestoreQueryDocumentSnapshot();
      when(mockDoc.id).thenReturn('target-user-id');
      when(mockDoc.data()).thenReturn({'phone': '+1234567890'});
      when(mockQuerySnapshot.docs).thenReturn([mockDoc]);
      when(mockInvitesCollection.add(anyNamed('data')))
          .thenAnswer((_) async => MockFirestoreDocumentReference());

      // Act
      await inviteService.sendInvites(
        meetingId: 'test-meeting-id',
        inviteePhones: ['+1234567890'],
        context: MockBuildContext(),
      );

      // Assert
      verify(mockInvitesCollection.add({
        'meetingId': 'test-meeting-id',
        'fromUid': 'test-user-id',
        'toUid': 'target-user-id',
        'status': 'pending',
        'timestamp': any,
        'phone': '+1234567890',
      })).called(1);
    });

    test('handles external user with fallback options', () async {
      // Arrange
      when(mockQuerySnapshot.docs).thenReturn([]);

      // Act
      await inviteService.sendInvites(
        meetingId: 'test-meeting-id',
        inviteePhones: ['+1234567890'],
        context: MockBuildContext(),
      );

      // Assert
      verifyNever(mockInvitesCollection.add(any));
    });

    test('handles errors gracefully', () async {
      // Arrange
      when(mockUsersQuery.get()).thenThrow(Exception('Test error'));

      // Act & Assert
      expect(
        () => inviteService.sendInvites(
          meetingId: 'test-meeting-id',
          inviteePhones: ['+1234567890'],
          context: MockBuildContext(),
        ),
        throwsException,
      );
    });
  });

  group('updateInviteStatus', () {
    test('updates invite status successfully', () async {
      // Arrange
      final mockDocRef = MockFirestoreDocumentReference();
      when(mockInvitesCollection.doc(any)).thenReturn(mockDocRef);
      when(mockDocRef.update(anyNamed('data'))).thenAnswer((_) async => null);

      // Act
      await inviteService.updateInviteStatus(
        inviteId: 'test-invite-id',
        status: 'accepted',
      );

      // Assert
      verify(mockDocRef.update({
        'status': 'accepted',
        'updatedAt': any,
      })).called(1);
    });

    test('throws when user not authenticated', () async {
      // Arrange
      when(mockAuth.currentUser).thenReturn(null);

      // Act & Assert
      expect(
        () => inviteService.updateInviteStatus(
          inviteId: 'test-invite-id',
          status: 'accepted',
        ),
        throwsException,
      );
    });
  });

  group('getPendingInvites', () {
    test('returns stream of pending invites', () {
      // Arrange
      final mockStream = Stream.value(mockQuerySnapshot);
      when(mockInvitesCollection.where('toUid', isEqualTo: 'test-user-id'))
          .thenReturn(mockUsersQuery);
      when(mockUsersQuery.where('status', isEqualTo: 'pending'))
          .thenReturn(mockUsersQuery);
      when(mockUsersQuery.orderBy('timestamp', descending: true))
          .thenReturn(mockUsersQuery);
      when(mockUsersQuery.snapshots()).thenAnswer((_) => mockStream);

      // Act
      final result = inviteService.getPendingInvites();

      // Assert
      expect(result, equals(mockStream));
    });

    test('throws when user not authenticated', () {
      // Arrange
      when(mockAuth.currentUser).thenReturn(null);

      // Act & Assert
      expect(() => inviteService.getPendingInvites(), throwsException);
    });
  });
}

class MockBuildContext extends Mock implements BuildContext {}
