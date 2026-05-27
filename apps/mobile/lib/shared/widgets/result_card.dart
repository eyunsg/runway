import 'package:flutter/material.dart';
import 'package:runway/core/theme/app_colors.dart';
import 'package:runway/core/theme/app_typography.dart';

class AppResultSummaryCard extends StatelessWidget {
  final String title;
  final String resultValue;
  final String monthlyDividendText;
  final String caption;

  const AppResultSummaryCard({
    super.key,
    required this.title,
    required this.resultValue,
    required this.monthlyDividendText,
    required this.caption,
  });

  @override
  Widget build(BuildContext context) {
    return _ResultCardContainer(
      minHeight: 134,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ResultCardTitle(title),
          const SizedBox(height: 8),
          _ResultCardValue(resultValue),
          const SizedBox(height: 8),
          _ResultCardSupportingText(monthlyDividendText),
          const SizedBox(height: 8),
          _ResultCardCaption(caption),
        ],
      ),
    );
  }
}

class AppGoalAnalysisCard extends StatelessWidget {
  final String assetTargetText;
  final String assetYearsText;
  final String dividendTargetText;
  final String dividendYearsText;

  const AppGoalAnalysisCard({
    super.key,
    required this.assetTargetText,
    required this.assetYearsText,
    required this.dividendTargetText,
    required this.dividendYearsText,
  });

  @override
  Widget build(BuildContext context) {
    return _ResultCardContainer(
      minHeight: 100,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _ResultCardTitle('목표 분석'),
          const SizedBox(height: 8),
          _GoalAnalysisRow(
            leftChild: _GoalAnalysisItem(
              targetText: assetTargetText,
              yearsText: assetYearsText,
            ),
            rightChild: _GoalAnalysisItem(
              targetText: dividendTargetText,
              yearsText: dividendYearsText,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultCardContainer extends StatelessWidget {
  final Widget child;
  final double? minHeight;

  const _ResultCardContainer({required this.child, this.minHeight});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: minHeight ?? 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.highlight.dark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}

class _ResultCardTitle extends StatelessWidget {
  final String text;

  const _ResultCardTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: AppTypography.heading.h4.copyWith(
        color: AppColors.natural.textColors.primary,
      ),
    );
  }
}

class _ResultCardValue extends StatelessWidget {
  final String text;

  const _ResultCardValue(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: AppTypography.heading.h1.copyWith(
        color: AppColors.natural.textColors.primary,
      ),
    );
  }
}

class _ResultCardSupportingText extends StatelessWidget {
  final String text;

  const _ResultCardSupportingText(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: AppTypography.body.m.copyWith(
        color: AppColors.natural.textColors.primary,
      ),
    );
  }
}

class _ResultCardCaption extends StatelessWidget {
  final String text;

  const _ResultCardCaption(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: AppTypography.caption.m.copyWith(
        color: AppColors.natural.textColors.secondary,
      ),
    );
  }
}

class _GoalAnalysisRow extends StatelessWidget {
  final Widget leftChild;
  final Widget rightChild;

  const _GoalAnalysisRow({required this.leftChild, required this.rightChild});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: leftChild),
        const SizedBox(width: 8),
        Expanded(child: rightChild),
      ],
    );
  }
}

class _GoalAnalysisItem extends StatelessWidget {
  final String targetText;
  final String yearsText;

  const _GoalAnalysisItem({required this.targetText, required this.yearsText});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          targetText,
          textAlign: TextAlign.center,
          style: AppTypography.body.m.copyWith(
            color: AppColors.natural.textColors.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          yearsText,
          textAlign: TextAlign.center,
          style: AppTypography.heading.h3.copyWith(
            color: AppColors.natural.textColors.primary,
          ),
        ),
      ],
    );
  }
}
