import 'package:runway/features/post/model/post.dart';

class GetMyPostState {
  final List<Post> posts;
  final bool isLoading;
  final bool isSuccess;
  final String? error;
  final bool hasMore;

  const GetMyPostState({
    this.posts = const [],
    this.isLoading = false,
    this.isSuccess = false,
    this.error,
    this.hasMore = true,
  });

  GetMyPostState copyWith({
    List<Post>? posts,
    bool? isLoading,
    bool? isSuccess,
    String? error,
    bool? hasMore,
  }) {
    return GetMyPostState(
      posts: posts ?? this.posts,
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      error: error,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}
