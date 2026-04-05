import { AssetType } from '../../domain/AssetType.ts';

//개별 자산 입력정보
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
  dividendFrequencyPerYear: number; // dividendFrequency -> PerYear 명시
  isReinvestDividends: boolean;
}

function isValidAssetType(value: any): value is AssetType {
  return Object.values(AssetType).includes(value);
}

// 몬테카를로 시뮬레이션 요청 DTO
export class RunMonteCarloSimulationRequestDto {
  public investmentPeriodMonths: number;
  public assets: AssetInputDto[];

  constructor(data: any) {
    if (!data) {
      throw new Error('Request body is required');
    }

    this.validateTopLevel(data);

    this.investmentPeriodMonths = data.investmentPeriodMonths;
    this.assets = data.assets.map((asset: any, index: number) => {
      this.validateAsset(asset, index);
      // 비배당 시 0으로 초기화 등 하지 않고 그대로 넘김
      return asset as AssetInputDto;
    });
  }

  private validateTopLevel(data: any): void {
    if (typeof data.investmentPeriodMonths !== 'number') {
      throw new Error('investmentPeriodMonths must be a number');
    }

    if (!Array.isArray(data.assets)) {
      throw new Error('assets must be an array');
    }

    if (data.assets.length === 0) {
      throw new Error('At least one asset is required for simulation.');
    }

    if (data.investmentPeriodMonths <= 0 || data.investmentPeriodMonths > 600) {
      throw new Error('Investment period must be between 1 and 600 months.');
    }
  }

  private validateAsset(asset: any, index: number): void {
    if (!asset.assetName || typeof asset.assetName !== 'string') {
      throw new Error(`Asset[${index}] invalid assetName`);
    }

    if (!isValidAssetType(asset.assetType)) {
      throw new Error(`Asset[${index}] invalid assetType: ${asset.assetType}`);
    }

    if (typeof asset.initialPrice !== 'number' || asset.initialPrice <= 0) {
      throw new Error(`Asset[${index}] invalid initialPrice`);
    }

    if (typeof asset.expectedAnnualPriceGrowthRate !== 'number') {
      throw new Error(`Asset[${index}] invalid expectedAnnualPriceGrowthRate`);
    }

    if (typeof asset.initialInvestmentAmount !== 'number') {
      throw new Error(`Asset[${index}] invalid initialInvestmentAmount`);
    }

    if (typeof asset.monthlyContributionAmount !== 'number') {
      throw new Error(`Asset[${index}] invalid monthlyContributionAmount`);
    }

    if (typeof asset.isDividendAsset !== 'boolean') {
      throw new Error(`Asset[${index}] invalid isDividendAsset`);
    }

    // 배당 자산일 경우 필수 필드 형식 검증
    if (asset.isDividendAsset) {
      if (typeof asset.dividendPerShare !== 'number') {
        throw new Error(`Asset[${index}] invalid dividendPerShare`);
      }

      if (typeof asset.expectedAnnualDividendGrowthRate !== 'number') {
        throw new Error(`Asset[${index}] invalid expectedAnnualDividendGrowthRate`);
      }

      if (
        typeof asset.dividendFrequencyPerYear !== 'number' ||
        ![1, 2, 4, 12].includes(asset.dividendFrequencyPerYear)
      ) {
        throw new Error(`Asset[${index}] invalid dividendFrequencyPerYear`);
      }
    }
  }
}
