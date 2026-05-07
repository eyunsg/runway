import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:runway/core/error/failure_extension.dart';
import 'package:runway/features/post/types/get_my_post_state.dart';
import 'package:runway/features/post/usecase/get_my_post_usecase.dart';

class GetMyPostController extends StateNotifier<GetMyPostState> {
  final GetMyPostUsecase useCase;

  GetMyPostController({required this.useCase}) : super(const GetMyPostState());

  Future<void> fetchMyPost() async {
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
