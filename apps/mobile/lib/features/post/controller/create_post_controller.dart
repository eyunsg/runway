import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:runway/core/error/failure_extension.dart';
import 'package:runway/features/post/model/create_post_selected_portfolio.dart';
import 'package:runway/features/post/types/create_post_state.dart';
import 'package:runway/features/post/usecase/create_post_usecase.dart';

class CreatePostController extends StateNotifier<CreatePostState> {
  final CreatePostUseCase useCase;

  CreatePostController({required this.useCase})
    : super(const CreatePostState());

  void reset() {
    state = const CreatePostState();
  }

  void updateContent(String content) {
    state = state.copyWith(content: content, error: null, isSuccess: false);
  }

  void selectPortfolio(CreatePostSelectedPortfolio portfolio) {
    state = state.copyWith(
      selectedPortfolio: portfolio,
      error: null,
      isSuccess: false,
      shouldShowPortfolioDeletedMessage: false,
    );
  }

  void clearSelectedPortfolio() {
    state = state.copyWith(
      clearSelectedPortfolio: true,
      error: null,
      isSuccess: false,
      shouldShowPortfolioDeletedMessage: true,
    );
  }

  void clearDeletedMessage() {
    state = state.copyWith(shouldShowPortfolioDeletedMessage: false);
  }

  void clearSuccess() {
    state = state.copyWith(isSuccess: false);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  Future<void> submitPost() async {
    state = state.copyWith(isSubmitting: true, error: null, isSuccess: false);

    final result = await useCase.execute(
      content: state.content,
      portfolioId: state.selectedPortfolio?.id,
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
        );
      },
    );
  }
}
