import 'package:runway/features/comment/model/comment.dart';

class GetCommentsState {
  final List<Comment> comments;
  final bool isLoading;
  final bool isSuccess;
  final String? error;

  const GetCommentsState({
    this.comments = const [],
    this.isLoading = false,
    this.isSuccess = false,
    this.error,
  });

  GetCommentsState copyWith({
    List<Comment>? comments,
    bool? isLoading,
    bool? isSuccess,
    String? error,
  }) {
    return GetCommentsState(
      comments: comments ?? this.comments,
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      error: error,
    );
  }
}
