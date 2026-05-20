import 'package:flutter/material.dart';
import 'package:runway/core/theme/app_colors.dart' hide Text;
import 'package:runway/core/theme/app_typography.dart';
import './button.dart';

/// - 타이틀, 설명, 2개의 액션 버튼으로 구성된 공통 Dialog 위젯입니다.
/// ```dart
/// AppDialog(
///   title: '삭제하시겠습니까?',
///   description: '삭제한 내용은 되돌릴 수 없습니다.',
///   secondaryButtonText: '취소',
///   primaryButtonText: '삭제',
///   onSecondaryPressed: () {},
///   onPrimaryPressed: () {},
/// )
/// ```
/// [title] : Dialog 상단에 표시할 제목 문자열
/// [description] : 제목 아래에 표시할 설명 문자열
/// [secondaryButtonText] : 왼쪽 secondary 버튼에 표시할 문자열
/// [primaryButtonText] : 오른쪽 primary 버튼에 표시할 문자열
/// [onSecondaryPressed] : 왼쪽 secondary 버튼 클릭 시 호출될 콜백 함수
/// [onPrimaryPressed] : 오른쪽 primary 버튼 클릭 시 호출될 콜백 함수
///
/// - Dialog는 width 300, minHeight 167 기준으로 구현됩니다.
/// - 내부 버튼은 AppButton을 사용하며, 각 버튼은 130 x 40 크기로 배치됩니다.
class AppDialog extends StatelessWidget {
  final String title;
  final String description;
  final String secondaryButtonText;
  final String primaryButtonText;
  final VoidCallback? onSecondaryPressed;
  final VoidCallback? onPrimaryPressed;

  const AppDialog({
    super.key,
    required this.title,
    required this.description,
    required this.secondaryButtonText,
    required this.primaryButtonText,
    this.onSecondaryPressed,
    this.onPrimaryPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      constraints: const BoxConstraints(minHeight: 167),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.highlight.dark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: AppTypography.heading.h3.copyWith(
                    color: AppColors.natural.text.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: AppTypography.body.s.copyWith(
                    color: AppColors.natural.text.secondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
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
