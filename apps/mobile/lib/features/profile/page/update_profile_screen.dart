import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:runway/core/theme/app_colors.dart';
import 'package:runway/core/theme/app_typography.dart';
import 'package:runway/shared/widgets/avatar.dart';
import 'package:runway/shared/widgets/button.dart';

import '../types/profile_state.dart';
import 'package:runway/core/providers.dart';
import 'package:go_router/go_router.dart';

class UpdateProfileScreen extends ConsumerStatefulWidget {
  const UpdateProfileScreen({super.key});

  @override
  ConsumerState<UpdateProfileScreen> createState() =>
      _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends ConsumerState<UpdateProfileScreen> {
  late final TextEditingController _nicknameController;

  late final ProviderSubscription<ProfileState> _updateSub;

  @override
  void initState() {
    super.initState();

    _nicknameController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(profileControllerProvider.notifier).fetchProfile();
      final profileState = ref.read(profileControllerProvider);
      if (profileState.displayName != null) {
        _nicknameController.text = profileState.displayName!;
      }
    });

    _updateSub = ref.listenManual<ProfileState>(
      updateProfileControllerProvider,
      (previous, next) {
        if (!mounted) return;

        if (previous?.isSuccess != true && next.isSuccess == true) {
          ref.invalidate(profileControllerProvider);
          context.pop();
        }

        if (next.error != null && next.error!.isNotEmpty) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(next.error!)));
        }
      },
    );
  }

  @override
  void dispose() {
    _updateSub.close();
    _nicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileControllerProvider);
    final updateState = ref.watch(updateProfileControllerProvider);

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
          '프로필 수정',
          style: AppTypography.heading.h4.copyWith(
            color: AppColors.natural.textColors.primary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [Avatar(size: IconSize.l)],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '이메일',
                      style: AppTypography.heading.h5.copyWith(
                        color: AppColors.natural.textColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: profileState.email ?? "@",
                    enabled: false,

                    style: AppTypography.body.m.copyWith(
                      color: AppColors.natural.textColors.secondary,
                    ),

                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.natural.textColors.disabled,

                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppColors.natural.textColors.disabled,
                        ),
                      ),

                      disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppColors.natural.textColors.disabled,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '닉네임',
                      style: AppTypography.heading.h5.copyWith(
                        color: AppColors.natural.textColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nicknameController,
                    enabled: !updateState.isLoading && !profileState.isLoading,
                    style: AppTypography.body.m.copyWith(
                      color: AppColors.natural.textColors.primary,
                    ),
                    decoration: InputDecoration(
                      hintText: '닉네임을 입력하세요',

                      hintStyle: AppTypography.body.m.copyWith(
                        color: AppColors.natural.textColors.secondary,
                      ),

                      // 기본 상태 (입력 전)
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppColors.natural.textColors.secondary,
                          width: 1,
                        ),
                      ),

                      // 포커스 상태 (입력 중)
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

                  Column(
                    children: [
                      AppButton(
                        text: '비밀번호 변경',
                        variant: ButtonVariant.secondary,
                        onPressed: () {
                          context.push('/password-change');
                        },
                      ),

                      const SizedBox(height: 24),

                      AppButton(
                        text: '회원탈퇴',
                        variant: ButtonVariant.danger,
                        onPressed: () {
                          ref
                              .read(deleteProfileControllerProvider.notifier)
                              .deleteProfile();
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  AppButton(
                    text: updateState.isLoading ? '저장 중...' : '저장하기',
                    variant: ButtonVariant.primary,
                    onPressed: (updateState.isLoading || profileState.isLoading)
                        ? () {}
                        : () {
                            ref
                                .read(updateProfileControllerProvider.notifier)
                                .updateProfile(_nicknameController.text);
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
