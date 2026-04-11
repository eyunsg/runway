import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:runway/core/error/failure_extension.dart';
import 'package:runway/features/portfolio/model/create_portfolio_input.dart';
import 'package:runway/features/portfolio/types/create_portfolio_state.dart';
import 'package:runway/features/portfolio/usecase/update_portfolio_usecase.dart';

class UpdatePortfolioController extends StateNotifier<PortfolioState> {
  final UpdatePortfolioUseCase useCase;

  UpdatePortfolioController({required this.useCase})
    : super(const PortfolioState());

  Future<void> updatePortfolio(
    String portfolioId,
    CreatePortfolioInput input,
  ) async {
    state = state.copyWith(isLoading: true, isSuccess: false, error: null);

    final result = await useCase.execute(portfolioId, input);

    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.toMessage());
      },
      (_) {
        state = state.copyWith(isLoading: false, isSuccess: true);
      },
    );
  }
}
