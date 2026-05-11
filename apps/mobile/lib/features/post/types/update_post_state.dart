import 'package:runway/features/post/model/create_post_selected_portfolio.dart';

class UpdatePostState {
  static const Object _sentinel = Object();

  final String postId;
  final String content;
  final CreatePostSelectedPortfolio? selectedPortfolio;
  final bool isSubmitting;
  final bool isSuccess;
  final String? error;
  final bool shouldShowPortfolioDeletedMessage;
  final bool isInitialized;
  final bool isPortfolioChanged;
  final bool isPortfolioRemoved;

  const UpdatePostState({
    this.postId = '',
    this.content = '',
    this.selectedPortfolio,
    this.isSubmitting = false,
    this.isSuccess = false,
    this.error,
    this.shouldShowPortfolioDeletedMessage = false,
    this.isInitialized = false,
    this.isPortfolioChanged = false,
    this.isPortfolioRemoved = false,
  });

  UpdatePostState copyWith({
    String? postId,
    String? content,
    CreatePostSelectedPortfolio? selectedPortfolio,
    bool clearSelectedPortfolio = false,
    bool? isSubmitting,
    bool? isSuccess,
    Object? error = _sentinel,
    bool? shouldShowPortfolioDeletedMessage,
    bool? isInitialized,
    bool? isPortfolioChanged,
    bool? isPortfolioRemoved,
  }) {
    return UpdatePostState(
      postId: postId ?? this.postId,
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
      isInitialized: isInitialized ?? this.isInitialized,
      isPortfolioChanged: isPortfolioChanged ?? this.isPortfolioChanged,
      isPortfolioRemoved: isPortfolioRemoved ?? this.isPortfolioRemoved,
    );
  }
}
