class DeletePostState {
  final bool isLoading;
  final String? error;
  final bool isSuccess;

  const DeletePostState({
    this.isLoading = false,
    this.error,
    this.isSuccess = false,
  });

  DeletePostState copyWith({bool? isLoading, String? error, bool? isSuccess}) {
    return DeletePostState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}
