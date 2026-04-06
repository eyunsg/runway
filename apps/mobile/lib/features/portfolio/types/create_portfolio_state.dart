class PortfolioState {
  final bool isLoading;
  final bool isSuccess;
  final String? error;

  const PortfolioState({
    this.isLoading = false,
    this.isSuccess = false,
    this.error,
  });

  PortfolioState copyWith({bool? isLoading, bool? isSuccess, String? error}) {
    return PortfolioState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      error: error,
    );
  }
}
