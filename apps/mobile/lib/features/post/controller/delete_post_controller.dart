import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:runway/features/post/types/delete_post_state.dart';
import 'package:runway/features/post/usecase/delete_post_usecase.dart';

class DeletePostController extends StateNotifier<DeletePostState> {
  final DeletePostUsecase useCase;

  DeletePostController({required this.useCase})
    : super(const DeletePostState());

  Future<void> deletePost(String postId) async {
    state = state.copyWith(isLoading: true, isSuccess: false, error: null);

    final result = await useCase.execute(postId);

    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
      },
      (_) {
        state = state.copyWith(isLoading: false, isSuccess: true);
      },
    );
  }
}
