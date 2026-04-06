// 분위수 결과 정보 인터페이스 - 모든 수치는 원 단위 정수(Amount)로 반환
export interface PercentileResultDto {
  p10: number; // 하위 10%
  p50: number; // 중위 50% (기대값)
  p90: number; // 상위 10%
}

// 목표 달성 분석 결과 정보 인터페이스
export interface GoalAchievementResultDto {
  // 목표 도달에 소요된 예상 개월 수 - 분석 한계치(600개월) 내에 도달하지 못한 경우 null을 반환
  expectedMonthsToTarget: number | null;
}

export class SimulationResponseDto {
  public percentiles: {
    portfolioValue: PercentileResultDto;
    monthlyDividend: PercentileResultDto;
  };

  public goalAnalysis: {
    portfolioValueGoal: GoalAchievementResultDto;
    monthlyDividendGoal: GoalAchievementResultDto;
  };

  constructor(params: {
    percentiles: {
      portfolioValue: PercentileResultDto;
      monthlyDividend: PercentileResultDto;
    };
    goalAnalysis: {
      portfolioValueGoal: GoalAchievementResultDto;
      monthlyDividendGoal: GoalAchievementResultDto;
    };
  }) {
    this.percentiles = params.percentiles;
    this.goalAnalysis = params.goalAnalysis;
  }

  // 서비스 레이어의 결과 데이터를 DTO 구조로 변환하는 정적 메서드
  public static fromResults(
    mcResults: {
      portfolioValue: PercentileResultDto;
      monthlyDividend: PercentileResultDto;
    },
    goalResults: {
      portfolioValueReachedMonths: number | null;
      monthlyDividendReachedMonths: number | null;
    }
  ): SimulationResponseDto {
    return new SimulationResponseDto({
      percentiles: {
        portfolioValue: mcResults.portfolioValue,
        monthlyDividend: mcResults.monthlyDividend,
      },
      goalAnalysis: {
        portfolioValueGoal: {
          expectedMonthsToTarget: goalResults.portfolioValueReachedMonths,
        },
        monthlyDividendGoal: {
          expectedMonthsToTarget: goalResults.monthlyDividendReachedMonths,
        },
      },
    });
  }
}
