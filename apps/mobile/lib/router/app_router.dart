import 'package:go_router/go_router.dart';

import 'package:runway/features/login/page/login_temp_screen.dart';
import 'package:runway/features/password_reset/page/request_password_reset_temp_screen.dart';
import 'package:runway/features/password_reset/page/password_reset_temp_screen.dart';
import 'package:runway/features/logout/page/logout_temp_screen.dart';
import '../features/register/page/register_temp_screen.dart';
import 'package:runway/features/profile/page/profile_temp_screen.dart';
import '../features/password_change/page/password_change_temp_screen.dart';
import '../features/simulation/page/simulation_temp_screen.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/register',
        builder: (context, state) => RegisterTempScreen(),
      ),
      GoRoute(path: '/login', builder: (context, state) => LoginTempScreen()),
      GoRoute(
        path: '/profile',
        builder: (context, state) => ProfileTempScreen(),
      ),
      GoRoute(
        path: '/password-change',
        builder: (context, state) => const PasswordChangePage(),
      ),
      GoRoute(path: '/logout', builder: (context, state) => LogoutTempScreen()),
      GoRoute(
        path: '/reset-password',
        builder: (context, state) => RequestPasswordResetTempScreen(),
      ),
      GoRoute(
        path: '/reset-password/new',
        builder: (context, state) => PasswordResetTempScreen(),
      ),
      GoRoute(
        path: '/simulation',
        builder: (context, state) => SimulationTempScreen(),
      ),
    ],
  );
}
