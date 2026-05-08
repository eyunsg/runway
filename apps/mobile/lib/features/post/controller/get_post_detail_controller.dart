import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:runway/core/error/failure_extension.dart';
import 'package:runway/features/post/types/get_post_detail_state.dart';
import 'package:runway/features/post/usecase/get_post_detail_usecase.dart';

class GetPostDetailController extends StateNotifier<GetPostDetailState> {
  final GetPostDetailUsecase useCase;

  GetPostDetailController({required this.useCase})
    : super(const GetPostDetailState());

  Future<void> fetchPostDetail(String postId) async {
    state = state.copyWith(
      isLoading: true,
      isSuccess: false,
      error: null,
      post: null,
    );

    final result = await useCase.execute(postId);

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          isSuccess: false,
          error: failure.toMessage(),
        );
      },
      (post) {
        state = state.copyWith(
          isLoading: false,
          isSuccess: true,
          error: null,
          post: post,
        );
      },
    );
  }
}
