import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:runway/core/error/failure_extension.dart';
import 'package:runway/features/post/model/create_post_selected_portfolio.dart';
import 'package:runway/features/post/model/post.dart';
import 'package:runway/features/post/types/update_post_state.dart';
import 'package:runway/features/post/usecase/update_post_usecase.dart';

class UpdatePostController extends StateNotifier<UpdatePostState> {
  final UpdatePostUsecase useCase;

  UpdatePostController({required this.useCase})
    : super(const UpdatePostState());

  void reset() {
    state = const UpdatePostState();
  }

  void initialize(Post post) {
    if (state.isInitialized && state.postId == post.postId) {
      return;
    }

    final bool hasPortfolio = post.portfolioName.trim().isNotEmpty;

    state = state.copyWith(
      postId: post.postId,
      content: post.content,
      selectedPortfolio: hasPortfolio
          ? CreatePostSelectedPortfolio(
              id: '',
              name: post.portfolioName,
              assetCount: post.assetCount,
              periodMonths: post.investmentPeriodMonths,
            )
          : null,
      isSubmitting: false,
      isSuccess: false,
      error: null,
      shouldShowPortfolioDeletedMessage: false,
      isInitialized: true,
      isPortfolioChanged: false,
      isPortfolioRemoved: false,
    );
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
      isPortfolioChanged: true,
      isPortfolioRemoved: false,
    );
  }

  void clearSelectedPortfolio() {
    state = state.copyWith(
      clearSelectedPortfolio: true,
      error: null,
      isSuccess: false,
      shouldShowPortfolioDeletedMessage: true,
      isPortfolioChanged: true,
      isPortfolioRemoved: true,
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

  Future<void> submitUpdate() async {
    state = state.copyWith(isSubmitting: true, error: null, isSuccess: false);

    final result = await useCase.execute(
      postId: state.postId,
      content: state.content,
      portfolioId: state.selectedPortfolio?.id,
      isPortfolioRemoved: state.isPortfolioRemoved,
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
