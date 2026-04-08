import 'package:runway/domain/entity/portfolio_detail.dart';

class PortfolioDetailResponseDto {
  final String name;
  final int investmentPeriodMonths;
  final int targetPortfolioValue;
  final int targetMonthlyDividend;
  final List<AssetDto> assets;
  final PercentilesDto percentiles;
  final GoalTargetDto portfolioValueGoal;
  final GoalTargetDto monthlyDividendGoal;

  PortfolioDetailResponseDto({
    required this.name,
    required this.investmentPeriodMonths,
    required this.targetPortfolioValue,
    required this.targetMonthlyDividend,
    required this.assets,
    required this.percentiles,
    required this.portfolioValueGoal,
    required this.monthlyDividendGoal,
  });

  factory PortfolioDetailResponseDto.fromJson(Map<String, dynamic> json) {
    final simulationInput = json['simulationInput'] as Map<String, dynamic>;
    final goal = simulationInput['goal'] as Map<String, dynamic>;
    final assetsJson = simulationInput['assets'] as List<dynamic>;

    final simulationResult = json['simulationResult'] as Map<String, dynamic>;
    final percentilesJson =
        simulationResult['percentiles'] as Map<String, dynamic>;
    final goalAnalysisJson =
        simulationResult['goalAnalysis'] as Map<String, dynamic>;

    return PortfolioDetailResponseDto(
      name: json['name'] as String,
      investmentPeriodMonths: goal['investmentPeriodMonths'] as int,
      targetPortfolioValue: goal['targetPortfolioValue'] as int,
      targetMonthlyDividend: goal['targetMonthlyDividend'] as int,
      assets: assetsJson
          .map((e) => AssetDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      percentiles: PercentilesDto.fromJson(percentilesJson),
      portfolioValueGoal: GoalTargetDto.fromJson(
        goalAnalysisJson['portfolioValueGoal'],
      ),
      monthlyDividendGoal: GoalTargetDto.fromJson(
        goalAnalysisJson['monthlyDividendGoal'],
      ),
    );
  }
}

class AssetDto {
  final String assetName;
  final String assetType;
  final double initialPrice;
  final double expectedAnnualPriceGrowthRate;
  final int initialInvestmentAmount;
  final int monthlyContributionAmount;
  final bool isDividendAsset;
  final double? dividendPerShare;
  final double? expectedAnnualDividendGrowthRate;
  final int? dividendFrequency;
  final bool? isReinvestDividends;

  AssetDto({
    required this.assetName,
    required this.assetType,
    required this.initialPrice,
    required this.expectedAnnualPriceGrowthRate,
    required this.initialInvestmentAmount,
    required this.monthlyContributionAmount,
    required this.isDividendAsset,
    this.dividendPerShare,
    this.expectedAnnualDividendGrowthRate,
    this.dividendFrequency,
    this.isReinvestDividends,
  });

  factory AssetDto.fromJson(Map<String, dynamic> json) {
    return AssetDto(
      assetName: json['assetName'] as String,
      assetType: json['assetType'] as String,
      initialPrice: (json['initialPrice'] as num).toDouble(),
      expectedAnnualPriceGrowthRate:
          (json['expectedAnnualPriceGrowthRate'] as num).toDouble(),
      initialInvestmentAmount: json['initialInvestmentAmount'] as int,
      monthlyContributionAmount: json['monthlyContributionAmount'] as int,
      isDividendAsset: json['isDividendAsset'] as bool,
      dividendPerShare: json['dividendPerShare'] != null
          ? (json['dividendPerShare'] as num).toDouble()
          : null,
      expectedAnnualDividendGrowthRate:
          json['expectedAnnualDividendGrowthRate'] != null
          ? (json['expectedAnnualDividendGrowthRate'] as num).toDouble()
          : null,
      dividendFrequency: json['dividendFrequency'] as int?,
      isReinvestDividends: json['isReinvestDividends'] as bool?,
    );
  }
}

class PercentilesDto {
  final PercentileDto portfolioValue;
  final PercentileDto monthlyDividend;

  PercentilesDto({required this.portfolioValue, required this.monthlyDividend});

  factory PercentilesDto.fromJson(Map<String, dynamic> json) {
    return PercentilesDto(
      portfolioValue: PercentileDto.fromJson(json['portfolioValue']),
      monthlyDividend: PercentileDto.fromJson(json['monthlyDividend']),
    );
  }
}

class PercentileDto {
  final double p10;
  final double p50;
  final double p90;

  PercentileDto({required this.p10, required this.p50, required this.p90});

  factory PercentileDto.fromJson(Map<String, dynamic> json) {
    return PercentileDto(
      p10: (json['p10'] as num).toDouble(),
      p50: (json['p50'] as num).toDouble(),
      p90: (json['p90'] as num).toDouble(),
    );
  }
}

class GoalTargetDto {
  final double target;
  final double achievementProbability;
  final double expectedMonthsToTarget;

  GoalTargetDto({
    required this.target,
    required this.achievementProbability,
    required this.expectedMonthsToTarget,
  });

  factory GoalTargetDto.fromJson(Map<String, dynamic> json) {
    return GoalTargetDto(
      target: (json['target'] as num).toDouble(),
      achievementProbability: (json['achievementProbability'] as num)
          .toDouble(),
      expectedMonthsToTarget: (json['expectedMonthsToTarget'] as num)
          .toDouble(),
    );
  }
}

extension PortfolioDetailMapper on PortfolioDetailResponseDto {
  PortfolioDetail toModel() {
    return PortfolioDetail(
      name: name,
      simulationInput: SimulationInput(
        goal: Goal(
          investmentPeriodMonths: investmentPeriodMonths,
          targetPortfolioValue: targetPortfolioValue,
          targetMonthlyDividend: targetMonthlyDividend,
        ),
        assets: assets
            .map(
              (e) => Asset(
                name: e.assetName,
                type: e.assetType,
                initialPrice: e.initialPrice,
                expectedAnnualPriceGrowthRate: e.expectedAnnualPriceGrowthRate,
                initialInvestmentAmount: e.initialInvestmentAmount,
                monthlyContributionAmount: e.monthlyContributionAmount,
                isDividendAsset: e.isDividendAsset,
                dividendPerShare: e.dividendPerShare,
                expectedAnnualDividendGrowthRate:
                    e.expectedAnnualDividendGrowthRate,
                dividendFrequency: e.dividendFrequency,
                isReinvestDividends: e.isReinvestDividends,
              ),
            )
            .toList(),
      ),
      simulationResult: SimulationResult(
        percentiles: Percentiles(
          portfolioValue: Percentile(
            p10: percentiles.portfolioValue.p10,
            p50: percentiles.portfolioValue.p50,
            p90: percentiles.portfolioValue.p90,
          ),
          monthlyDividend: Percentile(
            p10: percentiles.monthlyDividend.p10,
            p50: percentiles.monthlyDividend.p50,
            p90: percentiles.monthlyDividend.p90,
          ),
        ),
        goalAnalysis: GoalAnalysis(
          portfolioValueGoal: GoalTarget(
            target: portfolioValueGoal.target,
            achievementProbability: portfolioValueGoal.achievementProbability,
            expectedMonthsToTarget: portfolioValueGoal.expectedMonthsToTarget,
          ),
          monthlyDividendGoal: GoalTarget(
            target: monthlyDividendGoal.target,
            achievementProbability: monthlyDividendGoal.achievementProbability,
            expectedMonthsToTarget: monthlyDividendGoal.expectedMonthsToTarget,
          ),
        ),
      ),
    );
  }
}
