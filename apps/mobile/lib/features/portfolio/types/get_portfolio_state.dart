import 'package:runway/domain/entity/portfolio.dart';

class GetPortfolioState {
  final List<Portfolio> portfolios;
  final bool isLoading;
  final bool isSuccess;
  final String? error;
  final bool hasMore;

  const GetPortfolioState({
    this.portfolios = const [],
    this.isLoading = false,
    this.isSuccess = false,
    this.error,
    this.hasMore = true,
  });

  GetPortfolioState copyWith({
    List<Portfolio>? portfolios,
    bool? isLoading,
    bool? isSuccess,
    String? error,
    bool? hasMore,
  }) {
    return GetPortfolioState(
      portfolios: portfolios ?? this.portfolios,
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      error: error,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}
