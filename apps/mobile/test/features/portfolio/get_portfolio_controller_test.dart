import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';

import 'package:runway/features/portfolio/controller/get_portfolio_controller.dart';
import 'package:runway/features/portfolio/usecase/get_portfolio_usecase.dart';
import 'package:runway/features/portfolio/types/get_portfolio_state.dart';
import 'package:runway/core/error/failure.dart';
import 'package:runway/domain/entity/portfolio.dart';

class MockGetPortfolioUseCase extends Mock implements GetPortfolioUseCase {}

void main() {
  late GetPortfolioController controller;
  late MockGetPortfolioUseCase mockUseCase;

  Portfolio createDummyPortfolio(int i) {
    return Portfolio(
      id: i,
      name: 'portfolio_$i',
      assetCount: 1,
      periodMonths: 120,
      updatedAt: DateTime(2024, 1, 1),
    );
  }

  final dummyList = List.generate(10, (i) => createDummyPortfolio(i));

  setUp(() {
    mockUseCase = MockGetPortfolioUseCase();
    controller = GetPortfolioController(useCase: mockUseCase);
  });

  group('fetchPortfolio', () {
    test('성공 시 loading → success 상태 + 리스트 세팅', () async {
      when(
        () => mockUseCase.execute(),
      ).thenAnswer((_) async => Right(dummyList));

      final states = <GetPortfolioState>[];
      controller.addListener((state) => states.add(state));

      await controller.fetchPortfolio();

      verify(() => mockUseCase.execute()).called(1);

      expect(states.length, 3);

      expect(states[0].isLoading, false);

      expect(states[1].isLoading, true);
      expect(states[1].portfolios, []);

      expect(states[2].isLoading, false);
      expect(states[2].portfolios, dummyList);
      expect(states[2].error, isNull);
    });

    test('실패 시 error 세팅', () async {
      when(
        () => mockUseCase.execute(),
      ).thenAnswer((_) async => Left(ServerFailure('server error')));

      final states = <GetPortfolioState>[];
      controller.addListener((state) => states.add(state));

      await controller.fetchPortfolio();

      expect(states.length, 3);

      expect(states[0].isLoading, false);

      expect(states[1].isLoading, true);

      expect(states[2].isLoading, false);
      expect(states[2].error, '서버 오류가 발생했습니다.');
    });
  });
}
