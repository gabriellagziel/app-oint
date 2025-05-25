import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:app_oint/features/meetings/services/smart_suggestion_service.dart';
import 'package:clock/clock.dart';

import 'smart_suggestion_service_test.mocks.dart';

@GenerateMocks([
  FirebaseFirestore,
  User,
  DocumentSnapshot<Map<String, dynamic>>,
  QuerySnapshot<Map<String, dynamic>>,
  Query<Map<String, dynamic>>,
  DocumentReference<Map<String, dynamic>>,
  CollectionReference<Map<String, dynamic>>,
  QueryDocumentSnapshot<Map<String, dynamic>>,
])
void main() {
  late MockFirebaseFirestore mockFirestore;
  late MockUser mockUser;
  late MockQuerySnapshot<Map<String, dynamic>> mockQuerySnapshot;
  late MockQueryDocumentSnapshot<Map<String, dynamic>> mockDocument;
  late MockQuery<Map<String, dynamic>> mockQuery;
  late MockDocumentReference<Map<String, dynamic>> mockDocumentRef;
  late MockCollectionReference<Map<String, dynamic>> mockCollectionRef;
  late SmartSuggestionService service;
  final fixedNow = DateTime(2025, 1, 1, 10);

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockUser = MockUser();
    mockQuerySnapshot = MockQuerySnapshot<Map<String, dynamic>>();
    mockDocument = MockQueryDocumentSnapshot<Map<String, dynamic>>();
    mockQuery = MockQuery<Map<String, dynamic>>();
    mockDocumentRef = MockDocumentReference<Map<String, dynamic>>();
    mockCollectionRef = MockCollectionReference<Map<String, dynamic>>();

    when(mockUser.uid).thenReturn('test-user');
    when(mockFirestore.collection('meetings')).thenReturn(mockCollectionRef);
    when(mockCollectionRef.where(any, isEqualTo: anyNamed('isEqualTo')))
        .thenReturn(mockQuery);
    when(mockQuery.where(any, isLessThan: anyNamed('isLessThan')))
        .thenReturn(mockQuery);
    when(mockQuery.where(any, isEqualTo: anyNamed('isEqualTo')))
        .thenReturn(mockQuery);
    when(mockQuery.orderBy(any, descending: anyNamed('descending')))
        .thenReturn(mockQuery);
    when(mockQuery.limit(any)).thenReturn(mockQuery);
    when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
    when(mockDocument.reference).thenReturn(mockDocumentRef);
    when(mockDocumentRef.update(any)).thenAnswer((_) async {});
    when(mockDocument.id).thenReturn('test-meeting-id');

    // Mock suggestion logs collection
    when(mockFirestore.collection('suggestion_logs'))
        .thenReturn(mockCollectionRef);
    when(mockCollectionRef.doc(any)).thenReturn(mockDocumentRef);

    service = SmartSuggestionService(
      firestore: mockFirestore,
      clock: Clock.fixed(fixedNow),
    );
  });

  testWidgets('shows dialog when recent meeting found', (tester) async {
    // Setup meeting data
    when(mockQuerySnapshot.docs).thenReturn([mockDocument]);
    when(mockDocument.exists).thenReturn(true);
    when(mockDocument.data()).thenReturn({
      'title': 'Test Meeting',
      'startTime': Timestamp.fromDate(DateTime(2025, 1, 1, 8)),
      'endTime': Timestamp.fromDate(DateTime(2025, 1, 1, 9)),
      'suggestionShown': false,
    });

    // Setup suggestion log to not exist
    final mockSuggestionLog = MockDocumentSnapshot<Map<String, dynamic>>();
    when(mockSuggestionLog.exists).thenReturn(false);
    when(mockDocumentRef.get()).thenAnswer((_) async => mockSuggestionLog);

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () async {
                await service.maybeShowRepeatMeetingDialog(context, mockUser);
              },
              child: const Text('Test'),
            );
          },
        ),
      ),
    );

    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('Repeat this meeting?'), findsOneWidget);
    expect(
      find.text('You met recently for "Test Meeting". Want to repeat it?'),
      findsOneWidget,
    );
    expect(find.text('Dismiss'), findsOneWidget);
  });

  testWidgets('does not show dialog when no recent meetings', (tester) async {
    when(mockQuerySnapshot.docs).thenReturn([]);

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () async {
                await service.maybeShowRepeatMeetingDialog(context, mockUser);
              },
              child: const Text('Test'),
            );
          },
        ),
      ),
    );

    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('handles errors gracefully', (tester) async {
    when(mockQuerySnapshot.docs).thenReturn([mockDocument]);
    when(mockDocument.exists).thenReturn(true);
    when(mockDocument.data()).thenReturn({
      'title': 'Test Meeting',
      'startTime': Timestamp.fromDate(DateTime(2025, 1, 1, 8)),
      'endTime': Timestamp.fromDate(DateTime(2025, 1, 1, 9)),
      'suggestionShown': false,
    });

    // Setup suggestion log to not exist
    final mockSuggestionLog = MockDocumentSnapshot<Map<String, dynamic>>();
    when(mockSuggestionLog.exists).thenReturn(false);
    when(mockDocumentRef.get()).thenAnswer((_) async => mockSuggestionLog);

    when(mockDocumentRef.update(any)).thenThrow(Exception('Test error'));

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () async {
                await service.maybeShowRepeatMeetingDialog(context, mockUser);
              },
              child: const Text('Test'),
            );
          },
        ),
      ),
    );

    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    expect(find.byType(AlertDialog), findsOneWidget);
  });

  testWidgets('does not show dialog for meetings older than 24h',
      (tester) async {
    when(mockQuerySnapshot.docs).thenReturn([mockDocument]);
    when(mockDocument.exists).thenReturn(true);
    when(mockDocument.data()).thenReturn({
      'title': 'Test Meeting',
      'startTime': Timestamp.fromDate(DateTime(2024, 12, 30, 8)),
      'endTime': Timestamp.fromDate(DateTime(2024, 12, 30, 9)),
      'suggestionShown': false,
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () async {
                await service.maybeShowRepeatMeetingDialog(context, mockUser);
              },
              child: const Text('Test'),
            );
          },
        ),
      ),
    );

    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('does not show dialog for already suggested meetings',
      (tester) async {
    when(mockQuerySnapshot.docs).thenReturn([mockDocument]);
    when(mockDocument.exists).thenReturn(true);
    when(mockDocument.data()).thenReturn({
      'title': 'Test Meeting',
      'startTime': Timestamp.fromDate(DateTime(2025, 1, 1, 8)),
      'endTime': Timestamp.fromDate(DateTime(2025, 1, 1, 9)),
      'suggestionShown': false,
    });

    // Setup suggestion log to exist
    final mockSuggestionLog = MockDocumentSnapshot<Map<String, dynamic>>();
    when(mockSuggestionLog.exists).thenReturn(true);
    when(mockDocumentRef.get()).thenAnswer((_) async => mockSuggestionLog);

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () async {
                await service.maybeShowRepeatMeetingDialog(context, mockUser);
              },
              child: const Text('Test'),
            );
          },
        ),
      ),
    );

    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    expect(find.byType(AlertDialog), findsNothing);
  });
}
