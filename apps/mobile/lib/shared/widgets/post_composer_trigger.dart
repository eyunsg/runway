import 'package:flutter/material.dart';
import 'package:runway/core/theme/app_colors.dart';
import 'package:runway/core/theme/app_typography.dart';
import 'package:runway/shared/widgets/avatar.dart';

class PostComposerTrigger extends StatelessWidget {
  final VoidCallback onTap;
  final String text;

  const PostComposerTrigger({
    super.key,
    required this.onTap,
    this.text = '무슨 생각을 하고 있나요?',
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          const Avatar(size: IconSize.s),

          const SizedBox(width: 16),

          Expanded(
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: AppColors.highlight.dark,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.centerLeft,
                child: Text(
                  text,
                  style: AppTypography.body.m.copyWith(
                    color: AppColors.natural.textColors.secondary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
