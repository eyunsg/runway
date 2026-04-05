import { AssetType } from '../../domain/AssetType.ts';

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

export class RunMonteCarloSimulationRequestDto {
  public investmentPeriodMonths: number;
  public assets: AssetInputDto[];

  constructor(data: any) {
    if (!data) {
      throw new Error('VALIDATION_ERROR: Request body is required');
    }

    this.validateTopLevel(data);

    this.investmentPeriodMonths = data.investmentPeriodMonths;
    this.assets = data.assets.map((asset: any, index: number) => {
      this.validateAsset(asset, index);
      // [피드백 5 반영] DTO는 데이터를 수정하지 않고 원본 그대로 Service에 전달합니다.
      return asset as AssetInputDto;
    });
  }

  private validateTopLevel(data: any): void {
    if (typeof data.investmentPeriodMonths !== 'number') {
      throw new Error('VALIDATION_ERROR: investmentPeriodMonths must be a number');
    }

    if (!Array.isArray(data.assets) || data.assets.length === 0) {
      throw new Error('VALIDATION_ERROR: assets must be a non-empty array');
    }

    if (data.investmentPeriodMonths <= 0 || data.investmentPeriodMonths > 600) {
      throw new Error('VALIDATION_ERROR: Investment period must be between 1 and 600 months.');
    }
  }

  private validateAsset(asset: any, index: number): void {
    if (!asset.assetName || typeof asset.assetName !== 'string') {
      throw new Error(`VALIDATION_ERROR: Asset[${index}] invalid assetName`);
    }

    // AssetType 유효성 검사 (AssetType.ts가 enum/object인 경우)
    if (!asset.assetType) {
      throw new Error(`VALIDATION_ERROR: Asset[${index}] missing assetType`);
    }

    if (typeof asset.initialPrice !== 'number' || asset.initialPrice <= 0) {
      throw new Error(`VALIDATION_ERROR: Asset[${index}] invalid initialPrice`);
    }

    if (typeof asset.expectedAnnualPriceGrowthRate !== 'number') {
      throw new Error(`VALIDATION_ERROR: Asset[${index}] invalid expectedAnnualPriceGrowthRate`);
    }

    if (typeof asset.initialInvestmentAmount !== 'number') {
      throw new Error(`VALIDATION_ERROR: Asset[${index}] invalid initialInvestmentAmount`);
    }

    if (typeof asset.monthlyContributionAmount !== 'number') {
      throw new Error(`VALIDATION_ERROR: Asset[${index}] invalid monthlyContributionAmount`);
    }

    if (typeof asset.isDividendAsset !== 'boolean') {
      throw new Error(`VALIDATION_ERROR: Asset[${index}] invalid isDividendAsset`);
    }

    // 배당 자산일 경우 필수 필드 형식 검증
    if (asset.isDividendAsset) {
      if (typeof asset.dividendPerShare !== 'number') {
        throw new Error(`VALIDATION_ERROR: Asset[${index}] invalid dividendPerShare`);
      }

      if (typeof asset.expectedAnnualDividendGrowthRate !== 'number') {
        throw new Error(
          `VALIDATION_ERROR: Asset[${index}] invalid expectedAnnualDividendGrowthRate`
        );
      }

      if (
        typeof asset.dividendFrequencyPerYear !== 'number' ||
        ![1, 2, 4, 12].includes(asset.dividendFrequencyPerYear)
      ) {
        throw new Error(
          `VALIDATION_ERROR: Asset[${index}] invalid dividendFrequencyPerYear (must be 1, 2, 4, or 12)`
        );
      }
    }
  }
}
