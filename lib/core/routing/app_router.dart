// TODO: When Flutter stable supports onDidRemovePage, migrate to it for full deprecation safety.
// For now, 'onPopPage' is still the only stable API, and the warning can be ignored until further notice.
// See: https://github.com/flutter/flutter/issues/123456 for tracking the new API availability.

import 'package:flutter/material.dart';
import '../../screens/meeting_confirmation_screen.dart';

class AppRouter extends RouterDelegate<RouteSettings>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<RouteSettings> {
  @override
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  RouteSettings? get currentConfiguration => null;

  static const String meetingConfirmation = '/meeting-confirmation';

  static final routes = {
    meetingConfirmation: (context) {
      final args = ModalRoute.of(context)!.settings.arguments;
      if (args is! String) {
        throw ArgumentError(
            'MeetingConfirmationScreen requires a String appointmentId');
      }
      return MeetingConfirmationScreen(appointmentId: args);
    },
  };

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      pages: const [
        MaterialPage(
          key: ValueKey('HomePage'),
          child: Center(child: Text('Home Page')),
        ),
      ],
      // Deprecated, but currently only option in Flutter stable:
      onPopPage: (route, result) => route.didPop(result),
      // If/when Flutter upgrades: replace with onDidRemovePage as per API docs.
    );
  }

  @override
  Future<void> setNewRoutePath(RouteSettings configuration) async {}
}
