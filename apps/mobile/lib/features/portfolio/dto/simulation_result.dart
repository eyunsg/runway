class SimulationResult {
  final Percentiles percentiles;
  final GoalAnalysis goalAnalysis;

  SimulationResult({required this.percentiles, required this.goalAnalysis});

  Map<String, dynamic> toJson() => {
    'percentiles': percentiles.toJson(),
    'goalAnalysis': goalAnalysis.toJson(),
  };
}

class Percentiles {
  final PortfolioValue portfolioValue;
  final MonthlyDividend monthlyDividend;

  Percentiles({required this.portfolioValue, required this.monthlyDividend});

  Map<String, dynamic> toJson() => {
    'portfolioValue': portfolioValue.toJson(),
    'monthlyDividend': monthlyDividend.toJson(),
  };
}

class PortfolioValue {
  final num p10;
  final num p50;
  final num p90;

  PortfolioValue({required this.p10, required this.p50, required this.p90});

  Map<String, dynamic> toJson() => {'p10': p10, 'p50': p50, 'p90': p90};
}

class MonthlyDividend {
  final num p10;
  final num p50;
  final num p90;

  MonthlyDividend({required this.p10, required this.p50, required this.p90});

  Map<String, dynamic> toJson() => {'p10': p10, 'p50': p50, 'p90': p90};
}

class GoalAnalysis {
  final PortfolioValueGoal portfolioValueGoal;
  final MonthlyDividendGoal monthlyDividendGoal;

  GoalAnalysis({
    required this.portfolioValueGoal,
    required this.monthlyDividendGoal,
  });

  Map<String, dynamic> toJson() => {
    'portfolioValueGoal': portfolioValueGoal.toJson(),
    'monthlyDividendGoal': monthlyDividendGoal.toJson(),
  };
}

class PortfolioValueGoal {
  final int expectedMonthsToTarget;

  PortfolioValueGoal({required this.expectedMonthsToTarget});

  Map<String, dynamic> toJson() => {
    'expectedMonthsToTarget': expectedMonthsToTarget,
  };
}

class MonthlyDividendGoal {
  final int expectedMonthsToTarget;

  MonthlyDividendGoal({required this.expectedMonthsToTarget});

  Map<String, dynamic> toJson() => {
    'expectedMonthsToTarget': expectedMonthsToTarget,
  };
}
