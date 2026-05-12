import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:runway/core/error/failure_extension.dart';
import 'package:runway/features/comment/types/get_comments_state.dart';
import 'package:runway/features/comment/usecase/get_comments_usecase.dart';

class GetCommentsController extends StateNotifier<GetCommentsState> {
  final GetCommentsUsecase useCase;

  GetCommentsController({required this.useCase})
    : super(const GetCommentsState());

  Future<void> fetchComments(String postId) async {
    state = state.copyWith(
      isLoading: true,
      isSuccess: false,
      error: null,
      comments: const [],
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
      (comments) {
        state = state.copyWith(
          isLoading: false,
          isSuccess: true,
          error: null,
          comments: comments,
        );
      },
    );
  }
}
