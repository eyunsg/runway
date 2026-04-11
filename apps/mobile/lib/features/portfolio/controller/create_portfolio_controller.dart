import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:runway/core/error/failure_extension.dart';
import 'package:runway/features/portfolio/model/create_portfolio_input.dart';
import 'package:runway/features/portfolio/types/create_portfolio_state.dart';
import 'package:runway/features/portfolio/usecase/create_portfolio_usecase.dart';

class CreatePortfolioController extends StateNotifier<PortfolioState> {
  final CreatePortfolioUseCase useCase;

  CreatePortfolioController({required this.useCase})
    : super(const PortfolioState());

  Future<void> createPortfolio(CreatePortfolioInput input) async {
    state = state.copyWith(isLoading: true, isSuccess: false, error: null);

    final result = await useCase.execute(input);

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
