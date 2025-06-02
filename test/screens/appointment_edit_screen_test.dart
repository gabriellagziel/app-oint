import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_oint9/screens/appointment_edit_screen.dart';
import 'package:app_oint9/models/appointment.dart';
import 'package:app_oint9/services/appointments_service.dart';

import 'appointment_edit_screen_test.mocks.dart';

@GenerateMocks([], customMocks: [
  MockSpec<AppointmentsService>(as: #MockAppointmentsService),
])
void main() {
  late MockAppointmentsService mockAppointmentsService;
  late ProviderContainer container;

  setUp(() {
    mockAppointmentsService = MockAppointmentsService();

    // Set up mock responses
    when(mockAppointmentsService.createAppointment(any))
        .thenAnswer((_) async => 'mock-appointment-id-edit-1');
    when(mockAppointmentsService.updateAppointment(any))
        .thenAnswer((_) async {});
    when(mockAppointmentsService.deleteAppointment(any))
        .thenAnswer((_) async {});

    container = ProviderContainer();
  });

  tearDown(() {
    container.dispose();
  });

  testWidgets('renders appointment edit screen', (WidgetTester tester) async {
    final testAppointment = Appointment(
      id: '1',
      title: 'Test Appointment',
      datetime: DateTime.now().add(const Duration(days: 1)),
      userId: 'user1',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: UncontrolledProviderScope(
          container: container,
          child: AppointmentEditScreen(appointment: testAppointment),
        ),
      ),
    );

    expect(find.text('Edit Appointment'), findsOneWidget);
    expect(find.text('Test Appointment'), findsOneWidget);
  });

  testWidgets('updates appointment title', (WidgetTester tester) async {
    final testAppointment = Appointment(
      id: '1',
      title: 'Test Appointment',
      datetime: DateTime.now().add(const Duration(days: 1)),
      userId: 'user1',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: UncontrolledProviderScope(
          container: container,
          child: AppointmentEditScreen(appointment: testAppointment),
        ),
      ),
    );

    await tester.enterText(find.byType(TextFormField).first, 'Updated Title');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    verify(mockAppointmentsService.updateAppointment(any)).called(1);
  });

  testWidgets('shows delete button and triggers delete',
      (WidgetTester tester) async {
    final appointment = Appointment(
      id: '1',
      title: 'Test Appointment',
      datetime: DateTime.now().add(const Duration(days: 1)),
      location: 'Test Location',
      userId: 'test-user-id',
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: AppointmentEditScreen(appointment: appointment),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.delete));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(TextButton, 'Delete'));
    await tester.pumpAndSettle();

    verify(mockAppointmentsService.deleteAppointment(appointment.id)).called(1);
  });

  testWidgets('AppointmentEditScreen smoke test', (WidgetTester tester) async {
    final testAppointment = Appointment(
      id: '1',
      title: 'Test Appointment',
      datetime: DateTime.now().add(const Duration(days: 1)),
      userId: 'user1',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: AppointmentEditScreen(appointment: testAppointment),
      ),
    );

    expect(find.byType(AppointmentEditScreen), findsOneWidget);
  });
}
