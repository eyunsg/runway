import 'package:runway/domain/entity/portfolio.dart';

class GetRecentPortfolioState {
  final Portfolio? portfolio;
  final bool isLoading;
  final bool isSuccess;
  final String? error;

  const GetRecentPortfolioState({
    this.portfolio,
    this.isLoading = false,
    this.isSuccess = false,
    this.error,
  });

  GetRecentPortfolioState copyWith({
    Portfolio? portfolio,
    bool? isLoading,
    bool? isSuccess,
    String? error,
  }) {
    return GetRecentPortfolioState(
      portfolio: portfolio ?? this.portfolio,
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      error: error,
    );
  }
}
