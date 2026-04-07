class SimulationState {
  final bool isLoading;
  final bool isSuccess;
  final String? error;
  final dynamic resultData;

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
    dynamic resultData,
  }) {
    return SimulationState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      error: error,
      resultData: resultData ?? this.resultData,
    );
  }
}
