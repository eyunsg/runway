import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:runway/core/providers.dart';
import 'package:runway/core/state/async_state.dart';
import 'package:runway/core/theme/app_colors.dart';
import 'package:runway/core/theme/app_typography.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    ref.listen(logoutControllerProvider, (previous, next) {
      if (!mounted) return;

      if (next.status == AsyncStatus.success) {
        context.go('/login');
      } else if (next.status == AsyncStatus.error && next.error != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.error!.message)));
      }
    });

    ref.listen(deleteProfileControllerProvider, (previous, next) {
      if (!mounted) return;

      if (next.isSuccess) {
        context.go('/login');
      } else if (next.error != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.error!)));
      }
    });

    final profileState = ref.watch(profileControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.natural.backgroundColors.primary,
      appBar: AppBar(
        backgroundColor: AppColors.natural.backgroundColors.primary,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: GestureDetector(
            onTap: () {
              context.pop();
            },
            child: SizedBox(
              width: 40,
              height: 40,
              child: Center(
                child: Image.asset(
                  'icons/arrow_left.png',
                  width: 20,
                  height: 20,
                ),
              ),
            ),
          ),
        ),
        centerTitle: true,
        title: Text(
          '설정',
          style: AppTypography.heading.h4.copyWith(
            color: AppColors.natural.textColors.primary,
          ),
        ),
      ),
      body: profileState.isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: AppColors.highlight.light,
              ),
            )
          : profileState.error != null
          ? Center(child: Text(profileState.error!))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  /// profile section
                  Center(
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Image.asset('icons/avatar.png', width: 80, height: 80),

                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              context.push('/profile/update');
                            },
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.highlight.light,
                              ),
                              child: Center(
                                child: Image.asset(
                                  'icons/edit.png',
                                  width: 10,
                                  height: 10,
                                  color: AppColors.natural.textColors.primary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  Text(
                    profileState.displayName ?? '',
                    style: AppTypography.heading.h3.copyWith(
                      color: AppColors.natural.textColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),

                  Text(
                    profileState.email ?? '',
                    style: AppTypography.body.s.copyWith(
                      color: AppColors.natural.textColors.secondary,
                    ),
                  ),

                  /// list item section
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        ListTile(
                          onTap: () {
                            context.push('/app-info');
                          },
                          title: Text(
                            '앱 정보',
                            style: AppTypography.body.m.copyWith(
                              color: AppColors.natural.textColors.primary,
                            ),
                          ),
                          trailing: Image.asset(
                            'icons/arrow_right.png',
                            width: 12,
                            height: 12,
                            color: AppColors.natural.textColors.secondary,
                          ),
                        ),

                        Divider(
                          color: AppColors.natural.textColors.disabled,
                          thickness: 0.5,
                        ),

                        ListTile(
                          title: Text(
                            '로그아웃',
                            style: AppTypography.body.m.copyWith(
                              color: AppColors.error,
                            ),
                          ),
                          onTap: () async {
                            final controller = ref.read(
                              logoutControllerProvider.notifier,
                            );
                            await controller.logout();
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
