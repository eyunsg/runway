import 'package:flutter/material.dart';
import 'package:runway/core/theme/app_colors.dart';
import 'package:runway/core/theme/app_typography.dart';
import 'package:runway/shared/widgets/avator.dart';

//제출예정
class ContentPortfolioData {
  final String title;
  final String subtitle;

  const ContentPortfolioData({required this.title, required this.subtitle});
}

class AppContentCard extends StatelessWidget {
  final String displayName;
  final String dateText;
  final String content;
  final bool showMoreAction;
  final VoidCallback? onTap;
  final VoidCallback? onMoreTap;
  final ContentPortfolioData? portfolioData;
  final VoidCallback? onPortfolioTap;

  const AppContentCard({
    super.key,
    required this.displayName,
    required this.dateText,
    required this.content,
    this.showMoreAction = false,
    this.onTap,
    this.onMoreTap,
    this.portfolioData,
    this.onPortfolioTap,
  });

  static const double _headerBodyGap = 8;
  static const double _bodyPortfolioGap = 8;

  @override
  Widget build(BuildContext context) {
    final card = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _ContentCardHeader(
          displayName: displayName,
          dateText: dateText,
          showMoreAction: showMoreAction,
          onMoreTap: onMoreTap,
        ),
        const SizedBox(height: _headerBodyGap),
        _ContentCardBody(content: content),
        if (portfolioData != null) ...[
          const SizedBox(height: _bodyPortfolioGap),
          _ContentCardPortfolioLink(
            data: portfolioData!,
            onTap: onPortfolioTap,
          ),
        ],
      ],
    );

    if (onTap == null) {
      return card;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: AppColors.natural.textColors.primary.withValues(
          alpha: 0.04,
        ),
        highlightColor: Colors.transparent,
        child: card,
      ),
    );
  }
}

class _ContentCardHeader extends StatelessWidget {
  final String displayName;
  final String dateText;
  final bool showMoreAction;
  final VoidCallback? onMoreTap;

  const _ContentCardHeader({
    required this.displayName,
    required this.dateText,
    required this.showMoreAction,
    required this.onMoreTap,
  });

  static const double _avatarTextGap = 16;
  static const double _nameDateGap = 4;
  static const double _moreIconSize = 16;
  static const double _moreTapWidth = 24;
  static const double _moreTapHeight = 24;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Avatar(size: IconSize.s),
        const SizedBox(width: _avatarTextGap),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 1.5),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.heading.h4.copyWith(
                    color: AppColors.natural.textColors.primary,
                  ),
                ),
                const SizedBox(height: _nameDateGap),
                Text(
                  dateText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.body.s.copyWith(
                    color: AppColors.natural.textColors.secondary,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (showMoreAction) ...[
          const SizedBox(width: 8),
          SizedBox(
            width: _moreTapWidth,
            height: _moreTapHeight,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onMoreTap,
                customBorder: const CircleBorder(),
                splashColor: AppColors.natural.textColors.secondary.withValues(
                  alpha: 0.10,
                ),
                highlightColor: Colors.transparent,
                child: Center(
                  child: Image.asset(
                    'assets/icons/more_horizontal.png',
                    width: _moreIconSize,
                    height: _moreIconSize,
                    color: AppColors.natural.textColors.secondary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _ContentCardBody extends StatelessWidget {
  final String content;

  const _ContentCardBody({required this.content});

  @override
  Widget build(BuildContext context) {
    return Text(
      content,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: AppTypography.body.s.copyWith(
        color: AppColors.natural.textColors.secondary,
      ),
    );
  }
}

class _ContentCardPortfolioLink extends StatelessWidget {
  final ContentPortfolioData data;
  final VoidCallback? onTap;

  const _ContentCardPortfolioLink({required this.data, this.onTap});

  static const double _minHeight = 69;
  static const double _radius = 16;
  static const double _horizontalPadding = 16;
  static const double _verticalPadding = 14;
  static const double _titleSubtitleGap = 4;
  static const double _chevronSize = 12;

  @override
  Widget build(BuildContext context) {
    final child = Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: _minHeight),
      padding: const EdgeInsets.symmetric(
        horizontal: _horizontalPadding,
        vertical: _verticalPadding,
      ),
      decoration: BoxDecoration(
        color: AppColors.highlight.dark,
        borderRadius: BorderRadius.circular(_radius),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.heading.h4.copyWith(
                    color: AppColors.natural.textColors.primary,
                  ),
                ),
                const SizedBox(height: _titleSubtitleGap),
                Text(
                  data.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.body.s.copyWith(
                    color: AppColors.natural.textColors.secondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Image.asset(
            'assets/icons/arrow_right.png',
            width: _chevronSize,
            height: _chevronSize,
            color: AppColors.natural.textColors.secondary,
          ),
        ],
      ),
    );

    if (onTap == null) {
      return child;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(_radius),
        splashColor: AppColors.natural.textColors.primary.withValues(
          alpha: 0.05,
        ),
        highlightColor: Colors.transparent,
        child: child,
      ),
    );
  }
}
