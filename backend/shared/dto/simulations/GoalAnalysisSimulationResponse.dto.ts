export interface PercentileResultDto {
  p10: number;
  p50: number;
  p90: number;
}

export interface GoalAchievementResultDto {
  expectedMonthsToTarget: number;
}

export interface GoalAchievementResultDto {
  expectedMonthsToTarget: number;
}

export class GoalAnalysisSimulationResponseDto {
  public percentiles: {
    portfolioValue: PercentileResultDto;
    monthlyDividend: PercentileResultDto;
  };

  // 인터페이스 대신 인라인 타입을 사용하여 구조를 정의함
  public goalAnalysis: {
    portfolioValueGoal: GoalAchievementResultDto | null;
    monthlyDividendGoal: GoalAchievementResultDto | null;
  };

  constructor(
    portfolioValueGoal: GoalAchievementResultDto | null,
    monthlyDividendGoal: GoalAchievementResultDto | null
  ) {
    // 결정론적 모델이므로 percentiles는 0으로 초기화하여 구조만 유지
    const zeroPercentile = { p10: 0, p50: 0, p90: 0 };

    this.percentiles = {
      portfolioValue: zeroPercentile,
      monthlyDividend: zeroPercentile,
    };

    this.goalAnalysis = {
      portfolioValueGoal,
      monthlyDividendGoal,
    };
  }

  // 성공 응답
  public static toSuccess(
    portfolioValueGoal: GoalAchievementResultDto | null,
    monthlyDividendGoal: GoalAchievementResultDto | null
  ) {
    return {
      data: new GoalAnalysisSimulationResponseDto(portfolioValueGoal, monthlyDividendGoal),
      error: null,
    };
  }

  // 실패 응답
  public static toError(message: string) {
    return {
      data: null,
      error: {
        message: message,
      },
    };
  }
}
