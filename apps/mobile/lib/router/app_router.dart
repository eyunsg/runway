import 'package:go_router/go_router.dart';

import 'package:runway/features/login/page/login_screen.dart';
import 'package:runway/features/password_reset/page/request_password_reset_screen.dart';
import 'package:runway/features/password_reset/page/password_reset_screen.dart';
import 'package:runway/features/logout/page/logout_temp_screen.dart';
import 'package:runway/features/profile/page/app_information_screen.dart';
import 'package:runway/home_temp_screen.dart';
import '../features/register/page/register_screen.dart';
import 'package:runway/features/profile/page/profile_screen.dart';
import '../features/password_change/page/password_change_screen.dart';
import '../features/profile/page/update_profile_screen.dart';
import '../features/simulation/page/simulation_temp_screen.dart';
import '../features/portfolio/page/get_portfolio_temp_screen.dart';
import '../features/portfolio/page/create_portfolio_temp_screen.dart';
import 'package:runway/features/portfolio/model/create_portfolio_input.dart';
import '../features/portfolio/page/get_portfolio_detail_temp_screen.dart';
import '../features/post/page/create_post_temp_screen.dart';
import '../features/post/page/get_my_post_temp_screen.dart';
import '../features/post/page/get_post_temp_screen.dart';
import '../features/post/page/update_post_temp_screen.dart';
import 'package:runway/features/post/model/post.dart';
import '../features/post/page/get_post_detail_temp_screen.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(path: '/register', builder: (context, state) => RegisterScreen()),
      GoRoute(path: '/login', builder: (context, state) => LoginScreen()),
      GoRoute(path: '/profile', builder: (context, state) => ProfileScreen()),
      GoRoute(
        path: '/profile/update',
        builder: (context, state) => UpdateProfileScreen(),
      ),
      GoRoute(
        path: '/password-change',
        builder: (context, state) => PasswordChangeScreen(),
      ),
      GoRoute(path: '/logout', builder: (context, state) => LogoutTempScreen()),
      GoRoute(
        path: '/reset-password',
        builder: (context, state) => RequestPasswordResetScreen(),
      ),
      GoRoute(
        path: '/reset-password/new',
        builder: (context, state) => PasswordResetScreen(),
      ),
      GoRoute(
        path: '/simulation',
        builder: (context, state) => SimulationTempScreen(),
      ),
      GoRoute(
        path: '/portfolio/get',
        builder: (context, state) {
          final bool isSelectionMode = (state.extra is bool)
              ? state.extra as bool
              : false;

          return GetPortfolioTempScreen(isSelectionMode: isSelectionMode);
        },
      ),
      GoRoute(
        path: '/portfolio/create',
        builder: (context, state) {
          final createPortfolioInput = state.extra as CreatePortfolioInput;

          return CreatePortfolioTempScreen(
            createPortfolioInput: createPortfolioInput,
          );
        },
      ),
      GoRoute(
        path: '/portfolio/get/detail/:portfolioId',
        builder: (context, state) {
          final String portfolioId = state.pathParameters['portfolioId']!;

          return GetPortfolioDetailTempScreen(portfolioId: portfolioId);
        },
      ),
      GoRoute(
        path: '/portfolio/get/detail/snapshot/:portfolioSnapshotId',
        builder: (context, state) {
          final String portfolioSnapshotId =
              state.pathParameters['portfolioSnapshotId']!;

          return GetPortfolioDetailTempScreen.snapshot(
            portfolioSnapshotId: portfolioSnapshotId,
          );
        },
      ),
      GoRoute(
        path: '/post/create',
        builder: (context, state) => const CreatePostTempScreen(),
      ),
      GoRoute(
        path: '/post/get/me',
        builder: (context, state) => const GetMyPostTempScreen(),
      ),
      GoRoute(
        path: '/post/get',
        builder: (context, state) => const GetPostTempScreen(),
      ),
      GoRoute(
        path: '/post/update',
        builder: (context, state) {
          final Post post = state.extra as Post;
          return UpdatePostTempScreen(post: post);
        },
      ),
      GoRoute(
        path: '/post/get/detail/:postId',
        builder: (context, state) {
          final String postId = state.pathParameters['postId']!;
          return GetPostDetailTempScreen(postId: postId);
        },
      ),
      GoRoute(
        path: '/devhome',
        builder: (context, state) => const HomeTempScreen(),
      ),
      GoRoute(
        path: '/app-info',
        builder: (context, state) => const AppInformationScreen(),
      ),
    ],
  );
}
