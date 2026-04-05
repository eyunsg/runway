import 'package:runway/features/portfolio/dto/simulation_input.dart';
import 'package:runway/features/portfolio/dto/simulation_result.dart';

export 'simulation_input.dart';
export 'simulation_result.dart';

class CreatePortfolioRequestDto {
  final String name;
  final SimulationInput simulationInput;
  final SimulationResult simulationResult;

  CreatePortfolioRequestDto({
    required this.name,
    required this.simulationInput,
    required this.simulationResult,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'simulationInput': simulationInput.toJson(),
    'simulationResult': simulationResult.toJson(),
  };
}
