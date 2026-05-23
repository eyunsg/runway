import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:runway/core/providers.dart';
import 'package:runway/core/theme/app_colors.dart';
import 'package:runway/core/theme/app_typography.dart';
import 'package:runway/features/password_reset/types/password_reset_state.dart';
import 'package:runway/shared/widgets/button.dart';
import '../../../core/state/async_state.dart';

class PasswordResetScreen extends ConsumerStatefulWidget {
  const PasswordResetScreen({super.key});

  @override
  ConsumerState<PasswordResetScreen> createState() =>
      _PasswordResetScreenState();
}

class _PasswordResetScreenState extends ConsumerState<PasswordResetScreen> {
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();

    ref.listen<PasswordResetState>(resetPasswordControllerProvider, (
      previous,
      next,
    ) {
      if (!mounted) return;

      if (next.status == AsyncStatus.success) {
        context.go('/login');
      } else if (next.status == AsyncStatus.error && next.error != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.error!.message)));
      }
    });
  }

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.read(resetPasswordControllerProvider.notifier);
    final state = ref.watch(resetPasswordControllerProvider);

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
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '새 비밀번호를 입력하세요',
              style: AppTypography.heading.h1.copyWith(
                color: AppColors.natural.textColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: passwordController,

              style: AppTypography.body.m.copyWith(
                color: AppColors.natural.textColors.primary,
              ),

              decoration: InputDecoration(
                labelText: '비밀번호',

                labelStyle: AppTypography.body.m.copyWith(
                  color: AppColors.natural.textColors.secondary,
                ),

                floatingLabelStyle: AppTypography.body.m.copyWith(
                  color: AppColors.highlight.light,
                ),

                hintStyle: AppTypography.body.m.copyWith(
                  color: AppColors.natural.textColors.secondary,
                ),

                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColors.natural.textColors.secondary,
                    width: 1,
                  ),
                ),

                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColors.highlight.light,
                    width: 1.5,
                  ),
                ),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmPasswordController,

              style: AppTypography.body.m.copyWith(
                color: AppColors.natural.textColors.primary,
              ),

              decoration: InputDecoration(
                labelText: '비밀번호 확인',

                labelStyle: AppTypography.body.m.copyWith(
                  color: AppColors.natural.textColors.secondary,
                ),

                floatingLabelStyle: AppTypography.body.m.copyWith(
                  color: AppColors.highlight.light,
                ),

                hintStyle: AppTypography.body.m.copyWith(
                  color: AppColors.natural.textColors.secondary,
                ),

                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColors.natural.textColors.secondary,
                    width: 1,
                  ),
                ),

                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColors.highlight.light,
                    width: 1.5,
                  ),
                ),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            AppButton(
              text: state.status == AsyncStatus.loading ? '재설정 중...' : '재설정하기',
              variant: ButtonVariant.primary,
              onPressed: () async {
                await controller.resetPassword(
                  newPassword: passwordController.text,
                  passwordConfirm: confirmPasswordController.text,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
