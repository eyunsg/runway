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

export interface SimulationGoalDto {
  investmentPeriodMonths: number;
  targetPortfolioValue: number;
  targetMonthlyDividend: number;
}

export class GoalAnalysisSimulationRequestDto {
  public goal: SimulationGoalDto;
  public assets: AssetInputDto[];

  constructor(data: { goal: SimulationGoalDto; assets: AssetInputDto[] }) {
    // 1. 필수값/형식 검증 (DTO/모델 매핑 규칙 8항 준수)
    if (!data || !data.goal || !data.assets) {
      throw new Error('VALIDATION_ERROR: 필수 시뮬레이션 데이터가 누락되었습니다.');
    }

    // 2. 자산 리스트 체크
    if (!Array.isArray(data.assets) || data.assets.length === 0) {
      throw new Error('VALIDATION_ERROR: 최소 하나 이상의 자산 정보가 필요합니다.');
    }

    // 3. 제약 조건 검증
    if (data.assets.length > 10) {
      throw new Error('VALIDATION_ERROR: 최대 10개 자산까지만 분석 가능합니다.');
    }

    // 4. 데이터 타입 및 범위 검증
    if (
      typeof data.goal.targetPortfolioValue !== 'number' ||
      typeof data.goal.targetMonthlyDividend !== 'number' ||
      typeof data.goal.investmentPeriodMonths !== 'number'
    ) {
      throw new Error('VALIDATION_ERROR: 목표 금액, 배당금 및 투자 기간은 숫자여야 합니다.');
    }

    if (data.goal.investmentPeriodMonths <= 0 || data.goal.investmentPeriodMonths > 600) {
      throw new Error('VALIDATION_ERROR: 투자 기간은 1개월에서 600개월 사이여야 합니다.');
    }

    // 멤버 변수 할당
    this.goal = data.goal;
    this.assets = data.assets;
  }
}
