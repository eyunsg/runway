import 'package:go_router/go_router.dart';

import 'package:runway/features/login/page/login_temp_screen.dart';
import 'package:runway/features/password_reset/page/email_input_temp_screen.dart';
import 'package:runway/features/password_reset/page/password_reset_temp_screen.dart';
import '../features/register/page/register_temp_screen.dart';

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
        path: '/reset-password',
        builder: (context, state) => EmailInputTempScreen(),
      ),
      GoRoute(
        path: '/reset-password/new',
        builder: (context, state) => PasswordResetTempScreen(),
      ),
    ],
  );
}
