import { AssetInputDto, SimulationGoalDto } from '../simulations/SimulationRequest.dto.ts';
import {
  PercentileResultDto,
  GoalAchievementResultDto,
} from '../simulations/SimulationResponse.dto.ts';

export class SavePortfolioRequestDto {
  public name: string;
  public simulationInput: {
    goal: SimulationGoalDto;
    assets: AssetInputDto[];
  };
  public simulationResult: {
    percentiles: {
      portfolioValue: PercentileResultDto;
      monthlyDividend: PercentileResultDto;
    };
    goalAnalysis: {
      portfolioValueGoal: GoalAchievementResultDto;
      monthlyDividendGoal: GoalAchievementResultDto;
    };
  };

  constructor(body: any) {
    // 1. 기본 구조 검증
    this.validateSchema(body);

    // 2. 필드 매핑 (No-Wrapping 규칙 적용)
    this.name = body.name;
    this.simulationInput = body.simulationInput;
    this.simulationResult = body.simulationResult;
  }

  private validateSchema(body: any): void {
    if (!body) {
      throw new Error('VALIDATION_ERROR: 요청 본문이 비어있습니다.');
    }

    // 이름 검증
    if (!body.name || typeof body.name !== 'string') {
      throw new Error('VALIDATION_ERROR: 포트폴리오 이름(name)은 필수이며 문자열이어야 합니다.');
    }

    // simulationInput 구조 검증
    if (!body.simulationInput || typeof body.simulationInput !== 'object') {
      throw new Error('VALIDATION_ERROR: simulationInput 객체가 누락되었거나 올바르지 않습니다.');
    }

    if (!body.simulationInput.goal || !Array.isArray(body.simulationInput.assets)) {
      throw new Error(
        'VALIDATION_ERROR: simulationInput 내부에 goal 또는 assets 배열이 누락되었습니다.'
      );
    }

    // simulationResult 구조 검증
    if (!body.simulationResult || typeof body.simulationResult !== 'object') {
      throw new Error('VALIDATION_ERROR: simulationResult 객체가 누락되었거나 올바르지 않습니다.');
    }

    const { percentiles, goalAnalysis } = body.simulationResult;
    if (!percentiles || !goalAnalysis) {
      throw new Error(
        'VALIDATION_ERROR: simulationResult 내부에 percentiles 또는 goalAnalysis가 누락되었습니다.'
      );
    }
  }
}

export { SavePortfolioRequestDto as AddPortfolioRequestDto };
