export interface PercentileResultDto {
  p10: number; // 하위 10% (원 단위 정수)
  p50: number; // 중위 50% (원 단위 정수)
  p90: number; // 상위 10% (원 단위 정수)
}

export class MonteCarloSimulationResponseDto {
  public percentiles: {
    portfolioValue: PercentileResultDto;
    monthlyDividend: PercentileResultDto;
  };

  constructor(portfolioValue: PercentileResultDto, monthlyDividend: PercentileResultDto) {
    this.percentiles = {
      portfolioValue: portfolioValue,
      monthlyDividend: monthlyDividend,
    };
  }
}
