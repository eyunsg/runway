import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:runway/core/theme/app_colors.dart';
import 'package:runway/core/theme/app_typography.dart';
import 'package:runway/features/password_reset/types/password_reset_state.dart';
import 'package:runway/shared/widgets/button.dart';

import '../../../core/providers.dart';
import '../../../core/state/async_state.dart';

class RequestPasswordResetScreen extends ConsumerStatefulWidget {
  const RequestPasswordResetScreen({super.key});

  @override
  ConsumerState<RequestPasswordResetScreen> createState() =>
      _RequestPasswordResetScreenState();
}

class _RequestPasswordResetScreenState
    extends ConsumerState<RequestPasswordResetScreen> {
  late final TextEditingController emailController;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.read(
      requestPasswordResetControllerProvider.notifier,
    );
    final state = ref.watch(requestPasswordResetControllerProvider);

    ref.listen<RequestPasswordResetState>(
      requestPasswordResetControllerProvider,
      (previous, next) {
        final msg = ref
            .read(requestPasswordResetControllerProvider.notifier)
            .message;
        if (msg != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(msg)));
        }
      },
    );

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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '비밀번호를 잊으셨나요?',
                style: AppTypography.heading.h1.copyWith(
                  color: AppColors.natural.textColors.primary,
                ),
              ),
              const SizedBox(height: 24),
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
              const SizedBox(height: 24),
              AppButton(
                text: state.status == AsyncStatus.loading
                    ? '보내는 중...'
                    : '인증 메일 보내기',
                variant: ButtonVariant.primary,
                onPressed: () {
                  controller.requestReset(email: emailController.text);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
