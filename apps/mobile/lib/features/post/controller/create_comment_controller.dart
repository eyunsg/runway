import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:runway/core/error/failure_extension.dart';
import 'package:runway/features/post/types/create_comment_state.dart';
import 'package:runway/features/post/usecase/create_comment_usecase.dart';

class CreateCommentController extends StateNotifier<CreateCommentState> {
  final CreateCommentUsecase useCase;

  CreateCommentController({required this.useCase})
    : super(const CreateCommentState());

  void updateContent(String content) {
    state = state.copyWith(content: content, error: null, isSuccess: false);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void clearSuccess() {
    state = state.copyWith(isSuccess: false);
  }

  void reset() {
    state = const CreateCommentState();
  }

  Future<void> submitComment({required String postId}) async {
    state = state.copyWith(isSubmitting: true, error: null, isSuccess: false);

    final result = await useCase.execute(
      postId: postId,
      content: state.content,
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          isSubmitting: false,
          error: failure.toMessage(),
          isSuccess: false,
        );
      },
      (_) {
        state = state.copyWith(
          isSubmitting: false,
          error: null,
          isSuccess: true,
          content: '',
        );
      },
    );
  }
}
