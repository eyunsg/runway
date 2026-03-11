import 'package:go_router/go_router.dart';

import 'package:runway/features/login/page/login_temp_screen.dart';
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
    ],
  );
}
