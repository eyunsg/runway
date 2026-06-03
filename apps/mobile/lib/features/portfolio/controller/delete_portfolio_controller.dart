import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:runway/features/portfolio/types/delete_portfolio_state.dart';
import 'package:runway/features/portfolio/usecase/delete_portfolio_usecase.dart';

class DeletePortfolioController extends StateNotifier<DeletePortfolioState> {
  final DeletePortfolioUsecase useCase;

  DeletePortfolioController({required this.useCase})
    : super(const DeletePortfolioState());

  Future<void> deletePortfolio(String portfolioId) async {
    state = state.copyWith(isLoading: true, isSuccess: false, error: null);

    final result = await useCase.execute(portfolioId);

    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
      },
      (_) {
        state = state.copyWith(isLoading: false, isSuccess: true);
      },
    );
  }
}
