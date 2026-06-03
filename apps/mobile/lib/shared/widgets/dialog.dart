import 'package:flutter/material.dart';
import 'package:runway/core/theme/app_colors.dart';
import 'package:runway/core/theme/app_typography.dart';
import 'button.dart';

/// - 타이틀, 설명(선택), 2개의 액션 버튼으로 구성된 공통 Dialog 위젯입니다.
/// ```dart
/// AppDialog(
///   title: '삭제하시겠습니까?',
///   description: '삭제한 내용은 되돌릴 수 없습니다.', // 생략 가능
///   secondaryButtonText: '취소',
///   primaryButtonText: '삭제',
///   onSecondaryPressed: () {},
///   onPrimaryPressed: () {},
/// )
/// ```
class AppDialog extends StatelessWidget {
  final String title;
  final String? description;
  final String secondaryButtonText;
  final String primaryButtonText;
  final VoidCallback? onSecondaryPressed;
  final VoidCallback? onPrimaryPressed;

  const AppDialog({
    super.key,
    required this.title,
    this.description,
    required this.secondaryButtonText,
    required this.primaryButtonText,
    this.onSecondaryPressed,
    this.onPrimaryPressed,
  });

  @override
  Widget build(BuildContext context) {
    final hasDescription = description != null && description!.isNotEmpty;

    return Container(
      width: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.highlight.dark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              top: 8,
              left: 8,
              right: 8,
              bottom: 4,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: AppTypography.heading.h3.copyWith(
                    color: AppColors.natural.textColors.primary,
                  ),
                ),
                if (hasDescription) ...[
                  const SizedBox(height: 8),
                  Text(
                    description!,
                    textAlign: TextAlign.center,
                    style: AppTypography.body.s.copyWith(
                      color: AppColors.natural.textColors.secondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(height: hasDescription ? 20 : 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 130,
                height: 40,
                child: AppButton(
                  text: secondaryButtonText,
                  variant: ButtonVariant.secondary,
                  onPressed: onSecondaryPressed ?? () {},
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 130,
                height: 40,
                child: AppButton(
                  text: primaryButtonText,
                  variant: ButtonVariant.primary,
                  onPressed: onPrimaryPressed ?? () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
