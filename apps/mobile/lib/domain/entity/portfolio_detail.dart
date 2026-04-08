class PortfolioDetail {
  final String name;
  final SimulationInput simulationInput;
  final SimulationResult simulationResult;

  PortfolioDetail({
    required this.name,
    required this.simulationInput,
    required this.simulationResult,
  });
}

class SimulationInput {
  final Goal goal;
  final List<Asset> assets;

  SimulationInput({required this.goal, required this.assets});
}

class Goal {
  final int investmentPeriodMonths;
  final int targetPortfolioValue;
  final int targetMonthlyDividend;

  Goal({
    required this.investmentPeriodMonths,
    required this.targetPortfolioValue,
    required this.targetMonthlyDividend,
  });
}

class Asset {
  final String name;
  final String type;
  final double initialPrice;
  final double expectedAnnualPriceGrowthRate;
  final int initialInvestmentAmount;
  final int monthlyContributionAmount;
  final bool isDividendAsset;
  final double? dividendPerShare;
  final double? expectedAnnualDividendGrowthRate;
  final int? dividendFrequency;
  final bool? isReinvestDividends;

  Asset({
    required this.name,
    required this.type,
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
  final Percentiles percentiles;
  final GoalAnalysis goalAnalysis;

  SimulationResult({required this.percentiles, required this.goalAnalysis});
}

class Percentiles {
  final Percentile portfolioValue;
  final Percentile monthlyDividend;

  Percentiles({required this.portfolioValue, required this.monthlyDividend});
}

class Percentile {
  final double p10;
  final double p50;
  final double p90;

  Percentile({required this.p10, required this.p50, required this.p90});
}

class GoalAnalysis {
  final GoalTarget portfolioValueGoal;
  final GoalTarget monthlyDividendGoal;

  GoalAnalysis({
    required this.portfolioValueGoal,
    required this.monthlyDividendGoal,
  });
}

class GoalTarget {
  final double target;
  final double achievementProbability;
  final double expectedMonthsToTarget;

  GoalTarget({
    required this.target,
    required this.achievementProbability,
    required this.expectedMonthsToTarget,
  });
}
