import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:runway/core/theme/app_colors.dart';
import 'package:runway/core/theme/app_typography.dart';
import 'package:runway/shared/widgets/button.dart';

import '../../../core/providers.dart';
import '../../../core/state/async_state.dart';

class LoginScreen extends ConsumerWidget {
  LoginScreen({super.key});

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loginState = ref.watch(loginControllerProvider);

    ref.listen(loginControllerProvider, (prev, next) {
      if (next.status == AsyncStatus.success) {
        context.go('/home');
      }

      if (next.status == AsyncStatus.error && next.error != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.error!.message)));
      }
    });

    return Scaffold(
      backgroundColor: AppColors.natural.backgroundColors.primary,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: emailController,

                style: AppTypography.body.m.copyWith(
                  color: AppColors.natural.textColors.primary,
                ),

                decoration: InputDecoration(
                  labelText: '이메일',

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
              ),

              const SizedBox(height: 16),

              TextField(
                controller: passwordController,
                obscureText: true,

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
              ),

              const SizedBox(height: 16),

              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () {
                    context.push('/reset-password');
                  },

                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),

                  child: Text(
                    '비밀번호를 잊으셨나요?',
                    style: AppTypography.action.m.copyWith(
                      color: AppColors.highlight.light,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              AppButton(
                text: loginState.status == AsyncStatus.loading
                    ? '로그인 중...'
                    : '로그인',
                variant: ButtonVariant.primary,
                onPressed: loginState.status == AsyncStatus.loading
                    ? () {}
                    : () {
                        ref
                            .read(loginControllerProvider.notifier)
                            .login(
                              email: emailController.text,
                              password: passwordController.text,
                            );
                      },
              ),

              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '회원이 아니신가요? ',
                    style: AppTypography.body.s.copyWith(
                      color: AppColors.natural.textColors.secondary,
                    ),
                  ),

                  TextButton(
                    onPressed: () {
                      context.push('/register');
                    },

                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),

                    child: Text(
                      '회원가입',
                      style: AppTypography.action.m.copyWith(
                        color: AppColors.highlight.light,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
