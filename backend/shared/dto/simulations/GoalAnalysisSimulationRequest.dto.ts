import { AssetInputDto } from './MonteCarloSimulationRequest.dto.ts';

export interface SimulationGoalDto {
  investmentPeriodMonths: number;
  targetPortfolioAmount: number;
  targetMonthlyDividendAmount: number;
}

export class GoalAnalysisSimulationRequestDto {
  public goal: SimulationGoalDto;
  public assets: AssetInputDto[];

  constructor(data: { goal: SimulationGoalDto; assets: AssetInputDto[] }) {
    this.validate(data);
    this.goal = data.goal;
    this.assets = data.assets;
  }

  private validate(data: { goal: SimulationGoalDto; assets: AssetInputDto[] }): void {
    if (!data || !data.goal || !data.assets) {
      throw new Error('VALIDATION_ERROR: 필수 데이터가 누락되었습니다.');
    }

    if (!Array.isArray(data.assets) || data.assets.length === 0) {
      throw new Error('VALIDATION_ERROR: 최소 하나 이상의 자산 정보가 필요합니다.');
    }

    if (data.assets.length > 10) {
      throw new Error('VALIDATION_ERROR: 최대 10개 자산까지만 분석 가능합니다.');
    }

    const { investmentPeriodMonths, targetPortfolioAmount, targetMonthlyDividendAmount } =
      data.goal;

    if (
      typeof targetPortfolioAmount !== 'number' ||
      typeof targetMonthlyDividendAmount !== 'number' ||
      typeof investmentPeriodMonths !== 'number'
    ) {
      throw new Error('VALIDATION_ERROR: 목표 수치는 숫자여야 합니다.');
    }

    if (investmentPeriodMonths <= 0 || investmentPeriodMonths > 600) {
      throw new Error('VALIDATION_ERROR: 투자 기간은 1개월에서 600개월 사이여야 합니다.');
    }
  }
}
