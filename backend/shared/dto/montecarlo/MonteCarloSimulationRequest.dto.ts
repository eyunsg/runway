export interface AssetInputDto {
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
}

export class RunMonteCarloSimulationRequestDto {
  public investmentPeriodMonths: number;
  public assets: AssetInputDto[];

  constructor(data: { investmentPeriodMonths: number; assets: AssetInputDto[] }) {
    // 필수값/형식 검증 - Request DTO)
    if (!data || !data.investmentPeriodMonths || !data.assets) {
      throw new Error('Invalid request body. Missing required fields.');
    }

    // 필수값 체크)
    if (data.assets.length === 0) {
      throw new Error('At least one asset is required for simulation.');
    }

    // 범위 검증: Monte Carlo Simulation Design 2항 (투자 기간 ≤ 50년 = 600개월)
    if (data.investmentPeriodMonths <= 0 || data.investmentPeriodMonths > 600) {
      throw new Error('Investment period must be between 1 and 600 months.');
    }

    this.investmentPeriodMonths = data.investmentPeriodMonths;
    this.assets = data.assets;
  }
}
