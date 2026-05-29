import 'package:flutter/material.dart';
import 'package:runway/core/theme/app_colors.dart';
import 'package:runway/core/theme/app_typography.dart';

class AppPercentileResult extends StatelessWidget {
  final String leftValue;
  final String centerValue;
  final String rightValue;

  const AppPercentileResult({
    super.key,
    required this.leftValue,
    required this.centerValue,
    required this.rightValue,
  });

  static const double _designHeight = 83;
  static const double _barHeight = 8;
  static const double _outerCircleSize = 20;
  static const double _valueBoxWidth = 62;
  static const double _valueBoxHeight = 40;
  static const double _verticalGap = 16;
  static const double _horizontalInset = 18;

  double _valueBoxLeft({required double centerX, required double layoutWidth}) {
    final double left = centerX - (_valueBoxWidth / 2);
    if (left < 0) return 0;
    if (left + _valueBoxWidth > layoutWidth) {
      return layoutWidth - _valueBoxWidth;
    }
    return left;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double layoutWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : 316;

        final double leftCenterX = _horizontalInset + (_outerCircleSize / 2);
        final double rightCenterX =
            layoutWidth - _horizontalInset - (_outerCircleSize / 2);
        final double centerX = layoutWidth / 2;

        return SizedBox(
          width: layoutWidth,
          height: _designHeight,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: layoutWidth,
                height: _outerCircleSize,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      left: leftCenterX,
                      top: (_outerCircleSize - _barHeight) / 2,
                      child: Container(
                        width: rightCenterX - leftCenterX,
                        height: _barHeight,
                        decoration: BoxDecoration(
                          color: AppColors.highlight.light,
                          borderRadius: BorderRadius.circular(_barHeight / 2),
                        ),
                      ),
                    ),
                    Positioned(
                      left: leftCenterX - (_outerCircleSize / 2),
                      top: 0,
                      child: const _PercentilePoint(
                        innerColor: AppColors.error,
                      ),
                    ),
                    Positioned(
                      left: centerX - (_outerCircleSize / 2),
                      top: 0,
                      child: _PercentilePoint(
                        innerColor: AppColors.natural.textColors.primary,
                      ),
                    ),
                    Positioned(
                      left: rightCenterX - (_outerCircleSize / 2),
                      top: 0,
                      child: const _PercentilePoint(
                        innerColor: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: _verticalGap),
              SizedBox(
                width: layoutWidth,
                height: _valueBoxHeight,
                child: Stack(
                  children: [
                    Positioned(
                      left: _valueBoxLeft(
                        centerX: leftCenterX,
                        layoutWidth: layoutWidth,
                      ),
                      child: _PercentileValueBox(value: leftValue),
                    ),
                    Positioned(
                      left: _valueBoxLeft(
                        centerX: centerX,
                        layoutWidth: layoutWidth,
                      ),
                      child: _PercentileValueBox(value: centerValue),
                    ),
                    Positioned(
                      left: _valueBoxLeft(
                        centerX: rightCenterX,
                        layoutWidth: layoutWidth,
                      ),
                      child: _PercentileValueBox(value: rightValue),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PercentilePoint extends StatelessWidget {
  final Color innerColor;

  const _PercentilePoint({required this.innerColor});

  static const double _outerCircleSize = 20;
  static const double _innerCircleSize = 10;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _outerCircleSize,
      height: _outerCircleSize,
      child: Center(
        child: Container(
          width: _outerCircleSize,
          height: _outerCircleSize,
          decoration: BoxDecoration(
            color: AppColors.natural.textColors.primary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Container(
              width: _innerCircleSize,
              height: _innerCircleSize,
              decoration: BoxDecoration(
                color: innerColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PercentileValueBox extends StatelessWidget {
  final String value;

  const _PercentileValueBox({required this.value});

  static const double _width = 62;
  static const double _height = 40;
  static const double _radius = 12;

  void _showValueBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.highlight.dark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.natural.textColors.secondary.withValues(
                      alpha: 0.3,
                    ),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  '금액',
                  style: AppTypography.heading.h4.copyWith(
                    color: AppColors.natural.textColors.primary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  value,
                  textAlign: TextAlign.center,
                  style: AppTypography.body.m.copyWith(
                    color: AppColors.natural.textColors.primary,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showValueBottomSheet(context),
        borderRadius: BorderRadius.circular(_radius),
        splashColor: AppColors.natural.textColors.primary.withValues(
          alpha: 0.05,
        ),
        highlightColor: Colors.transparent,
        child: Container(
          width: _width,
          height: _height,
          padding: const EdgeInsets.symmetric(horizontal: 6.5, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.natural.textColors.disabled,
            borderRadius: BorderRadius.circular(_radius),
          ),
          child: Center(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: AppTypography.body.s.copyWith(
                color: AppColors.natural.textColors.primary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
