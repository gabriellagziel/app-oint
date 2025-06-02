import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_oint9/screens/meeting_flow_screen.dart';
import 'package:app_oint9/services/appointments_service.dart';
import 'package:app_oint9/services/contact_picker_service.dart';
import 'package:app_oint9/providers/contact_picker_service_provider.dart';

import 'meeting_flow_screen_test.mocks.dart';

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
        .thenAnswer((_) async => 'mock-appointment-id-flow');
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

  testWidgets('renders meeting flow screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: UncontrolledProviderScope(
          container: container,
          child: const MeetingFlowScreen(),
        ),
      ),
    );

    expect(find.text('Create Meeting'), findsOneWidget);
  });
}
