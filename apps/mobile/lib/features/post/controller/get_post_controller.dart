import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:runway/core/error/failure_extension.dart';
import 'package:runway/features/post/types/get_post_state.dart';
import 'package:runway/features/post/usecase/get_post_usecase.dart';

class GetPostController extends StateNotifier<GetPostState> {
  final GetPostUsecase useCase;

  GetPostController({required this.useCase}) : super(const GetPostState());

  Future<void> fetchPost() async {
    state = state.copyWith(
      isLoading: true,
      error: null,
      posts: [],
      hasMore: false,
    );

    final result = await useCase.execute();

    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.toMessage());
      },
      (list) {
        state = state.copyWith(isLoading: false, posts: list, hasMore: false);
      },
    );
  }
}
