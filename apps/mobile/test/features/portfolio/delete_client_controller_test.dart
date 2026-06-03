import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:runway/core/error/failure.dart';
import 'package:runway/features/portfolio/controller/delete_portfolio_controller.dart';
import 'package:runway/features/portfolio/types/delete_portfolio_state.dart';
import 'package:runway/features/portfolio/usecase/delete_portfolio_usecase.dart';

class MockDeletePortfolioUseCase extends Mock
    implements DeletePortfolioUsecase {}

void main() {
  late DeletePortfolioController controller;
  late MockDeletePortfolioUseCase mockUseCase;

  const testPortfolioId = 'test-id';

  setUp(() {
    mockUseCase = MockDeletePortfolioUseCase();
    controller = DeletePortfolioController(useCase: mockUseCase);
  });

  group('deletePortfolio', () {
    test('성공 시 loading → success 상태로 변경된다', () async {
      when(
        () => mockUseCase.execute(testPortfolioId),
      ).thenAnswer((_) async => const Right(null));

      final states = <DeletePortfolioState>[];
      controller.addListener(states.add);

      await controller.deletePortfolio(testPortfolioId);

      verify(() => mockUseCase.execute(testPortfolioId)).called(1);

      expect(states.length, 3);
      expect(states[0].isLoading, false);

      expect(states[1].isLoading, true);
      expect(states[1].isSuccess, false);

      expect(states[2].isLoading, false);
      expect(states[2].isSuccess, true);
      expect(states[2].error, isNull);
    });

    test('실패 시 error 세팅', () async {
      when(
        () => mockUseCase.execute(testPortfolioId),
      ).thenAnswer((_) async => Left(ServerFailure('server error')));

      final states = <DeletePortfolioState>[];
      controller.addListener(states.add);

      await controller.deletePortfolio(testPortfolioId);

      verify(() => mockUseCase.execute(testPortfolioId)).called(1);

      expect(states.length, 3);
      expect(states[0].isLoading, false);

      expect(states[1].isLoading, true);

      expect(states[2].isLoading, false);
      expect(states[2].isSuccess, false);
      expect(states[2].error, 'server error');
    });
  });
}
