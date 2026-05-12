class CreateCommentState {
  static const Object _sentinel = Object();

  final String content;
  final bool isSubmitting;
  final bool isSuccess;
  final String? error;

  const CreateCommentState({
    this.content = '',
    this.isSubmitting = false,
    this.isSuccess = false,
    this.error,
  });

  CreateCommentState copyWith({
    String? content,
    bool? isSubmitting,
    bool? isSuccess,
    Object? error = _sentinel,
  }) {
    return CreateCommentState(
      content: content ?? this.content,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      error: identical(error, _sentinel) ? this.error : error as String?,
    );
  }
}
