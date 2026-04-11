import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:runway/core/providers.dart';
import 'package:go_router/go_router.dart';

import 'package:runway/features/portfolio/model/create_portfolio_input.dart';

class CreatePortfolioTempScreen extends ConsumerStatefulWidget {
  final CreatePortfolioInput createPortfolioInput;

  const CreatePortfolioTempScreen({
    super.key,
    required this.createPortfolioInput,
  });

  @override
  ConsumerState<CreatePortfolioTempScreen> createState() =>
      _CreatePortfolioTempScreenState();
}

class _CreatePortfolioTempScreenState
    extends ConsumerState<CreatePortfolioTempScreen> {
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
      appBar: AppBar(
        title: const Text(''),
        actions: [
          TextButton(
            onPressed: portfolioState.isLoading
                ? null
                : () async {
                    await ref
                        .read(createPortfolioControllerProvider.notifier)
                        .createPortfolio(widget.createPortfolioInput);
                  },

            child: Text(portfolioState.isLoading ? '추가 중...' : '추가하기'),
          ),
        ],
      ),
      body: SafeArea(
        child: portfolioState.isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _ResultSummaryCard(
                      investmentPeriodYears: investmentPeriodYears,
                      portfolioValueText: portfolioValueMedianText,
                      monthlyDividendText: monthlyDividendMedianText,
                    ),
                    SizedBox(height: 16),

                    _GoalAnalysisCard(
                      portfolioGoalSummaryText: portfolioGoalSummaryText,
                      portfolioGoalMonthsText: portfolioGoalMonthsText,
                      monthlyDividendGoalSummaryText:
                          monthlyDividendGoalSummaryText,
                      monthlyDividendGoalMonthsText:
                          monthlyDividendGoalMonthsText,
                    ),
                    SizedBox(height: 24),

                    _CenteredSectionTitle(title: '평가금액'),
                    SizedBox(height: 8),

                    _PercentileSliderCard(
                      description: '80% 확률로 이 범위 안의 평가금액 달성됩니다.',
                      leftLabel: _formatKrwAmount(
                        portfolioValuePercentiles.p10,
                      ),
                      centerLabel: _formatKrwAmount(
                        portfolioValuePercentiles.p50,
                      ),
                      rightLabel: _formatKrwAmount(
                        portfolioValuePercentiles.p90,
                      ),
                    ),
                    SizedBox(height: 24),

                    _CenteredSectionTitle(title: '배당금액'),
                    SizedBox(height: 8),

                    _PercentileSliderCard(
                      description: '80% 확률로 이 범위 안의 배당금액 달성됩니다.',
                      leftLabel: _formatKrwAmount(
                        monthlyDividendPercentiles.p10,
                      ),
                      centerLabel: _formatKrwAmount(
                        monthlyDividendPercentiles.p50,
                      ),
                      rightLabel: _formatKrwAmount(
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

  // 원화 포맷
  String _formatKrwAmount(num value) {
    final roundedValue = value.round();

    if (roundedValue.abs() >= 100000000) {
      final eok = roundedValue / 100000000;
      if (eok == eok.roundToDouble()) {
        return '₩${eok.toStringAsFixed(0)}억';
      }
      return '₩${eok.toStringAsFixed(1)}억';
    }

    if (roundedValue.abs() >= 10000) {
      final man = roundedValue / 10000;
      if (man == man.roundToDouble()) {
        return '₩${man.toStringAsFixed(0)}만';
      }
      return '₩${man.toStringAsFixed(1)}만';
    }

    return '₩${roundedValue.toString()}';
  }
}

class _ResultSummaryCard extends StatelessWidget {
  final int investmentPeriodYears;
  final String portfolioValueText;
  final String monthlyDividendText;

  const _ResultSummaryCard({
    required this.investmentPeriodYears,
    required this.portfolioValueText,
    required this.monthlyDividendText,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          children: [
            Text('$investmentPeriodYears년 후 예상 결과'),
            const SizedBox(height: 8),
            Text(
              portfolioValueText,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('월 배당금: $monthlyDividendText'),
            const SizedBox(height: 4),
            const Text('[중위값 기준]'),
          ],
        ),
      ),
    );
  }
}

class _GoalAnalysisCard extends StatelessWidget {
  final String portfolioGoalSummaryText;
  final String portfolioGoalMonthsText;
  final String monthlyDividendGoalSummaryText;
  final String monthlyDividendGoalMonthsText;

  const _GoalAnalysisCard({
    required this.portfolioGoalSummaryText,
    required this.portfolioGoalMonthsText,
    required this.monthlyDividendGoalSummaryText,
    required this.monthlyDividendGoalMonthsText,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          children: [
            const Text('목표 분석', textAlign: TextAlign.center),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _GoalSummaryItem(
                    topText: portfolioGoalSummaryText,
                    bottomText: portfolioGoalMonthsText,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _GoalSummaryItem(
                    topText: monthlyDividendGoalSummaryText,
                    bottomText: monthlyDividendGoalMonthsText,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _GoalSummaryItem extends StatelessWidget {
  const _GoalSummaryItem({required this.topText, required this.bottomText});

  final String topText;
  final String bottomText;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(topText, textAlign: TextAlign.center),
        SizedBox(height: 8),
        Text(
          bottomText,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class _CenteredSectionTitle extends StatelessWidget {
  const _CenteredSectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }
}

class _PercentileSliderCard extends StatelessWidget {
  final String description;
  final String leftLabel;
  final String centerLabel;
  final String rightLabel;

  const _PercentileSliderCard({
    required this.description,
    required this.leftLabel,
    required this.centerLabel,
    required this.rightLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          description,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12),
        ),
        const SizedBox(height: 12),

        Slider(value: 1, min: 0, max: 2, divisions: 2, onChanged: null),

        const SizedBox(height: 8),

        Row(
          children: [
            Expanded(
              child: _BottomValueBox(
                label: leftLabel,
                textAlign: TextAlign.left,
              ),
            ),
            Expanded(
              child: _BottomValueBox(
                label: centerLabel,
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: _BottomValueBox(
                label: rightLabel,
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _BottomValueBox extends StatelessWidget {
  const _BottomValueBox({
    required this.label,
    this.textAlign = TextAlign.center,
  });

  final String label;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Text(label, textAlign: textAlign, overflow: TextOverflow.ellipsis),
    );
  }
}
