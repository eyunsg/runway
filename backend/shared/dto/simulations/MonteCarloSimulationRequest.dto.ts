export enum AssetType {
  STOCK = 'STOCK',
  CRYPTO = 'CRYPTO',
  INDEX = 'INDEX',
  COMMODITY = 'COMMODITY',
  GOLD = 'GOLD',
}

export interface AssetInputDto {
  assetName: string;
  assetType: AssetType;
  initialPrice: number;
  expectedAnnualPriceGrowthRate: number;
  initialInvestmentAmount: number;
  monthlyContributionAmount: number;
  isDividendAsset: boolean;
  dividendPerShare: number;
  expectedAnnualDividendGrowthRate: number;
  dividendFrequencyPerYear: number;
  isReinvestDividends: boolean;
}

export class RunMonteCarloSimulationRequestDto {
  public investmentPeriodMonths: number;
  public assets: AssetInputDto[];

  constructor(data: { investmentPeriodMonths: number; assets: AssetInputDto[] }) {
    this.validate(data);

    this.investmentPeriodMonths = data.investmentPeriodMonths;
    this.assets = data.assets;
  }

  private validate(data: { investmentPeriodMonths: number; assets: AssetInputDto[] }): void {
    if (!data || data.investmentPeriodMonths === undefined || !data.assets) {
      throw new Error('필수 요청 필드가 누락되었습니다.');
    }

    if (data.assets.length === 0) {
      throw new Error('시뮬레이션을 위해 최소 하나 이상의 자산이 필요합니다.');
    }

    if (data.investmentPeriodMonths <= 0 || data.investmentPeriodMonths > 600) {
      throw new Error('투자 기간은 1개월에서 600개월 사이여야 합니다.');
    }
  }
}
