import 'package:flutter/material.dart';

import 'package:runway/core/theme/app_colors.dart';
import 'package:runway/core/theme/app_typography.dart';
import 'package:runway/shared/widgets/avatar.dart';

class CommentInputWidget extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSubmit;

  const CommentInputWidget({
    super.key,
    required this.controller,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Avatar(size: IconSize.s),

          const SizedBox(width: 16),

          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.highlight.dark,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      style: AppTypography.body.m.copyWith(
                        color: AppColors.natural.textColors.primary,
                      ),
                      decoration: InputDecoration(
                        hintText: '댓글로 의견을 남겨보세요',
                        hintStyle: AppTypography.body.m.copyWith(
                          color: AppColors.natural.textColors.secondary,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  GestureDetector(
                    onTap: onSubmit,
                    child: Container(
                      width: 30,
                      height: 30,
                      margin: const EdgeInsets.only(right: 16),
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
          ),
        ],
      ),
    );
  }
}
