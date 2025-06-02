import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:app_oint9/services/appointments_service.dart';
import 'package:app_oint9/models/appointment.dart';

class FakeAuthService implements AuthService {
  String? _userId;

  void setUser(String? userId) {
    _userId = userId;
  }

  @override
  String? get currentUserId => _userId;
}

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late FakeAuthService authService;
  late AppointmentsService appointmentsService;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    authService = FakeAuthService();
    appointmentsService = AppointmentsService(
      firestore: fakeFirestore,
      authService: authService,
    );

    authService.setUser('test-user-id');
  });

  group('AppointmentsService', () {
    test('creates appointment successfully', () async {
      final appointment = Appointment(
        id: 'test-id',
        title: 'Test Appointment',
        datetime: DateTime.now(),
        location: 'Test Location',
        notes: 'Test Notes',
        userId: 'test-user-id',
      );

      await appointmentsService.createAppointment(appointment);

      final doc = await fakeFirestore
          .collection('appointments')
          .doc(appointment.id)
          .get();
      expect(doc.exists, isTrue);
      expect(doc.data()?['title'], equals(appointment.title));
      expect(doc.data()?['location'], equals(appointment.location));
      expect(doc.data()?['notes'], equals(appointment.notes));
      expect(doc.data()?['userId'], equals(appointment.userId));
    });

    test('updates appointment successfully', () async {
      final appointment = Appointment(
        id: 'test-id',
        title: 'Test Appointment',
        datetime: DateTime.now(),
        location: 'Test Location',
        notes: 'Test Notes',
        userId: 'test-user-id',
      );

      await fakeFirestore
          .collection('appointments')
          .doc(appointment.id)
          .set(appointment.toJson());

      final updatedAppointment = Appointment(
        id: appointment.id,
        title: 'Updated Appointment',
        datetime: appointment.datetime,
        location: 'Updated Location',
        notes: 'Updated Notes',
        userId: appointment.userId,
      );

      await appointmentsService.updateAppointment(updatedAppointment);

      final doc = await fakeFirestore
          .collection('appointments')
          .doc(appointment.id)
          .get();
      expect(doc.exists, isTrue);
      expect(doc.data()?['title'], equals(updatedAppointment.title));
      expect(doc.data()?['location'], equals(updatedAppointment.location));
      expect(doc.data()?['notes'], equals(updatedAppointment.notes));
    });

    test('deletes appointment successfully', () async {
      final appointment = Appointment(
        id: 'test-id',
        title: 'Test Appointment',
        datetime: DateTime.now(),
        location: 'Test Location',
        notes: 'Test Notes',
        userId: 'test-user-id',
      );

      await fakeFirestore
          .collection('appointments')
          .doc(appointment.id)
          .set(appointment.toJson());

      await appointmentsService.deleteAppointment(appointment.id);

      final doc = await fakeFirestore
          .collection('appointments')
          .doc(appointment.id)
          .get();
      expect(doc.exists, isFalse);
    });

    test('gets appointments stream', () async {
      final appointments = [
        Appointment(
          id: 'test-id-1',
          title: 'Test Appointment 1',
          datetime: DateTime.now(),
          location: 'Test Location 1',
          notes: 'Test Notes 1',
          userId: 'test-user-id',
        ),
        Appointment(
          id: 'test-id-2',
          title: 'Test Appointment 2',
          datetime: DateTime.now(),
          location: 'Test Location 2',
          notes: 'Test Notes 2',
          userId: 'test-user-id',
        ),
      ];

      for (final appointment in appointments) {
        await fakeFirestore
            .collection('appointments')
            .doc(appointment.id)
            .set(appointment.toJson());
      }

      final stream = appointmentsService.getAppointmentsStream();
      final result = await stream.first;

      expect(result.length, equals(2));
      expect(result[0].title, equals(appointments[0].title));
      expect(result[1].title, equals(appointments[1].title));
    });

    test('gets single appointment', () async {
      final appointment = Appointment(
        id: 'test-id',
        title: 'Test Appointment',
        datetime: DateTime.now(),
        location: 'Test Location',
        notes: 'Test Notes',
        userId: 'test-user-id',
      );

      await fakeFirestore
          .collection('appointments')
          .doc(appointment.id)
          .set(appointment.toJson());

      final result = await appointmentsService.getAppointment(appointment.id);

      expect(result, isNotNull);
      expect(result?.title, equals(appointment.title));
      expect(result?.location, equals(appointment.location));
      expect(result?.notes, equals(appointment.notes));
    });
  });
}
