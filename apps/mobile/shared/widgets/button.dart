import 'package:flutter/material.dart';
import 'package:runway/core/theme/app_colors.dart';
import 'package:runway/core/theme/app_typography.dart';

enum ButtonVariant { primary, secondary }

/// - 전체 너비를 채우는 full-width 공통 버튼 위젯입니다.
/// ```dart
/// AppButton(
///   text: '저장',
///   variant: ButtonVariant.primary,
///   onPressed: () {},
/// )
/// ```
/// [text] : 버튼에 표시할 문자열
/// [onPressed] : 버튼 클릭 시 호출될 콜백 함수
/// [variant] : 버튼 스타일 종류 (기본값=primary / secondary)
class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final ButtonVariant variant;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.variant = ButtonVariant.primary,
  });

  Color get _backgroundColor {
    switch (variant) {
      case ButtonVariant.primary:
        return AppColors.highlight.light;
      case ButtonVariant.secondary:
        return Colors.transparent;
    }
  }

  BorderSide get _borderSide {
    switch (variant) {
      case ButtonVariant.primary:
        return BorderSide.none;
      case ButtonVariant.secondary:
        return BorderSide(color: AppColors.highlight.light, width: 1.5);
    }
  }

  Color get _textColor {
    switch (variant) {
      case ButtonVariant.primary:
        return AppColors.natural.textColors.primary;
      case ButtonVariant.secondary:
        return AppColors.highlight.light;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 40,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: _backgroundColor,
          overlayColor: AppColors.highlight.light.withValues(alpha: 0.08),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: _borderSide,
          ),
          elevation: 0,
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: AppTypography.action.m.copyWith(color: _textColor),
        ),
      ),
    );
  }
}
