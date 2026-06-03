class DeleteProfileState {
  final bool isLoading;
  final String? error;
  final bool isSuccess;

  DeleteProfileState({
    this.isLoading = false,
    this.error,
    this.isSuccess = false,
  });

  DeleteProfileState copyWith({
    bool? isLoading,
    String? error,
    bool? isSuccess,
  }) {
    return DeleteProfileState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}
