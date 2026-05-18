import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';

import 'package:runway/features/portfolio/controller/get_recent_portfolio_controller.dart';
import 'package:runway/features/portfolio/usecase/get_recent_portfolio_usecase.dart';
import 'package:runway/features/portfolio/types/get_recent_portfolio_state.dart';

import 'package:runway/core/error/failure.dart';
import 'package:runway/domain/entity/portfolio.dart';

class MockGetRecentPortfolioUseCase extends Mock
    implements GetRecentPortfolioUseCase {}

void main() {
  late GetRecentPortfolioController controller;
  late MockGetRecentPortfolioUseCase mockUseCase;

  final dummyPortfolio = Portfolio(
    id: 'portfolio-id',
    name: '테스트 포트폴리오',
    assetCount: 1,
    periodMonths: 120,
    updatedAt: DateTime(2024, 1, 1),
  );

  setUp(() {
    mockUseCase = MockGetRecentPortfolioUseCase();

    controller = GetRecentPortfolioController(useCase: mockUseCase);
  });

  group('fetchRecentPortfolio', () {
    test('성공 시 loading → success 상태 + portfolio 세팅', () async {
      when(
        () => mockUseCase.execute(),
      ).thenAnswer((_) async => Right(dummyPortfolio));

      final states = <GetRecentPortfolioState>[];

      controller.addListener((state) {
        states.add(state);
      });

      await controller.fetchRecentPortfolio();

      verify(() => mockUseCase.execute()).called(1);

      expect(states.length, 3);

      expect(states[0].isLoading, false);

      expect(states[1].isLoading, true);
      expect(states[1].portfolio, isNull);

      expect(states[2].isLoading, false);
      expect(states[2].portfolio, dummyPortfolio);
      expect(states[2].error, isNull);
    });

    test('실패 시 error 세팅', () async {
      when(
        () => mockUseCase.execute(),
      ).thenAnswer((_) async => Left(ServerFailure('server error')));

      final states = <GetRecentPortfolioState>[];

      controller.addListener((state) {
        states.add(state);
      });

      await controller.fetchRecentPortfolio();

      expect(states.length, 3);

      expect(states[0].isLoading, false);

      expect(states[1].isLoading, true);

      expect(states[2].isLoading, false);
      expect(states[2].error, 'server error');
    });
  });
}
