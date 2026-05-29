import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:runway/core/providers.dart';
import 'package:runway/domain/entity/portfolio_detail.dart';
import 'package:go_router/go_router.dart';
import 'package:runway/core/theme/app_colors.dart';
import 'package:runway/core/theme/app_typography.dart';
import 'package:runway/shared/widgets/result_card.dart';
import 'package:runway/shared/widgets/percentile_result.dart';
import 'package:runway/shared/widgets/button.dart';
import 'package:runway/shared/widgets/dialog.dart';

class GetPortfolioDetailScreen extends ConsumerStatefulWidget {
  final String? portfolioId;
  final String? portfolioSnapshotId;

  const GetPortfolioDetailScreen({super.key, required String portfolioId})
    : portfolioId = portfolioId,
      portfolioSnapshotId = null,
      assert(portfolioId != '');

  const GetPortfolioDetailScreen.snapshot({
    super.key,
    required String portfolioSnapshotId,
  }) : portfolioSnapshotId = portfolioSnapshotId,
       portfolioId = null,
       assert(portfolioSnapshotId != '');

  @override
  ConsumerState<GetPortfolioDetailScreen> createState() =>
      _GetPortfolioDetailScreenState();
}

class _GetPortfolioDetailScreenState
    extends ConsumerState<GetPortfolioDetailScreen> {
  final Set<int> _expandedAssetIndexes = <int>{};

  String _providerKey() {
    final snapshotId = (widget.portfolioSnapshotId ?? '').trim();

    if (snapshotId.isNotEmpty) {
      return 'snapshot:$snapshotId';
    }

    return 'portfolio:${widget.portfolioId!}';
  }

  // 포트폴리오 삭제 다이얼로그
  Future<void> _onDeletePressed() async {
    final String? portfolioId = widget.portfolioId;
    if (portfolioId == null || portfolioId.trim().isEmpty) return;

    final bool shouldDelete =
        await showDialog<bool>(
          context: context,
          barrierColor: Colors.black.withValues(alpha: 0.4),
          builder: (dialogContext) {
            return Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              insetPadding: const EdgeInsets.symmetric(horizontal: 30),
              child: AppDialog(
                title: '포트폴리오 삭제',
                description: '이 포트폴리오를 삭제하시겠습니까?',
                secondaryButtonText: '취소',
                primaryButtonText: '삭제',
                onSecondaryPressed: () {
                  Navigator.of(dialogContext).pop(false);
                },
                onPrimaryPressed: () {
                  Navigator.of(dialogContext).pop(true);
                },
              ),
            );
          },
        ) ??
        false;

    if (!shouldDelete || !mounted) return;

    await ref
        .read(deleteClientControllerProvider.notifier)
        .deletePortfolio(portfolioId);
  }

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      if (!mounted) return;

      final controller = ref.read(
        getPortfolioDetailControllerProvider(_providerKey()).notifier,
      );
      final String snapshotId = (widget.portfolioSnapshotId ?? '').trim();

      if (snapshotId.isNotEmpty) {
        controller.getPortfolioSnapshotDetail(snapshotId);
      } else {
        controller.getPortfolioDetail(widget.portfolioId!);
      }
    });

    ref.listenManual(getPortfolioDetailControllerProvider(_providerKey()), (
      previous,
      next,
    ) {
      final hasNewError = previous?.error != next.error && next.error != null;

      if (hasNewError && mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.error!)));
      }
    });

    ref.listenManual(deleteClientControllerProvider, (previous, next) {
      if (widget.portfolioId == null) return;

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
    final detailState = ref.watch(
      getPortfolioDetailControllerProvider(_providerKey()),
    );
    final bool isSnapshotDetail = widget.portfolioId == null;
    final bool canDelete = widget.portfolioId != null && !isSnapshotDetail;
    final bool canEditAssets = !isSnapshotDetail;

    final bool isInitialLoading =
        detailState.isLoading && detailState.portfolioDetail == null;

    final PortfolioDetail? portfolioDetail = detailState.portfolioDetail;

    if (isInitialLoading) {
      return Scaffold(
        backgroundColor: AppColors.natural.backgroundColors.primary,
        body: SafeArea(
          child: Center(
            child: CircularProgressIndicator(color: AppColors.highlight.light),
          ),
        ),
      );
    }

    if (portfolioDetail == null) {
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
            if (canDelete)
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: GestureDetector(
                  onTap: _onDeletePressed,
                  child: Center(
                    child: Image.asset(
                      'icons/Trash.png',
                      width: 20,
                      height: 20,
                      color: AppColors.error,
                    ),
                  ),
                ),
              ),
          ],
        ),
        body: SafeArea(
          child: Center(
            child: Text(
              '포트폴리오 상세 정보를 불러오지 못했습니다.',
              style: AppTypography.body.m.copyWith(
                color: AppColors.natural.textColors.primary,
              ),
            ),
          ),
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
          if (canDelete)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: GestureDetector(
                onTap: _onDeletePressed,
                child: Center(
                  child: Image.asset(
                    'icons/Trash.png',
                    width: 20,
                    height: 20,
                    color: AppColors.error,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
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
                leftValue: _formatKrwAmount(portfolioValuePercentiles.p10),
                centerValue: _formatKrwAmount(portfolioValuePercentiles.p50),
                rightValue: _formatKrwAmount(portfolioValuePercentiles.p90),
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
                leftValue: _formatKrwAmount(monthlyDividendPercentiles.p10),
                centerValue: _formatKrwAmount(monthlyDividendPercentiles.p50),
                rightValue: _formatKrwAmount(monthlyDividendPercentiles.p90),
              ),
              const SizedBox(height: 24),

              ...assets.asMap().entries.map((entry) {
                final int index = entry.key;
                final Asset asset = entry.value;

                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index == assets.length - 1 ? 0 : 8,
                  ),
                  child: _PortfolioAssetCard(
                    title: asset.name.isEmpty ? '자산명 ${index + 1}' : asset.name,
                    detailLines: _buildAssetDetailLines(asset),
                    isExpanded: _expandedAssetIndexes.contains(index),
                    onTap: () {
                      setState(() {
                        if (_expandedAssetIndexes.contains(index)) {
                          _expandedAssetIndexes.remove(index);
                        } else {
                          _expandedAssetIndexes.add(index);
                        }
                      });
                    },
                  ),
                );
              }),

              if (canEditAssets) ...[
                const SizedBox(height: 24),
                AppButton(
                  text: '자산 수정하기',
                  variant: ButtonVariant.primary,
                  onPressed: () {
                    // TODO: update portfolio 화면 연결 시 수정
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  List<String> _buildAssetDetailLines(Asset asset) {
    final List<String> lines = [
      '자산 유형 ${asset.type}',
      '초기 가격 ${_formatAssetAmount(asset.initialPrice)}',
      '연간 가격 상승률 ${asset.expectedAnnualPriceGrowthRate}%',
      '초기 투자 금액 ${_formatAssetAmount(asset.initialInvestmentAmount)}',
      '월 적립 금액 ${_formatAssetAmount(asset.monthlyContributionAmount)}',
      '배당 자산 여부 ${asset.isDividendAsset ? '예' : '아니오'}',
    ];

    if (asset.dividendPerShare != null) {
      lines.add('주당 배당금 ${_formatAssetAmount(asset.dividendPerShare!)}');
    }
    if (asset.expectedAnnualDividendGrowthRate != null) {
      lines.add('연간 배당 성장률 ${asset.expectedAnnualDividendGrowthRate}%');
    }
    if (asset.dividendFrequency != null) {
      lines.add('배당 빈도 ${asset.dividendFrequency}회');
    }
    if (asset.isReinvestDividends != null) {
      lines.add('배당 재투자 여부 ${asset.isReinvestDividends! ? '예' : '아니오'}');
    }

    return lines;
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

  String _formatAssetAmount(num value) {
    final int roundedValue = value.round();
    return '₩$roundedValue';
  }
}

class _PortfolioAssetCard extends StatelessWidget {
  final String title;
  final List<String> detailLines;
  final bool isExpanded;
  final VoidCallback onTap;

  const _PortfolioAssetCard({
    required this.title,
    required this.detailLines,
    required this.isExpanded,
    required this.onTap,
  });

  static const double _radius = 16;
  static const double _horizontalPadding = 16;
  static const double _verticalPadding = 16;
  static const double _titleDetailGap = 12;
  static const double _iconSize = 12;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(_radius),
        splashColor: AppColors.natural.textColors.primary.withValues(
          alpha: 0.05,
        ),
        highlightColor: Colors.transparent,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: _horizontalPadding,
            vertical: _verticalPadding,
          ),
          decoration: BoxDecoration(
            color: AppColors.highlight.dark,
            borderRadius: BorderRadius.circular(_radius),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.body.m.copyWith(
                        color: AppColors.natural.textColors.primary,
                      ),
                    ),
                    if (isExpanded) ...[
                      const SizedBox(height: _titleDetailGap),
                      ...detailLines.asMap().entries.map((entry) {
                        final int index = entry.key;
                        final String line = entry.value;

                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: index == detailLines.length - 1 ? 0 : 4,
                          ),
                          child: Text(
                            line,
                            style: AppTypography.body.s.copyWith(
                              color: AppColors.natural.textColors.secondary,
                            ),
                          ),
                        );
                      }),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Image.asset(
                  isExpanded ? 'icons/arrow_up.png' : 'icons/arrow_down.png',
                  width: _iconSize,
                  height: _iconSize,
                  color: AppColors.natural.textColors.secondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
