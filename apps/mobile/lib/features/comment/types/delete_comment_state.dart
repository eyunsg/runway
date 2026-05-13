class DeleteCommentState {
  final bool isSubmitting;
  final bool isSuccess;
  final String? error;

  const DeleteCommentState({
    this.isSubmitting = false,
    this.isSuccess = false,
    this.error,
  });

  DeleteCommentState copyWith({
    bool? isSubmitting,
    bool? isSuccess,
    String? error,
    bool clearError = false,
  }) {
    return DeleteCommentState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
