// 자산 입력 DTO
class AssetInputDto {
  final String assetName;
  final String assetType;
  final double initialPrice;
  final double expectedAnnualPriceGrowthRate;
  final double initialInvestmentAmount;
  final double monthlyContributionAmount;
  final bool isDividendAsset;
  final double dividendPerShare;
  final double expectedAnnualDividendGrowthRate;
  final int dividendFrequency;
  final bool isReinvestDividends;

  AssetInputDto({
    required this.assetName,
    required this.assetType,
    required this.initialPrice,
    required this.expectedAnnualPriceGrowthRate,
    required this.initialInvestmentAmount,
    required this.monthlyContributionAmount,
    required this.isDividendAsset,
    required this.dividendPerShare,
    required this.expectedAnnualDividendGrowthRate,
    required this.dividendFrequency,
    required this.isReinvestDividends,
  });

  Map<String, dynamic> toJson() => {
    'assetName': assetName,
    'assetType': assetType,
    'initialPrice': initialPrice,
    'expectedAnnualPriceGrowthRate': expectedAnnualPriceGrowthRate,
    'initialInvestmentAmount': initialInvestmentAmount,
    'monthlyContributionAmount': monthlyContributionAmount,
    'isDividendAsset': isDividendAsset,
    'dividendPerShare': dividendPerShare,
    'expectedAnnualDividendGrowthRate': expectedAnnualDividendGrowthRate,
    'dividendFrequency': dividendFrequency,
    'isReinvestDividends': isReinvestDividends,
  };
}

// 목표 정보 DTO
class SimulationGoalDto {
  final int investmentPeriodMonths;
  final double targetPortfolioValue;
  final double targetMonthlyDividend;

  SimulationGoalDto({
    required this.investmentPeriodMonths,
    required this.targetPortfolioValue,
    required this.targetMonthlyDividend,
  });

  Map<String, dynamic> toJson() => {
    'investmentPeriodMonths': investmentPeriodMonths,
    'targetPortfolioValue': targetPortfolioValue,
    'targetMonthlyDividend': targetMonthlyDividend,
  };
}

// 시뮬레이션 Request DTO
class GoalAnalysisSimulationRequestDto {
  final SimulationGoalDto goal;
  final List<AssetInputDto> assets;

  GoalAnalysisSimulationRequestDto({required this.goal, required this.assets});

  Map<String, dynamic> toJson() => {
    'goal': goal.toJson(),
    'assets': assets.map((e) => e.toJson()).toList(),
  };
}
