import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:runway/core/error/failure_extension.dart';
import 'package:runway/features/portfolio/types/get_portfolio_detail_state.dart';
import 'package:runway/features/portfolio/usecase/get_portfolio_detail_usecase.dart';

class GetPortfolioDetailController
    extends StateNotifier<GetPortfolioDetailState> {
  final GetPortfolioDetailUseCase useCase;

  GetPortfolioDetailController({required this.useCase})
    : super(const GetPortfolioDetailState());

  Future<void> getPortfolioDetail(String portfolioId) async {
    state = state.copyWith(isLoading: true, isSuccess: false, error: null);

    final result = await useCase.execute(portfolioId: portfolioId);

    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.toMessage());
      },
      (portfolioDetail) {
        state = state.copyWith(
          isLoading: false,
          isSuccess: true,
          portfolioDetail: portfolioDetail,
        );
      },
    );
  }
}
