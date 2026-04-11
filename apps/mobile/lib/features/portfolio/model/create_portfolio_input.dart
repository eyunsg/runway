class CreatePortfolioInput {
  final String name;

  final SimulationInput simulationInput;
  final SimulationResult simulationResult;

  CreatePortfolioInput({
    required this.name,
    required this.simulationInput,
    required this.simulationResult,
  });
}

class SimulationInput {
  final GoalInput goal;
  final List<AssetInput> assets;

  SimulationInput({required this.goal, required this.assets});
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
  final int? dividendFrequency;
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

class SimulationResult {
  final PercentilesInput percentiles;
  final GoalAnalysisInput goalAnalysis;

  SimulationResult({required this.percentiles, required this.goalAnalysis});
}

class PercentilesInput {
  final PortfolioValueInput portfolioValue;
  final MonthlyDividendInput monthlyDividend;

  PercentilesInput({
    required this.portfolioValue,
    required this.monthlyDividend,
  });
}

class PortfolioValueInput {
  final num p10;
  final num p50;
  final num p90;

  PortfolioValueInput({
    required this.p10,
    required this.p50,
    required this.p90,
  });
}

class MonthlyDividendInput {
  final num p10;
  final num p50;
  final num p90;

  MonthlyDividendInput({
    required this.p10,
    required this.p50,
    required this.p90,
  });
}

class GoalAnalysisInput {
  final PortfolioValueGoalInput portfolioValueGoal;
  final MonthlyDividendGoalInput monthlyDividendGoal;

  GoalAnalysisInput({
    required this.portfolioValueGoal,
    required this.monthlyDividendGoal,
  });
}

class PortfolioValueGoalInput {
  final int expectedMonthsToTarget;

  PortfolioValueGoalInput({required this.expectedMonthsToTarget});
}

class MonthlyDividendGoalInput {
  final int expectedMonthsToTarget;

  MonthlyDividendGoalInput({required this.expectedMonthsToTarget});
}
