import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:runway/core/error/failure_extension.dart';
import 'package:runway/features/post/types/get_post_state.dart';
import 'package:runway/features/post/usecase/get_recent_post_usecase.dart';

class GetRecentPostController extends StateNotifier<GetPostState> {
  final GetRecentPostUsecase useCase;

  GetRecentPostController({required this.useCase})
    : super(const GetPostState());

  Future<void> fetchRecentPost() async {
    state = state.copyWith(isLoading: true, error: null, posts: []);

    final result = await useCase.execute();

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          isSuccess: false,
          error: failure.toMessage(),
        );
      },
      (list) {
        state = state.copyWith(isLoading: false, isSuccess: true, posts: list);
      },
    );
  }
}
