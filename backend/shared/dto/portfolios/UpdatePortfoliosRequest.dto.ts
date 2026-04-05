import { SimulationInput, SimulationResult } from './Portfolios';

export class CreatePortfolioRequestDto {
  constructor(
    public name: string,
    public simulationInput: SimulationInput,
    public simulationResult: SimulationResult
  ) {}
}

export class UpdatePortfolioRequestDto {
  constructor(
    public name?: string,
    public simulationInput?: SimulationInput,
    public simulationResult?: SimulationResult
  ) {}
}
