import 'package:flutter/material.dart';
import 'package:runway/core/theme/app_colors.dart';
import 'package:runway/core/theme/app_typography.dart';

//제출예정
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

  static const double _designWidth = 316;
  static const double _designHeight = 83;
  static const double _barHeight = 8;
  static const double _outerCircleSize = 20;
  static const double _circleGap = 130;
  static const double _circleStart = 18;
  static const double _valueBoxWidth = 56;
  static const double _valueBoxHeight = 40;
  static const double _verticalGap = 16;

  double get _leftPointCenterX => _circleStart + (_outerCircleSize / 2);
  double get _centerPointCenterX =>
      _circleStart + _circleGap + (_outerCircleSize / 2);
  double get _rightPointCenterX =>
      _circleStart + (_circleGap * 2) + (_outerCircleSize / 2);

  double _valueBoxLeft(double centerX) {
    final double left = centerX - (_valueBoxWidth / 2);
    if (left < 0) return 0;
    if (left + _valueBoxWidth > _designWidth) {
      return _designWidth - _valueBoxWidth;
    }
    return left;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double availableWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : _designWidth;
        final double actualWidth = availableWidth < _designWidth
            ? availableWidth
            : _designWidth;

        return SizedBox(
          width: actualWidth,
          child: FittedBox(
            fit: BoxFit.contain,
            alignment: Alignment.center,
            child: SizedBox(
              width: _designWidth,
              height: _designHeight,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: _designWidth,
                    height: _outerCircleSize,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned(
                          left: _leftPointCenterX,
                          top: (_outerCircleSize - _barHeight) / 2,
                          child: Container(
                            width: _rightPointCenterX - _leftPointCenterX,
                            height: _barHeight,
                            decoration: BoxDecoration(
                              color: AppColors.highlight.light,
                              borderRadius: BorderRadius.circular(
                                _barHeight / 2,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          left: _circleStart,
                          top: 0,
                          child: const _PercentilePoint(),
                        ),
                        Positioned(
                          left: _circleStart + _circleGap,
                          top: 0,
                          child: const _PercentilePoint(),
                        ),
                        Positioned(
                          left: _circleStart + (_circleGap * 2),
                          top: 0,
                          child: const _PercentilePoint(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: _verticalGap),
                  SizedBox(
                    width: _designWidth,
                    height: _valueBoxHeight,
                    child: Stack(
                      children: [
                        Positioned(
                          left: _valueBoxLeft(_leftPointCenterX),
                          child: _PercentileValueBox(value: leftValue),
                        ),
                        Positioned(
                          left: _valueBoxLeft(_centerPointCenterX),
                          child: _PercentileValueBox(value: centerValue),
                        ),
                        Positioned(
                          left: _valueBoxLeft(_rightPointCenterX),
                          child: _PercentileValueBox(value: rightValue),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PercentilePoint extends StatelessWidget {
  const _PercentilePoint();

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
                color: AppColors.highlight.light,
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

  static const double _width = 56;
  static const double _height = 40;
  static const double _radius = 12;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _width,
      height: _height,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.natural.textColors.disabled,
        borderRadius: BorderRadius.circular(_radius),
      ),
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            maxLines: 1,
            style: AppTypography.body.s.copyWith(
              color: AppColors.natural.textColors.primary,
            ),
          ),
        ),
      ),
    );
  }
}
