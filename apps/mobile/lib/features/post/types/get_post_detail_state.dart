import 'package:runway/features/post/model/post.dart';

class GetPostDetailState {
  final Post? post;
  final bool isLoading;
  final bool isSuccess;
  final String? error;

  const GetPostDetailState({
    this.post,
    this.isLoading = false,
    this.isSuccess = false,
    this.error,
  });

  GetPostDetailState copyWith({
    Post? post,
    bool? isLoading,
    bool? isSuccess,
    String? error,
  }) {
    return GetPostDetailState(
      post: post ?? this.post,
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      error: error,
    );
  }
}
