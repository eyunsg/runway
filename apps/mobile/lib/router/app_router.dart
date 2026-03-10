import 'package:go_router/go_router.dart';
import '../features/register/page/register_temp_screen.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/register',
    routes: [
      GoRoute(
        path: '/register',
        builder: (context, state) => RegisterTempScreen(),
      ),
    ],
  );
}
