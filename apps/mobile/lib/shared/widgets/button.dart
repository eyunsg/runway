import 'package:flutter/material.dart';
import 'package:runway/core/theme/app_colors.dart';
import 'package:runway/core/theme/app_typography.dart';

enum ButtonVariant { primary, secondary, danger, disabled }

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
      case ButtonVariant.danger:
        return Colors.transparent;
      case ButtonVariant.disabled:
        return Colors.transparent;
    }
  }

  BorderSide get _borderSide {
    switch (variant) {
      case ButtonVariant.primary:
        return BorderSide.none;
      case ButtonVariant.secondary:
        return BorderSide(color: AppColors.highlight.light, width: 1.5);
      case ButtonVariant.danger:
        return BorderSide(color: AppColors.error, width: 1.5);
      case ButtonVariant.disabled:
        return BorderSide(
          color: AppColors.natural.textColors.disabled,
          width: 1.5,
        );
    }
  }

  Color get _textColor {
    switch (variant) {
      case ButtonVariant.primary:
        return AppColors.natural.textColors.primary;
      case ButtonVariant.secondary:
        return AppColors.highlight.light;
      case ButtonVariant.danger:
        return AppColors.error;
      case ButtonVariant.disabled:
        return AppColors.natural.textColors.disabled;
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
