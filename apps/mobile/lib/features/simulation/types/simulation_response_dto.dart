class SimulationResponseDto {
  final SimulationPercentilesDto percentiles;
  final SimulationGoalAnalysisDto goalAnalysis;

  SimulationResponseDto({
    required this.percentiles,
    required this.goalAnalysis,
  });

  factory SimulationResponseDto.fromJson(Map<String, dynamic> json) {
    return SimulationResponseDto(
      percentiles: SimulationPercentilesDto.fromJson(
        json['percentiles'] as Map<String, dynamic>,
      ),
      goalAnalysis: SimulationGoalAnalysisDto.fromJson(
        json['goalAnalysis'] as Map<String, dynamic>,
      ),
    );
  }
}

class SimulationPercentilesDto {
  final SimulationPercentileValueDto portfolioValue;
  final SimulationPercentileValueDto monthlyDividend;

  SimulationPercentilesDto({
    required this.portfolioValue,
    required this.monthlyDividend,
  });

  factory SimulationPercentilesDto.fromJson(Map<String, dynamic> json) {
    return SimulationPercentilesDto(
      portfolioValue: SimulationPercentileValueDto.fromJson(
        json['portfolioValue'] as Map<String, dynamic>,
      ),
      monthlyDividend: SimulationPercentileValueDto.fromJson(
        json['monthlyDividend'] as Map<String, dynamic>,
      ),
    );
  }
}

class SimulationPercentileValueDto {
  final double p10;
  final double p50;
  final double p90;

  SimulationPercentileValueDto({
    required this.p10,
    required this.p50,
    required this.p90,
  });

  factory SimulationPercentileValueDto.fromJson(Map<String, dynamic> json) {
    return SimulationPercentileValueDto(
      p10: (json['p10'] as num).toDouble(),
      p50: (json['p50'] as num).toDouble(),
      p90: (json['p90'] as num).toDouble(),
    );
  }
}

class SimulationGoalAnalysisDto {
  final SimulationGoalMetricDto portfolioValueGoal;
  final SimulationGoalMetricDto monthlyDividendGoal;

  SimulationGoalAnalysisDto({
    required this.portfolioValueGoal,
    required this.monthlyDividendGoal,
  });

  factory SimulationGoalAnalysisDto.fromJson(Map<String, dynamic> json) {
    return SimulationGoalAnalysisDto(
      portfolioValueGoal: SimulationGoalMetricDto.fromJson(
        json['portfolioValueGoal'] as Map<String, dynamic>,
      ),
      monthlyDividendGoal: SimulationGoalMetricDto.fromJson(
        json['monthlyDividendGoal'] as Map<String, dynamic>,
      ),
    );
  }
}

class SimulationGoalMetricDto {
  final int? expectedMonthsToTarget;

  SimulationGoalMetricDto({required this.expectedMonthsToTarget});

  factory SimulationGoalMetricDto.fromJson(Map<String, dynamic> json) {
    final value = json['expectedMonthsToTarget'];

    return SimulationGoalMetricDto(
      expectedMonthsToTarget: value == null ? null : (value as num).toInt(),
    );
  }
}
