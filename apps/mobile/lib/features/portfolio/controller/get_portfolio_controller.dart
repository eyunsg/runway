import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:runway/core/error/failure_extension.dart';
import 'package:runway/features/portfolio/types/get_portfolio_state.dart';
import 'package:runway/features/portfolio/usecase/get_portfolio_usecase.dart';

class GetPortfolioController extends StateNotifier<GetPortfolioState> {
  final GetPortfolioUseCase useCase;

  GetPortfolioController({required this.useCase})
    : super(const GetPortfolioState());

  // int _offset = 0;
  // final int _limit = 10;

  Future<void> fetchPortfolio() async {
    // _offset = 0;

    state = state.copyWith(
      isLoading: true,
      error: null,
      portfolios: [],
      hasMore: false,
    );

    // final result = await useCase.execute(limit: _limit, offset: _offset);
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
          // hasMore: list.length == _limit,
        );

        // _offset += _limit;
      },
    );
  }

  // Future<void> fetchMore() async {
  //   if (state.isLoading || !state.hasMore) return;

  //   state = state.copyWith(isLoading: true, error: null);

  //   final result = await useCase.execute(limit: _limit, offset: _offset);

  //   result.fold(
  //     (failure) {
  //       state = state.copyWith(isLoading: false, error: failure.toMessage());
  //     },
  //     (list) {
  //       state = state.copyWith(
  //         isLoading: false,
  //         portfolios: [...state.portfolios, ...list], // append
  //         hasMore: list.length == _limit,
  //       );

  //       _offset += _limit;
  //     },
  //   );
  // }
}
