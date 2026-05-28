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
    if (state.isLoading) return;

    state = state.copyWith(
      isLoading: true,
      isSuccess: false,
      clearError: true,
      portfolioDetail: null,
    );

    final result = await useCase.execute(portfolioId: portfolioId);

    result.fold(
      (failure) {
        final message = failure.toMessage();

        if (state.error == message) {
          state = state.copyWith(isLoading: false);
          return;
        }

        state = state.copyWith(isLoading: false, error: message);
      },
      (portfolioDetail) {
        if (state.portfolioDetail == portfolioDetail) {
          state = state.copyWith(isLoading: false);
          return;
        }

        state = state.copyWith(
          isLoading: false,
          isSuccess: true,
          portfolioDetail: portfolioDetail,
        );
      },
    );
  }

  Future<void> getPortfolioSnapshotDetail(String portfolioSnapshotId) async {
    if (state.isLoading) return;

    state = state.copyWith(
      isLoading: true,
      isSuccess: false,
      clearError: true,
      portfolioDetail: null,
    );

    final result = await useCase.executeBySnapshotId(
      portfolioSnapshotId: portfolioSnapshotId,
    );

    result.fold(
      (failure) {
        final message = failure.toMessage();

        if (state.error == message) {
          state = state.copyWith(isLoading: false);
          return;
        }

        state = state.copyWith(isLoading: false, error: message);
      },
      (portfolioDetail) {
        if (state.portfolioDetail == portfolioDetail) {
          state = state.copyWith(isLoading: false);
          return;
        }

        state = state.copyWith(
          isLoading: false,
          isSuccess: true,
          portfolioDetail: portfolioDetail,
        );
      },
    );
  }
}
