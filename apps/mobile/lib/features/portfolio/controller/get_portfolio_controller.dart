import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:runway/core/error/failure_extension.dart';
import 'package:runway/features/portfolio/types/get_portfolio_state.dart';
import 'package:runway/features/portfolio/usecase/get_portfolio_usecase.dart';

class GetPortfolioController extends StateNotifier<GetPortfolioState> {
  final GetPortfolioUseCase useCase;

  GetPortfolioController({required this.useCase})
    : super(const GetPortfolioState());

  Future<void> fetchPortfolio() async {
    // _offset = 0;

    state = state.copyWith(
      isLoading: true,
      error: null,
      portfolios: [],
      hasMore: false,
    );

    final result = await useCase.execute();

    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.toMessage());
      },
      (list) {
        state = state.copyWith(
          isLoading: false,
          portfolios: list,
          hasMore: false,
        );
      },
    );
  }
}
