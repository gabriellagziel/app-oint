import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:app_oint/features/meetings/services/smart_suggestion_service.dart';
import '../../../mocks/mock_test.mocks.dart';

void main() {
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference<Map<String, dynamic>> mockCollection;
  late MockQuery<Map<String, dynamic>> mockQuery;
  late MockQuerySnapshot<Map<String, dynamic>> mockQuerySnapshot;
  late MockQueryDocumentSnapshot<Map<String, dynamic>> mockDocument;
  late MockDocumentReference<Map<String, dynamic>> mockDocumentRef;
  late SmartSuggestionService service;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockCollection = MockCollectionReference<Map<String, dynamic>>();
    mockQuery = MockQuery<Map<String, dynamic>>();
    mockQuerySnapshot = MockQuerySnapshot<Map<String, dynamic>>();
    mockDocument = MockQueryDocumentSnapshot<Map<String, dynamic>>();
    mockDocumentRef = MockDocumentReference<Map<String, dynamic>>();
    service = SmartSuggestionService(firestore: mockFirestore);

    when(mockFirestore.collection('meetings')).thenReturn(mockCollection);
    when(
      mockCollection.where('creatorId', isEqualTo: any),
    ).thenReturn(mockQuery);
    when(mockQuery.where('endTime', isLessThan: any)).thenReturn(mockQuery);
    when(
      mockQuery.where('suggestionShown', isEqualTo: false),
    ).thenReturn(mockQuery);
    when(mockQuery.orderBy('endTime', descending: true)).thenReturn(mockQuery);
    when(mockQuery.limit(1)).thenReturn(mockQuery);
    when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
    when(mockDocument.reference).thenReturn(mockDocumentRef);
    when(mockDocumentRef.update(any)).thenAnswer((_) async {});
  });

  testWidgets('shows dialog when recent meeting found', (
    WidgetTester tester,
  ) async {
    // Arrange
    when(mockQuerySnapshot.docs).thenReturn([mockDocument]);
    when(mockDocument.data()).thenReturn({
      'title': 'Test Meeting',
      'startTime': DateTime.now().subtract(const Duration(hours: 2)),
      'endTime': DateTime.now().subtract(const Duration(hours: 1)),
    });

    // Act
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder:
              (context) => Scaffold(
                body: ElevatedButton(
                  onPressed:
                      () => service.checkAndPromptSmartSuggestion(
                        context: context,
                        userId: 'test-user',
                      ),
                  child: const Text('Check Suggestions'),
                ),
              ),
        ),
      ),
    );

    await tester.tap(find.text('Check Suggestions'));
    await tester.pumpAndSettle();

    // Assert
    expect(find.text('Repeat this meeting?'), findsOneWidget);
    expect(find.text('Test Meeting'), findsOneWidget);
    expect(find.text('Duplicate'), findsOneWidget);
    expect(find.text('Reschedule'), findsOneWidget);
    expect(find.text('Dismiss'), findsOneWidget);
  });

  testWidgets('does not show dialog when no recent meetings', (
    WidgetTester tester,
  ) async {
    // Arrange
    when(mockQuerySnapshot.docs).thenReturn([]);

    // Act
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder:
              (context) => Scaffold(
                body: ElevatedButton(
                  onPressed:
                      () => service.checkAndPromptSmartSuggestion(
                        context: context,
                        userId: 'test-user',
                      ),
                  child: const Text('Check Suggestions'),
                ),
              ),
        ),
      ),
    );

    await tester.tap(find.text('Check Suggestions'));
    await tester.pumpAndSettle();

    // Assert
    expect(find.text('Repeat this meeting?'), findsNothing);
  });

  testWidgets('handles errors gracefully', (WidgetTester tester) async {
    // Arrange
    when(mockQuery.get()).thenThrow(Exception('Test error'));

    // Act
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder:
              (context) => Scaffold(
                body: ElevatedButton(
                  onPressed:
                      () => service.checkAndPromptSmartSuggestion(
                        context: context,
                        userId: 'test-user',
                      ),
                  child: const Text('Check Suggestions'),
                ),
              ),
        ),
      ),
    );

    await tester.tap(find.text('Check Suggestions'));
    await tester.pumpAndSettle();

    // Assert
    expect(
      find.text('Failed to check for meeting suggestions'),
      findsOneWidget,
    );
  });
}
