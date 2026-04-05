export interface GoalAchievementResultDto {
  reachedMonths: number | null;
}

export class GoalAnalysisSimulationResponseDto {
  public goalAnalysis: {
    portfolioAmountGoal: GoalAchievementResultDto;
    monthlyDividendAmountGoal: GoalAchievementResultDto;
  };

  constructor(
    reachedPortfolioAmountMonth: number | null,
    reachedMonthlyDividendAmountMonth: number | null
  ) {
    this.goalAnalysis = {
      portfolioAmountGoal: {
        reachedMonths: reachedPortfolioAmountMonth,
      },
      monthlyDividendAmountGoal: {
        reachedMonths: reachedMonthlyDividendAmountMonth,
      },
    };
  }

  public static toSuccess(
    reachedPortfolioAmountMonth: number | null,
    reachedMonthlyDividendAmountMonth: number | null
  ) {
    return {
      data: new GoalAnalysisSimulationResponseDto(
        reachedPortfolioAmountMonth,
        reachedMonthlyDividendAmountMonth
      ),
      error: null,
    };
  }

  public static toError(message: string) {
    return {
      data: null,
      error: {
        message: message,
      },
    };
  }
}
