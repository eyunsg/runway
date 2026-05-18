import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:runway/core/error/failure_extension.dart';
import 'package:runway/features/portfolio/usecase/get_recent_portfolio_usecase.dart';
import 'package:runway/features/portfolio/types/get_recent_portfolio_state.dart';

class GetRecentPortfolioController
    extends StateNotifier<GetRecentPortfolioState> {
  final GetRecentPortfolioUseCase useCase;

  GetRecentPortfolioController({required this.useCase})
    : super(const GetRecentPortfolioState());

  Future<void> fetchRecentPortfolio() async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await useCase.execute();

    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.toMessage());
      },
      (portfolio) {
        state = state.copyWith(isLoading: false, portfolio: portfolio);
      },
    );
  }
}
