import { AssetInputDto, SimulationGoalDto } from '../../dto/simulations/SimulationRequest.dto.ts';
import {
  PercentileResultDto,
  GoalAchievementResultDto,
} from '../../dto/simulations/SimulationResponse.dto.ts';

export class Portfolio {
  constructor(
    public readonly userId: string,
    public readonly name: string,
    public readonly simulationInput: {
      goal: SimulationGoalDto;
      assets: AssetInputDto[];
    },
    public readonly simulationResult: {
      percentiles: {
        portfolioValue: PercentileResultDto;
        monthlyDividend: PercentileResultDto;
      };
      goalAnalysis: {
        portfolioValueGoal: GoalAchievementResultDto;
        monthlyDividendGoal: GoalAchievementResultDto;
      };
    },
    public readonly id?: string
  ) {
    this.validate();
  }

  // 비즈니스 규칙 검증
  private validate() {
    // 이름 검증
    if (!this.name || this.name.trim().length === 0) {
      throw new Error('VALIDATION_ERROR: 포트폴리오 이름은 필수이며 비어있을 수 없습니다.');
    }
    if (this.name.length > 100) {
      throw new Error('VALIDATION_ERROR: 포트폴리오 이름은 100자 이내여야 합니다.');
    }

    // 자산 수 검증 (Min/Max Limit)
    const assetCount = this.simulationInput.assets?.length || 0;

    if (assetCount === 0) {
      throw new Error('VALIDATION_ERROR: 최소 하나 이상의 자산이 필요합니다.');
    }

    if (assetCount > 10) {
      throw new Error('VALIDATION_ERROR: 자산은 최대 10개까지만 저장 가능합니다.');
    }
  }
}
