import 'package:flutter/material.dart';
import 'package:runway/core/theme/app_colors.dart';
import 'package:runway/core/theme/app_typography.dart';

/// 메시지 타입 정의
enum ToastType { success, error }

/// 토스트 컴포넌트
class AppToast extends StatelessWidget {
  final String title;
  final ToastType type;

  const AppToast({super.key, required this.title, required this.type});

  /// 토스트 타입에 따른 아이콘 에셋 경로 매핑
  String get _iconAssetPath {
    switch (type) {
      case ToastType.success:
        return '/icons/Success.png';
      case ToastType.error:
        return '/icons/Warning.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 56.0),
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: AppColors.highlight.dark,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            _iconAssetPath,
            width: 22.0,
            height: 22.0,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 16.0),
          Expanded(
            child: Text(
              title,
              style: AppTypography.heading.h5.copyWith(
                color: AppColors.natural.textColors.primary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
