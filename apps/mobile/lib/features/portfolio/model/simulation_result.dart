class SimulationResultInput {
  final PercentilesInput percentiles;
  final GoalAnalysisInput goalAnalysis;

  SimulationResultInput({
    required this.percentiles,
    required this.goalAnalysis,
  });
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
