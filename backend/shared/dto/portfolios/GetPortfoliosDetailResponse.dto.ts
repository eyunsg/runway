export class GetPortfolioDetailResponseDto {
  name: string;
  simulationInput: {
    goal: {
      investmentPeriodMonths: number;
      targetPortfolioValue: number;
      targetMonthlyDividend: number;
    };
    assets: Array<{
      assetName: string;
      assetType: string;
      initialPrice: number;
      expectedAnnualPriceGrowthRate: number;
      initialInvestmentAmount: number;
      monthlyContributionAmount: number;
      isDividendAsset: boolean;
      dividendPerShare: number;
      expectedAnnualDividendGrowthRate: number;
      dividendFrequency: number;
      isReinvestDividends: boolean;
    }>;
  };
  simulationResult: {
    percentiles: {
      portfolioValue: { p10: number; p50: number; p90: number };
      monthlyDividend: { p10: number; p50: number; p90: number };
    };
    goalAnalysis: {
      portfolioValueGoal: {
        target: number;
        achievementProbability: number;
        expectedMonthsToTarget: number | null;
      };
      monthlyDividendGoal: {
        target: number;
        achievementProbability: number;
        expectedMonthsToTarget: number | null;
      };
    };
  };

  constructor(
    name: string,
    simulationInput: GetPortfolioDetailResponseDto['simulationInput'],
    simulationResult: GetPortfolioDetailResponseDto['simulationResult']
  ) {
    this.name = name;
    this.simulationInput = simulationInput;
    this.simulationResult = simulationResult;
  }
}
