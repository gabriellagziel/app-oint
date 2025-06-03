import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app_oint/screens/invite_inbox_screen.dart';
import 'package:app_oint/services/invite_service.dart';
import '../helpers/firebase_test_helper.dart';

@GenerateMocks([
  InviteService,
  QuerySnapshot,
  QueryDocumentSnapshot,
])
import 'invite_inbox_screen_test.mocks.dart';

void main() {
  testWidgets('shows invite and accepts it', (WidgetTester tester) async {
    final mockInviteService = MockInviteService();

    final mockSnapshot = MockQuerySnapshot();
    final mockDoc = MockQueryDocumentSnapshot();

    when(mockDoc.id).thenReturn('invite-id-123');
    when(mockDoc['meetingId']).thenReturn('meeting-abc');
    when(mockSnapshot.docs).thenReturn([mockDoc]);

    when(mockInviteService.getPendingInvites())
        .thenAnswer((_) => Stream.value(mockSnapshot));

    when(mockInviteService.updateInviteStatus(
      inviteId: anyNamed('inviteId'),
      status: anyNamed('status'),
    )).thenAnswer((_) async {});

    await tester.pumpWidget(MaterialApp(
      home: InviteInboxScreen(inviteService: mockInviteService),
    ));

    await tester.pumpAndSettle();

    expect(find.text('Meeting ID: meeting-abc'), findsOneWidget);
    expect(find.text('Accept'), findsOneWidget);
    expect(find.text('Decline'), findsOneWidget);

    await tester.tap(find.text('Accept'));
    await tester.pump();

    verify(mockInviteService.updateInviteStatus(
      inviteId: 'invite-id-123',
      status: 'accepted',
    )).called(1);
  });
}
