import 'package:runway/features/portfolio/dto/create_portfolio_request_dto.dart';
import 'package:runway/features/portfolio/model/simulation_result.dart';

export 'simulation_input.dart';
export 'simulation_result.dart';

class CreatePortfolioInput {
  final String name;

  final SimulationInput simulationInput;
  final SimulationResultInput simulationResult;

  CreatePortfolioInput({
    required this.name,
    required this.simulationInput,
    required this.simulationResult,
  });
}
