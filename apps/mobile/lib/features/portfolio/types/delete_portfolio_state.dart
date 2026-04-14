class DeletePortfolioState {
  final bool isLoading;
  final String? error;
  final bool isSuccess;

  const DeletePortfolioState({
    this.isLoading = false,
    this.error,
    this.isSuccess = false,
  });

  DeletePortfolioState copyWith({
    bool? isLoading,
    String? error,
    bool? isSuccess,
  }) {
    return DeletePortfolioState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}
