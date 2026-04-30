import 'package:runway/features/post/model/create_post_selected_portfolio.dart';

class CreatePostState {
  static const Object _sentinel = Object();

  final String content;
  final CreatePostSelectedPortfolio? selectedPortfolio;
  final bool isSubmitting;
  final bool isSuccess;
  final String? error;
  final bool shouldShowPortfolioDeletedMessage;

  const CreatePostState({
    this.content = '',
    this.selectedPortfolio,
    this.isSubmitting = false,
    this.isSuccess = false,
    this.error,
    this.shouldShowPortfolioDeletedMessage = false,
  });

  CreatePostState copyWith({
    String? content,
    CreatePostSelectedPortfolio? selectedPortfolio,
    bool clearSelectedPortfolio = false,
    bool? isSubmitting,
    bool? isSuccess,
    Object? error = _sentinel,
    bool? shouldShowPortfolioDeletedMessage,
  }) {
    return CreatePostState(
      content: content ?? this.content,
      selectedPortfolio: clearSelectedPortfolio
          ? null
          : (selectedPortfolio ?? this.selectedPortfolio),
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      error: identical(error, _sentinel) ? this.error : error as String?,
      shouldShowPortfolioDeletedMessage:
          shouldShowPortfolioDeletedMessage ??
          this.shouldShowPortfolioDeletedMessage,
    );
  }
}
