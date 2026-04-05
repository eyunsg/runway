import { SimulationInput, SimulationResult } from './portfolios';

export class GetPortfolioResponseDto {
  public name: string;
  public simulationInput: SimulationInput;
  public simulationResult: SimulationResult;

  constructor(name: string, simulationInput: SimulationInput, simulationResult: SimulationResult) {
    this.name = name;
    this.simulationInput = simulationInput;
    this.simulationResult = simulationResult;
  }
}

export class PortfolioSummaryDto {
  public portfolioId: string;
  public name: string;
  public updatedAt?: number;

  constructor(portfolioId: string, name: string, updatedAt?: number) {
    this.portfolioId = portfolioId;
    this.name = name;
    this.updatedAt = updatedAt;
  }
}

export class PortfolioActionResponseDto {
  public portfolioId: string;
  public actionAt: number; // updatedAt 또는 deletedAt 타임스탬프

  constructor(portfolioId: string, actionAt: number) {
    this.portfolioId = portfolioId;
    this.actionAt = actionAt;
  }
}
