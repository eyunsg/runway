import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:runway/core/providers.dart';
import 'package:go_router/go_router.dart';
import 'package:runway/features/portfolio/model/create_portfolio_input.dart';
import 'package:runway/core/theme/app_colors.dart';
import 'package:runway/core/theme/app_typography.dart';
import 'package:runway/shared/widgets/result_card.dart';
import 'package:runway/shared/widgets/percentile_result.dart';

class CreatePortfolioScreen extends ConsumerStatefulWidget {
  final CreatePortfolioInput createPortfolioInput;

  const CreatePortfolioScreen({super.key, required this.createPortfolioInput});

  @override
  ConsumerState<CreatePortfolioScreen> createState() =>
      _CreatePortfolioScreenState();
}

class _CreatePortfolioScreenState extends ConsumerState<CreatePortfolioScreen> {
  @override
  Widget build(BuildContext context) {
    final portfolioState = ref.watch(createPortfolioControllerProvider);

    ref.listen(createPortfolioControllerProvider, (previous, next) {
      if (next.error != null && next.error!.isNotEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.error!)));
      }

      if (next.isSuccess && previous?.isSuccess != true) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('포트폴리오 생성이 완료되었습니다.')));
        context.go('/portfolio/get');
      }
    });

    // 렌더링 전용 데이터 참조
    final createPortfolioInput = widget.createPortfolioInput;
    final simulationInput = createPortfolioInput.simulationInput;
    final simulationResult = createPortfolioInput.simulationResult;

    // 상단 요약/슬라이더/목표 분석에 필요한 값 추출
    final investmentPeriodYears =
        (simulationInput.goal.investmentPeriodMonths / 12).floor();

    final portfolioValuePercentiles =
        simulationResult.percentiles.portfolioValue;
    final monthlyDividendPercentiles =
        simulationResult.percentiles.monthlyDividend;

    final portfolioValueGoalMonths =
        simulationResult.goalAnalysis.portfolioValueGoal.expectedMonthsToTarget;

    final monthlyDividendGoalMonths = simulationResult
        .goalAnalysis
        .monthlyDividendGoal
        .expectedMonthsToTarget;

    // 상단 카드 대표값 중위값 기준
    final portfolioValueMedianText = _formatKrwAmount(
      portfolioValuePercentiles.p50,
    );
    final monthlyDividendMedianText = _formatKrwAmount(
      monthlyDividendPercentiles.p50,
    );

    // 목표 분석 문구 생성
    final portfolioGoalSummaryText =
        '자산 ${_formatKrwAmount(simulationInput.goal.targetPortfolioValue)}까지';

    final monthlyDividendGoalSummaryText =
        '배당 ${_formatKrwAmount(simulationInput.goal.targetMonthlyDividend)}까지';

    final portfolioGoalMonthsText = _formatExpectedMonthsToTarget(
      portfolioValueGoalMonths,
    );
    final monthlyDividendGoalMonthsText = _formatExpectedMonthsToTarget(
      monthlyDividendGoalMonths,
    );

    return Scaffold(
      backgroundColor: AppColors.natural.backgroundColors.primary,
      appBar: AppBar(
        backgroundColor: AppColors.natural.backgroundColors.primary,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: SizedBox(
            width: 40,
            height: 40,
            child: GestureDetector(
              onTap: () {
                context.pop();
              },
              child: Center(
                child: Image.asset(
                  'icons/arrow_left.png',
                  width: 20,
                  height: 20,
                ),
              ),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: TextButton(
              onPressed: portfolioState.isLoading
                  ? null
                  : () async {
                      await ref
                          .read(createPortfolioControllerProvider.notifier)
                          .createPortfolio(widget.createPortfolioInput);
                    },
              child: Text(
                portfolioState.isLoading ? '추가 중...' : '추가하기',
                style: AppTypography.body.m.copyWith(
                  color: portfolioState.isLoading
                      ? AppColors.natural.textColors.disabled
                      : AppColors.natural.textColors.secondary,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: portfolioState.isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: AppColors.highlight.light,
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppResultSummaryCard(
                      title: '$investmentPeriodYears년 후 예상 결과',
                      resultValue: portfolioValueMedianText,
                      monthlyDividendText: '월 배당금: $monthlyDividendMedianText',
                      caption: '(중위값 기준)',
                    ),
                    const SizedBox(height: 24),

                    AppGoalAnalysisCard(
                      assetTargetText: portfolioGoalSummaryText,
                      assetYearsText: portfolioGoalMonthsText,
                      dividendTargetText: monthlyDividendGoalSummaryText,
                      dividendYearsText: monthlyDividendGoalMonthsText,
                    ),
                    const SizedBox(height: 24),

                    Text(
                      '평가금액',
                      textAlign: TextAlign.center,
                      style: AppTypography.heading.h4.copyWith(
                        color: AppColors.natural.textColors.primary,
                      ),
                    ),
                    const SizedBox(height: 8),

                    Text(
                      '80% 확률로 이 범위 안에 결과가 형성됩니다.',
                      textAlign: TextAlign.center,
                      style: AppTypography.caption.m.copyWith(
                        color: AppColors.natural.textColors.secondary,
                      ),
                    ),
                    const SizedBox(height: 8),

                    AppPercentileResult(
                      leftValue: _formatKrwAmount(
                        portfolioValuePercentiles.p10,
                      ),
                      centerValue: _formatKrwAmount(
                        portfolioValuePercentiles.p50,
                      ),
                      rightValue: _formatKrwAmount(
                        portfolioValuePercentiles.p90,
                      ),
                    ),
                    const SizedBox(height: 24),

                    Divider(
                      height: 1,
                      thickness: 1,
                      color: AppColors.natural.textColors.disabled,
                    ),
                    const SizedBox(height: 24),

                    Text(
                      '배당금액',
                      textAlign: TextAlign.center,
                      style: AppTypography.heading.h4.copyWith(
                        color: AppColors.natural.textColors.primary,
                      ),
                    ),
                    const SizedBox(height: 8),

                    Text(
                      '80% 확률로 이 범위 안에 결과가 형성됩니다.',
                      textAlign: TextAlign.center,
                      style: AppTypography.caption.m.copyWith(
                        color: AppColors.natural.textColors.secondary,
                      ),
                    ),
                    const SizedBox(height: 8),

                    AppPercentileResult(
                      leftValue: _formatKrwAmount(
                        monthlyDividendPercentiles.p10,
                      ),
                      centerValue: _formatKrwAmount(
                        monthlyDividendPercentiles.p50,
                      ),
                      rightValue: _formatKrwAmount(
                        monthlyDividendPercentiles.p90,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  // 목표 도달 개월 처리 포함 텍스트 포맷
  String _formatExpectedMonthsToTarget(int? months) {
    if (months == null) {
      return '목표 도달 불가';
    }

    if (months < 12) {
      return '$months개월';
    }

    final years = months ~/ 12;
    final remainingMonths = months % 12;

    if (remainingMonths == 0) {
      return '$years년';
    }

    return '$years년 $remainingMonths개월';
  }

  String _formatKrwAmount(num value) {
    final int roundedValue = value.round();
    final int absValue = roundedValue.abs();

    if (absValue >= 1000000000000) {
      final double jo = roundedValue / 1000000000000;
      if (jo == jo.roundToDouble()) {
        return '₩${jo.toStringAsFixed(0)}조';
      }
      return '₩${jo.toStringAsFixed(1)}조';
    }

    if (absValue >= 100000000) {
      final double eok = roundedValue / 100000000;
      if (eok == eok.roundToDouble()) {
        return '₩${eok.toStringAsFixed(0)}억';
      }
      return '₩${eok.toStringAsFixed(1)}억';
    }

    if (absValue >= 10000) {
      final double man = roundedValue / 10000;
      if (man == man.roundToDouble()) {
        return '₩${man.toStringAsFixed(0)}만';
      }
      return '₩${man.toStringAsFixed(1)}만';
    }

    return '₩$roundedValue';
  }
}
