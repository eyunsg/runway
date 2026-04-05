class SimulationInputInput {
  final GoalInput goal;
  final List<AssetInput> assets;

  SimulationInputInput({required this.goal, required this.assets});
}

class GoalInput {
  final int investmentPeriodMonths;
  final num targetPortfolioValue;
  final num targetMonthlyDividend;

  GoalInput({
    required this.investmentPeriodMonths,
    required this.targetPortfolioValue,
    required this.targetMonthlyDividend,
  });
}

class AssetInput {
  final String assetName;
  final String assetType;
  final num initialPrice;
  final num expectedAnnualPriceGrowthRate;
  final num initialInvestmentAmount;
  final num monthlyContributionAmount;
  final bool isDividendAsset;

  final num? dividendPerShare;
  final num? expectedAnnualDividendGrowthRate;
  final String? dividendFrequency;
  final bool? isReinvestDividends;

  AssetInput({
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
}
