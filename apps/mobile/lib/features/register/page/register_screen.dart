import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:runway/core/theme/app_colors.dart';
import 'package:runway/core/theme/app_typography.dart';
import 'package:runway/shared/widgets/button.dart';

import '../../../core/providers.dart';
import '../../../core/state/async_state.dart';

class RegisterScreen extends ConsumerWidget {
  RegisterScreen({super.key});

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final passwordConfirmController = TextEditingController();
  final displayNameController = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final registerState = ref.watch(registerControllerProvider);

    ref.listen(registerControllerProvider, (prev, next) {
      if (next.status == AsyncStatus.error && next.error != null) {
        final errorMsg = next.error!.message;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMsg)));
      }
    });

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
          '회원가입',
          style: AppTypography.heading.h4.copyWith(
            color: AppColors.natural.textColors.primary,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
                controller: passwordConfirmController,

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
                controller: displayNameController,

                style: AppTypography.body.m.copyWith(
                  color: AppColors.natural.textColors.primary,
                ),

                decoration: InputDecoration(
                  labelText: '닉네임',

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
              const SizedBox(height: 24),
              AppButton(
                text: registerState.status == AsyncStatus.loading
                    ? '회원가입 중 중...'
                    : '회원가입',
                variant: ButtonVariant.primary,
                onPressed: () {
                  ref
                      .read(registerControllerProvider.notifier)
                      .register(
                        email: emailController.text,
                        password: passwordController.text,
                        passwordConfirm: passwordConfirmController.text,
                        displayName: displayNameController.text,
                      );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
