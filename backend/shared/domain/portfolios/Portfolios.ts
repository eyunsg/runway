import {
  SimulationGoal,
  Asset,
  SimulationInput,
  Percentiles,
  GoalAnalysisItem,
  SimulationResult,
} from '';

export class Portfolio {
  constructor(
    public readonly id: string | null,
    public userId: string,
    public name: string,
    public simulationInput: SimulationInput,
    public simulationResult: SimulationResult,
    public readonly createdAt: Date = new Date(),
    public updatedAt: Date = new Date(),
    public deletedAt: Date | null = null
  ) {
    this.validate();
  }

  private validate() {
    if (!this.name || this.name.trim().length === 0) {
      throw new Error('VALIDATION_ERROR: Portfolio name is required.');
    }
    if (this.name.length > 100) {
      throw new Error('VALIDATION_ERROR: Portfolio name must be less than 100 characters.');
    }
    if (this.simulationInput.goal.investmentPeriodMonths <= 0) {
      throw new Error('VALIDATION_ERROR: Investment period must be at least 1 month.');
    }
    if (!this.simulationInput.assets || this.simulationInput.assets.length === 0) {
      throw new Error('VALIDATION_ERROR: At least one asset is required for simulation.');
    }
  }

  public isActive(): boolean {
    return this.deletedAt === null;
  }
}
