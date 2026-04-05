import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:runway/core/error/failure.dart';
import 'package:runway/core/error/validation_failure.dart';
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
        state = state.copyWith(
          isLoading: false,
          error: _mapFailureToMessage(failure),
        );
      },
      (_) {
        state = state.copyWith(isLoading: false, isSuccess: true);
      },
    );
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is EmptyAssetsFailure) {
      return '자산을 최소 1개 이상 추가해야 합니다.';
    }

    if (failure is InvalidAssetFailure) {
      return '배당 자산 정보가 올바르지 않습니다.';
    }

    if (failure is AuthFailure) {
      return '로그인이 필요합니다.';
    }

    if (failure is NetworkFailure) {
      return '네트워크 오류가 발생했습니다.';
    }

    if (failure is ServerFailure) {
      return '서버 오류가 발생했습니다.';
    }

    return '알 수 없는 오류가 발생했습니다.';
  }
}
