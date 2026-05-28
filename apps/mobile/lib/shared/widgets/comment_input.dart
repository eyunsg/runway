import 'package:flutter/material.dart';

import 'package:runway/core/theme/app_colors.dart';
import 'package:runway/core/theme/app_typography.dart';
import 'package:runway/shared/widgets/avatar.dart';

class CommentInputWidget extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback? onSubmit;
  final bool isSubmitting;
  final bool enabled;

  const CommentInputWidget({
    super.key,
    required this.controller,
    required this.onSubmit,
    this.isSubmitting = false,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: AppColors.natural.textColors.disabled,
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Avatar(size: IconSize.s),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.highlight.dark,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextField(
                  controller: controller,
                  minLines: 1,
                  maxLines: 5,
                  enabled: enabled,
                  style: AppTypography.body.m.copyWith(
                    color: AppColors.natural.textColors.primary,
                  ),
                  decoration: InputDecoration(
                    hintText: '댓글로 의견을 남겨보세요',
                    hintStyle: AppTypography.body.m.copyWith(
                      color: AppColors.natural.textColors.secondary,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            isSubmitting
                ? const SizedBox(
                    width: 30,
                    height: 30,
                    child: Padding(
                      padding: EdgeInsets.all(4.0),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : GestureDetector(
                    onTap: enabled ? onSubmit : null,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: AppColors.natural.textColors.disabled,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Image.asset(
                        '/icons/send.png',
                        width: 15,
                        height: 15,
                        color: AppColors.natural.textColors.primary,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
