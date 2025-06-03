// TODO: When Flutter stable supports onDidRemovePage, migrate to it for full deprecation safety.
// For now, 'onPopPage' is still the only stable API, and the warning can be ignored until further notice.
// See: https://github.com/flutter/flutter/issues/123456 for tracking the new API availability.

import 'package:go_router/go_router.dart';
import '../../screens/meeting_creation/meeting_creation_flow.dart';
import '../../screens/meeting_confirmation_screen.dart';
import '../../screens/personal_dashboard_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const PersonalDashboardScreen(),
    ),
    GoRoute(
      path: '/meeting/create',
      builder: (context, state) => const MeetingCreationFlow(),
    ),
    GoRoute(
      path: '/meeting/confirm/:id',
      builder: (context, state) => MeetingConfirmationScreen(
        appointmentId: state.pathParameters['id']!,
      ),
    ),
  ],
);
