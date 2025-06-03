import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_role.dart';
import '../providers/auth_provider.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../../admin/screens/admin_dashboard_screen.dart';
import '../../studio/screens/studio_dashboard_screen.dart';
import '../../personal/screens/personal_dashboard_screen.dart';

final navigationServiceProvider = Provider<NavigationService>((ref) {
  return NavigationService(ref);
});

class NavigationService {
  final Ref _ref;

  NavigationService(this._ref);

  String getInitialRoute() {
    final user = _ref.read(currentUserProvider).value;
    if (user == null) {
      return '/login';
    }

    return _getHomeRouteForRole(user.role);
  }

  String _getHomeRouteForRole(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return '/admin/dashboard';
      case UserRole.studio:
        return '/studio/dashboard';
      case UserRole.personal:
        return '/personal/dashboard';
    }
  }

  Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case '/register':
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case '/admin/dashboard':
        return MaterialPageRoute(builder: (_) => const AdminDashboardScreen());
      case '/studio/dashboard':
        return MaterialPageRoute(builder: (_) => const StudioDashboardScreen());
      case '/personal/dashboard':
        return MaterialPageRoute(
          builder: (_) => const PersonalDashboardScreen(),
        );
      default:
        return MaterialPageRoute(
          builder:
              (_) => Scaffold(
                body: Center(
                  child: Text('No route defined for ${settings.name}'),
                ),
              ),
        );
    }
  }
}
