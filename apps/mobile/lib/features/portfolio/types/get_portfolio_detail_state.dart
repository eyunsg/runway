import 'package:runway/domain/entity/portfolio_detail.dart';

class GetPortfolioDetailState {
  final PortfolioDetail? portfolioDetail;
  final bool isLoading;
  final bool isSuccess;
  final String? error;

  const GetPortfolioDetailState({
    this.portfolioDetail,
    this.isLoading = false,
    this.isSuccess = false,
    this.error,
  });

  GetPortfolioDetailState copyWith({
    PortfolioDetail? portfolioDetail,
    bool? isLoading,
    bool? isSuccess,
    String? error,
  }) {
    return GetPortfolioDetailState(
      portfolioDetail: portfolioDetail ?? this.portfolioDetail,
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      error: error,
    );
  }
}
