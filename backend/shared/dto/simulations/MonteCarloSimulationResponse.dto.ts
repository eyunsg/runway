export interface PercentileResultDto {
  p10: number; // 하위 10% (원 단위 정수)
  p50: number; // 중위 50% (원 단위 정수)
  p90: number; // 상위 10% (원 단위 정수)
}

export class MonteCarloSimulationResponseDto {
  public percentiles: {
    portfolioAmount: PercentileResultDto;
    monthlyDividendAmount: PercentileResultDto;
  };

  constructor(portfolioAmount: PercentileResultDto, monthlyDividendAmount: PercentileResultDto) {
    this.percentiles = {
      portfolioAmount: portfolioAmount,
      monthlyDividendAmount: monthlyDividendAmount,
    };
  }
}
