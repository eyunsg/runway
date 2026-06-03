import { AssetType } from '../../domain/AssetType.ts';

// 개별 자산 입력 정보 인터페이스
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
  dividendFrequency: number; // 연간 배당 횟수
  isReinvestDividends: boolean;
}

export interface SimulationGoalDto {
  investmentPeriodMonths: number;
  targetPortfolioValue: number; // 명세서 기준: Value 사용
  targetMonthlyDividend: number;
}

export class SimulationRequestDto {
  public goal: SimulationGoalDto;
  public assets: AssetInputDto[];
  public seed?: string;

  constructor(body: any) {
    if (!body) {
      throw new Error('VALIDATION_ERROR: 요청 본문(body)이 비어있습니다.');
    }

    this.validateGoal(body.goal);
    this.validateAssets(body.assets);

    this.goal = body.goal;
    this.assets = body.assets;

    if (body.seed !== undefined && body.seed !== null) {
      if (typeof body.seed !== 'string') {
        throw new Error('VALIDATION_ERROR: seed는 문자열 형식이어야 합니다.');
      }
      this.seed = body.seed;
    }
  }

  // 목표 설정 데이터 유효성 검사
  private validateGoal(goal: any): void {
    if (!goal || typeof goal !== 'object') {
      throw new Error('VALIDATION_ERROR: goal 객체는 필수이며 올바른 형식이어야 합니다.');
    }

    const { investmentPeriodMonths, targetPortfolioValue, targetMonthlyDividend } = goal;

    if (
      typeof investmentPeriodMonths !== 'number' ||
      investmentPeriodMonths <= 0 ||
      investmentPeriodMonths > 600
    ) {
      throw new Error('VALIDATION_ERROR: investmentPeriodMonths는 1~600 사이의 숫자여야 합니다.');
    }

    if (typeof targetPortfolioValue !== 'number' || targetPortfolioValue < 0) {
      throw new Error('VALIDATION_ERROR: targetPortfolioValue는 0 이상의 숫자여야 합니다.');
    }

    if (typeof targetMonthlyDividend !== 'number' || targetMonthlyDividend < 0) {
      throw new Error('VALIDATION_ERROR: targetMonthlyDividend는 0 이상의 숫자여야 합니다.');
    }
  }

  // 자산 리스트 데이터 유효성 검사
  private validateAssets(assets: any): void {
    if (!Array.isArray(assets) || assets.length === 0) {
      throw new Error('VALIDATION_ERROR: 최소 하나 이상의 자산(assets)이 필요합니다.');
    }

    if (assets.length > 10) {
      throw new Error('VALIDATION_ERROR: 최대 10개의 자산까지만 시뮬레이션 가능합니다.');
    }

    assets.forEach((asset, index) => this.validateAssetItem(asset, index));
  }

  // 개별 자산 항목에 대한 상세 형식 검사
  private validateAssetItem(asset: any, index: number): void {
    const prefix = `VALIDATION_ERROR: Asset[${index}]`;

    if (!asset.assetName || typeof asset.assetName !== 'string') {
      throw new Error(`${prefix} assetName이 누락되었거나 문자열이 아닙니다.`);
    }

    if (!asset.assetType) {
      throw new Error(`${prefix} assetType이 누락되었습니다.`);
    }

    // 수치형 데이터 검증 (명세서의 Decimal/Integer 타입 확인)
    const numericFields = [
      'initialPrice',
      'expectedAnnualPriceGrowthRate',
      'initialInvestmentAmount',
      'monthlyContributionAmount',
    ];

    numericFields.forEach((field) => {
      if (typeof asset[field] !== 'number') {
        throw new Error(`${prefix} ${field}는 숫자 형식이어야 합니다.`);
      }
    });

    if (asset.initialPrice <= 0) {
      throw new Error(`${prefix} initialPrice는 0보다 커야 합니다.`);
    }

    if (typeof asset.isDividendAsset !== 'boolean') {
      throw new Error(`${prefix} isDividendAsset은 불리언 값이어야 합니다.`);
    }

    // 배당 자산일 경우 추가 필수 필드 검증
    if (asset.isDividendAsset) {
      if (typeof asset.dividendPerShare !== 'number' || asset.dividendPerShare < 0) {
        throw new Error(`${prefix} dividendPerShare가 숫자가 아니거나 음수입니다.`);
      }
      if (typeof asset.expectedAnnualDividendGrowthRate !== 'number') {
        throw new Error(`${prefix} expectedAnnualDividendGrowthRate가 숫자가 아닙니다.`);
      }
      if (![1, 2, 4, 12].includes(asset.dividendFrequency)) {
        throw new Error(`${prefix} dividendFrequency는 1, 2, 4, 12 중 하나여야 합니다.`);
      }
      if (typeof asset.isReinvestDividends !== 'boolean') {
        throw new Error(`${prefix} isReinvestDividends는 불리언 값이어야 합니다.`);
      }
    }
  }
}
