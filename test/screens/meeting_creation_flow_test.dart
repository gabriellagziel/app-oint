import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:app_oint9/screens/meeting_creation/meeting_creation_flow.dart';
import 'package:app_oint9/services/appointments_service.dart';
import 'package:app_oint9/services/contact_picker_service.dart';
import 'package:app_oint9/providers/contact_picker_service_provider.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

import 'meeting_creation_flow_test.mocks.dart';

@GenerateMocks([], customMocks: [
  MockSpec<AppointmentsService>(as: #MockAppointmentsService),
  MockSpec<ContactPickerService>(as: #MockContactPickerService),
])
void main() {
  late MockAppointmentsService mockAppointmentsService;
  late MockContactPickerService mockContactPickerService;
  late ProviderContainer container;

  setUp(() {
    mockAppointmentsService = MockAppointmentsService();
    mockContactPickerService = MockContactPickerService();

    // Set up mock responses
    when(mockAppointmentsService.createAppointment(any))
        .thenAnswer((_) async => 'mock-appointment-id');
    when(mockContactPickerService.getContacts()).thenAnswer((_) async => []);
    when(mockContactPickerService.pickContact()).thenAnswer((_) async => null);

    container = ProviderContainer(
      overrides: [
        contactPickerServiceProvider
            .overrideWithValue(mockContactPickerService),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  testWidgets('renders meeting creation flow', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: UncontrolledProviderScope(
          container: container,
          child: const MeetingCreationFlow(),
        ),
      ),
    );

    expect(find.text('Create Meeting'), findsOneWidget);
    expect(find.text('What\'s the meeting about?'), findsOneWidget);
  });

  testWidgets('completes title step', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: UncontrolledProviderScope(
          container: container,
          child: const MeetingCreationFlow(),
        ),
      ),
    );

    await tester.enterText(find.byType(TextFormField), 'Test Meeting');
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.text('When is the meeting?'), findsOneWidget);
  });

  testWidgets('completes datetime step', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: UncontrolledProviderScope(
          container: container,
          child: const MeetingCreationFlow(),
        ),
      ),
    );

    // Complete title step
    await tester.enterText(find.byType(TextFormField), 'Test Meeting');
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    // Select date
    await tester.tap(find.text('Select Date'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('15'));
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    // Select time
    await tester.tap(find.text('Select Time'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.text('What type of meeting is this?'), findsOneWidget);
  });

  testWidgets('completes type step', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: UncontrolledProviderScope(
          container: container,
          child: const MeetingCreationFlow(),
        ),
      ),
    );

    // Complete previous steps
    await tester.enterText(find.byType(TextFormField), 'Test Meeting');
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Select Date'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('15'));
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Select Time'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    // Select meeting type
    await tester.tap(find.text('One-on-One'));
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.text('Who\'s attending?'), findsOneWidget);
  });

  testWidgets('completes participants step', (WidgetTester tester) async {
    final mockContact = Contact(
      id: '1',
      displayName: 'Test Contact',
      name: Name(first: 'Test', last: 'Contact'),
    );

    when(mockContactPickerService.getContacts())
        .thenAnswer((_) async => [mockContact]);
    when(mockContactPickerService.pickContact())
        .thenAnswer((_) async => mockContact);

    await tester.pumpWidget(
      MaterialApp(
        home: UncontrolledProviderScope(
          container: container,
          child: const MeetingCreationFlow(),
        ),
      ),
    );

    // Complete previous steps
    await tester.enterText(find.byType(TextFormField), 'Test Meeting');
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Select Date'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('15'));
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Select Time'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('One-on-One'));
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    // Add participant
    await tester.tap(find.text('Test Contact'));
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.text('Where is the meeting?'), findsOneWidget);
  });

  testWidgets('completes location step', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: UncontrolledProviderScope(
          container: container,
          child: const MeetingCreationFlow(),
        ),
      ),
    );

    // Complete previous steps
    await tester.enterText(find.byType(TextFormField), 'Test Meeting');
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Select Date'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('15'));
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Select Time'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('One-on-One'));
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    // Add participant
    await tester.tap(find.text('Test Contact'));
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    // Enter location
    await tester.enterText(find.byType(TextFormField), 'Test Location');
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.text('Any additional notes?'), findsOneWidget);
  });

  testWidgets('completes notes step and submits meeting',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: UncontrolledProviderScope(
          container: container,
          child: const MeetingCreationFlow(),
        ),
      ),
    );

    // Complete previous steps
    await tester.enterText(find.byType(TextFormField), 'Test Meeting');
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Select Date'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('15'));
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Select Time'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('One-on-One'));
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    // Add participant
    await tester.tap(find.text('Test Contact'));
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    // Enter location
    await tester.enterText(find.byType(TextFormField), 'Test Location');
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    // Enter notes
    await tester.enterText(find.byType(TextField), 'Test Notes');
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    // Submit meeting
    await tester.tap(find.byIcon(Icons.check));
    await tester.pumpAndSettle();

    verify(mockAppointmentsService.createAppointment(any)).called(1);
  });
}
