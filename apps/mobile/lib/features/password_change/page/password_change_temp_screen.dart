import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:runway/core/theme/app_colors.dart';
import 'package:runway/core/theme/app_typography.dart';
import 'package:runway/shared/widgets/button.dart';
import '../../../core/state/async_state.dart';
import '../../../core/providers.dart';

class PasswordChangePage extends ConsumerStatefulWidget {
  const PasswordChangePage({super.key});

  @override
  ConsumerState<PasswordChangePage> createState() => _PasswordChangePageState();
}

class _PasswordChangePageState extends ConsumerState<PasswordChangePage> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(passwordChangeControllerProvider);

    ref.listen(passwordChangeControllerProvider, (previous, next) {
      if (next.message != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.message!)));
      }

      if (next.status == AsyncStatus.success) {
        context.go('/login');
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
          '비밀번호 변경',
          style: AppTypography.heading.h4.copyWith(
            color: AppColors.natural.textColors.primary,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _currentPasswordController,
              enabled: state.status != AsyncStatus.loading,
              obscureText: true,
              style: AppTypography.body.m.copyWith(
                color: AppColors.natural.textColors.primary,
              ),
              decoration: InputDecoration(
                hintText: '현재 비밀번호',

                hintStyle: AppTypography.body.m.copyWith(
                  color: AppColors.natural.textColors.secondary,
                ),

                // 기본 상태
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColors.natural.textColors.secondary,
                    width: 1,
                  ),
                ),

                // 포커스 상태
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColors.highlight.light,
                    width: 1.5,
                  ),
                ),
              ),
              inputFormatters: [
                FilteringTextInputFormatter.deny(RegExp(r'\s')),
              ],
            ),
            const SizedBox(height: 24),

            TextField(
              controller: _newPasswordController,
              enabled: state.status != AsyncStatus.loading,
              obscureText: true,
              style: AppTypography.body.m.copyWith(
                color: AppColors.natural.textColors.primary,
              ),
              decoration: InputDecoration(
                hintText: '새 비밀번호',

                hintStyle: AppTypography.body.m.copyWith(
                  color: AppColors.natural.textColors.secondary,
                ),

                // 기본 상태
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColors.natural.textColors.secondary,
                    width: 1,
                  ),
                ),

                // 포커스 상태
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColors.highlight.light,
                    width: 1.5,
                  ),
                ),
              ),
              inputFormatters: [
                FilteringTextInputFormatter.deny(RegExp(r'\s')),
              ],
            ),
            const SizedBox(height: 24),

            TextField(
              controller: _confirmPasswordController,
              enabled: state.status != AsyncStatus.loading,
              obscureText: true,
              style: AppTypography.body.m.copyWith(
                color: AppColors.natural.textColors.primary,
              ),
              decoration: InputDecoration(
                hintText: '새 비밀번호 확인',

                hintStyle: AppTypography.body.m.copyWith(
                  color: AppColors.natural.textColors.secondary,
                ),

                // 기본 상태
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColors.natural.textColors.secondary,
                    width: 1,
                  ),
                ),

                // 포커스 상태
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColors.highlight.light,
                    width: 1.5,
                  ),
                ),
              ),
              inputFormatters: [
                FilteringTextInputFormatter.deny(RegExp(r'\s')),
              ],
            ),
            const SizedBox(height: 24),

            AppButton(
              text: state.status == AsyncStatus.loading ? '변경 중...' : '비밀번호 변경',
              variant: ButtonVariant.primary,
              onPressed: state.status == AsyncStatus.loading
                  ? () {}
                  : () {
                      FocusScope.of(context).unfocus();

                      ref
                          .read(passwordChangeControllerProvider.notifier)
                          .changePassword(
                            currentPassword: _currentPasswordController.text
                                .trim(),
                            newPassword: _newPasswordController.text.trim(),
                            newPasswordConfirm: _confirmPasswordController.text
                                .trim(),
                          );
                    },
            ),
          ],
        ),
      ),
    );
  }
}
