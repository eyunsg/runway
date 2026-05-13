import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:runway/core/error/failure_extension.dart';
import 'package:runway/features/comment/types/delete_comment_state.dart';
import 'package:runway/features/comment/usecase/delete_comment_usecase.dart';

class DeleteCommentController extends StateNotifier<DeleteCommentState> {
  final DeleteCommentUsecase useCase;

  DeleteCommentController({required this.useCase})
    : super(const DeleteCommentState());

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  void clearSuccess() {
    state = state.copyWith(isSuccess: false);
  }

  void reset() {
    state = const DeleteCommentState();
  }

  Future<void> deleteComment({required String commentId}) async {
    state = state.copyWith(
      isSubmitting: true,
      isSuccess: false,
      clearError: true,
    );

    final result = await useCase.execute(commentId);

    result.fold(
      (failure) {
        state = state.copyWith(
          isSubmitting: false,
          isSuccess: false,
          error: failure.toMessage(),
        );
      },
      (_) {
        state = state.copyWith(
          isSubmitting: false,
          isSuccess: true,
          clearError: true,
        );
      },
    );
  }
}
