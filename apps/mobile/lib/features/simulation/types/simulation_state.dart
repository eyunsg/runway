import 'package:runway/features/simulation/types/simulation_response_dto.dart';

class SimulationState {
  final bool isLoading;
  final bool isSuccess;
  final String? error;
  final SimulationResponseDto? resultData;

  const SimulationState({
    this.isLoading = false,
    this.isSuccess = false,
    this.error,
    this.resultData,
  });

  SimulationState copyWith({
    bool? isLoading,
    bool? isSuccess,
    String? error,
    SimulationResponseDto? resultData,
  }) {
    return SimulationState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      error: error,
      resultData: resultData ?? this.resultData,
    );
  }
}
