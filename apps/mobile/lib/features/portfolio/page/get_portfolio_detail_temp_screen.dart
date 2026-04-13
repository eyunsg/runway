import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:runway/core/providers.dart';
import 'package:runway/domain/entity/portfolio_detail.dart';
import 'package:go_router/go_router.dart';

class GetPortfolioDetailTempScreen extends ConsumerStatefulWidget {
  final String portfolioId;

  const GetPortfolioDetailTempScreen({super.key, required this.portfolioId});

  @override
  ConsumerState<GetPortfolioDetailTempScreen> createState() =>
      _GetPortfolioDetailTempScreenState();
}

class _GetPortfolioDetailTempScreenState
    extends ConsumerState<GetPortfolioDetailTempScreen> {
  // 포트폴리오 삭제 다이얼로그
  Future<void> _onDeletePressed() async {
    final bool shouldDelete =
        await showDialog<bool>(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              title: const Text('포트폴리오 삭제'),
              content: const Text('이 포트폴리오를 삭제하시겠습니까?'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop(false);
                  },
                  child: const Text('취소'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop(true);
                  },
                  child: const Text('삭제'),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!shouldDelete || !mounted) return;

    await ref
        .read(deleteClientControllerProvider.notifier)
        .deletePortfolio(widget.portfolioId);
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(getPortfolioDetailControllerProvider.notifier)
          .getPortfolioDetail(widget.portfolioId);
    });

    ref.listenManual(getPortfolioDetailControllerProvider, (previous, next) {
      final hasNewError = previous?.error != next.error && next.error != null;

      if (hasNewError && mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.error!)));
      }
    });

    ref.listenManual(deleteClientControllerProvider, (previous, next) {
      if (next.isSuccess && mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('삭제 완료')));

        ref.invalidate(getPortfolioControllerProvider);

        context.go('/portfolio/get');
      }

      if (next.error != null && mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.error!)));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final detailState = ref.watch(getPortfolioDetailControllerProvider);

    final bool isInitialLoading =
        detailState.isLoading && detailState.portfolioDetail == null;

    final PortfolioDetail? portfolioDetail = detailState.portfolioDetail;

    if (isInitialLoading) {
      return const Scaffold(
        body: SafeArea(child: Center(child: CircularProgressIndicator())),
      );
    }

    if (portfolioDetail == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(''),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: () {
              context.go('/portfolio/get');
            },
          ),
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.delete_outline),
            ),
          ],
        ),
        body: const SafeArea(
          child: Center(child: Text('포트폴리오 상세 정보를 불러오지 못했습니다.')),
        ),
      );
    }

    final simulationInput = portfolioDetail.simulationInput;
    final simulationResult = portfolioDetail.simulationResult;

    final int investmentPeriodYears =
        (simulationInput.goal.investmentPeriodMonths / 12).floor();

    final portfolioValuePercentiles =
        simulationResult.percentiles.portfolioValue;
    final monthlyDividendPercentiles =
        simulationResult.percentiles.monthlyDividend;

    final double? portfolioValueGoalMonths =
        simulationResult.goalAnalysis.portfolioValueGoal.expectedMonthsToTarget;

    final double? monthlyDividendGoalMonths = simulationResult
        .goalAnalysis
        .monthlyDividendGoal
        .expectedMonthsToTarget;

    final String portfolioValueMedianText = _formatKrwAmount(
      portfolioValuePercentiles.p50,
    );

    final String monthlyDividendMedianText = _formatKrwAmount(
      monthlyDividendPercentiles.p50,
    );

    final String portfolioGoalSummaryText =
        '자산 ${_formatKrwAmount(simulationInput.goal.targetPortfolioValue)}까지';

    final String monthlyDividendGoalSummaryText =
        '배당 ${_formatKrwAmount(simulationInput.goal.targetMonthlyDividend)}까지';

    final String portfolioGoalMonthsText = _formatExpectedMonthsToTarget(
      portfolioValueGoalMonths,
    );

    final String monthlyDividendGoalMonthsText = _formatExpectedMonthsToTarget(
      monthlyDividendGoalMonths,
    );

    final List<Asset> assets = simulationInput.assets;

    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            context.go('/portfolio/get');
          },
        ),
        actions: [
          IconButton(
            onPressed: _onDeletePressed,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ResultSummaryCard(
                investmentPeriodYears: investmentPeriodYears,
                portfolioValueText: portfolioValueMedianText,
                monthlyDividendText: monthlyDividendMedianText,
              ),
              const SizedBox(height: 16),

              _GoalAnalysisCard(
                portfolioGoalSummaryText: portfolioGoalSummaryText,
                portfolioGoalMonthsText: portfolioGoalMonthsText,
                monthlyDividendGoalSummaryText: monthlyDividendGoalSummaryText,
                monthlyDividendGoalMonthsText: monthlyDividendGoalMonthsText,
              ),
              const SizedBox(height: 24),

              const _CenteredSectionTitle(title: '평가금액'),
              const SizedBox(height: 8),

              _PercentileSliderCard(
                description: '80% 확률로 이 범위 안에 결과가 형성됩니다.',
                leftLabel: _formatKrwAmount(portfolioValuePercentiles.p10),
                centerLabel: _formatKrwAmount(portfolioValuePercentiles.p50),
                rightLabel: _formatKrwAmount(portfolioValuePercentiles.p90),
              ),
              const SizedBox(height: 24),

              const Divider(),
              const SizedBox(height: 16),

              const _CenteredSectionTitle(title: '배당금액'),
              const SizedBox(height: 8),

              _PercentileSliderCard(
                description: '80% 확률로 이 범위 안에 결과가 형성됩니다.',
                leftLabel: _formatKrwAmount(monthlyDividendPercentiles.p10),
                centerLabel: _formatKrwAmount(monthlyDividendPercentiles.p50),
                rightLabel: _formatKrwAmount(monthlyDividendPercentiles.p90),
              ),
              const SizedBox(height: 24),

              ...assets.asMap().entries.map((entry) {
                final int index = entry.key;
                final Asset asset = entry.value;

                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index == assets.length - 1 ? 24 : 12,
                  ),
                  child: _AssetExpansionCard(
                    title: asset.name.isEmpty ? '자산명 ${index + 1}' : asset.name,
                    asset: asset,
                  ),
                );
              }),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: update portfolio 화면 연결 시 수정
                  },
                  child: const Text('자산 수정하기'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatExpectedMonthsToTarget(double? months) {
    if (months == null) {
      return '목표 도달 불가';
    }

    final int roundedMonths = months.round();

    if (roundedMonths < 12) {
      return '$roundedMonths개월';
    }

    final int years = roundedMonths ~/ 12;
    final int remainingMonths = roundedMonths % 12;

    if (remainingMonths == 0) {
      return '$years년';
    }

    return '$years년 $remainingMonths개월';
  }

  String _formatKrwAmount(num value) {
    final int roundedValue = value.round();

    if (roundedValue.abs() >= 100000000) {
      final double eok = roundedValue / 100000000;
      if (eok == eok.roundToDouble()) {
        return '₩${eok.toStringAsFixed(0)}억';
      }
      return '₩${eok.toStringAsFixed(1)}억';
    }

    if (roundedValue.abs() >= 10000) {
      final double man = roundedValue / 10000;
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
            const Text('(중위값 기준)'),
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
        const SizedBox(height: 8),
        Text(
          bottomText,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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

class _AssetExpansionCard extends StatelessWidget {
  final String title;
  final Asset asset;

  const _AssetExpansionCard({required this.title, required this.asset});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        title: Text(title),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          _AssetDetailRow(label: '자산 유형', value: asset.type),
          _AssetDetailRow(
            label: '초기 가격',
            value: _formatAssetAmount(asset.initialPrice),
          ),
          _AssetDetailRow(
            label: '연간 가격 상승률',
            value: '${asset.expectedAnnualPriceGrowthRate}%',
          ),
          _AssetDetailRow(
            label: '초기 투자 금액',
            value: _formatAssetAmount(asset.initialInvestmentAmount),
          ),
          _AssetDetailRow(
            label: '월 적립 금액',
            value: _formatAssetAmount(asset.monthlyContributionAmount),
          ),
          _AssetDetailRow(
            label: '배당 자산 여부',
            value: asset.isDividendAsset ? '예' : '아니오',
          ),
          if (asset.dividendPerShare != null)
            _AssetDetailRow(
              label: '주당 배당금',
              value: _formatAssetAmount(asset.dividendPerShare!),
            ),
          if (asset.expectedAnnualDividendGrowthRate != null)
            _AssetDetailRow(
              label: '연간 배당 성장률',
              value: '${asset.expectedAnnualDividendGrowthRate}%',
            ),
          if (asset.dividendFrequency != null)
            _AssetDetailRow(
              label: '배당 빈도',
              value: '${asset.dividendFrequency}회',
            ),
          if (asset.isReinvestDividends != null)
            _AssetDetailRow(
              label: '배당 재투자 여부',
              value: asset.isReinvestDividends! ? '예' : '아니오',
            ),
        ],
      ),
    );
  }

  String _formatAssetAmount(num value) {
    final int roundedValue = value.round();
    return '₩$roundedValue';
  }
}

class _AssetDetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _AssetDetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text(label)),
          const SizedBox(width: 12),
          Expanded(child: Text(value, textAlign: TextAlign.right)),
        ],
      ),
    );
  }
}
