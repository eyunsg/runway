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
        () => mockUseCase.execute(
          limit: any(named: 'limit'),
          offset: any(named: 'offset'),
        ),
      ).thenAnswer((_) async => Right(dummyList));

      final states = <GetPortfolioState>[];
      controller.addListener((state) => states.add(state));

      await controller.fetchPortfolio();

      verify(() => mockUseCase.execute(limit: 10, offset: 0)).called(1);

      expect(states.length, 3);

      // initial
      expect(states[0].isLoading, false);

      // loading
      expect(states[1].isLoading, true);
      expect(states[1].portfolios, []);

      // success
      expect(states[2].isLoading, false);
      expect(states[2].portfolios, dummyList);
      expect(states[2].hasMore, true);
      expect(states[2].error, isNull);
    });

    test('실패 시 error 세팅', () async {
      when(
        () => mockUseCase.execute(
          limit: any(named: 'limit'),
          offset: any(named: 'offset'),
        ),
      ).thenAnswer((_) async => Left(ServerFailure('server error')));

      final states = <GetPortfolioState>[];
      controller.addListener((state) => states.add(state));

      await controller.fetchPortfolio();

      expect(states.length, 3);

      // initial
      expect(states[0].isLoading, false);

      // loading
      expect(states[1].isLoading, true);

      // failure
      expect(states[2].isLoading, false);
      expect(states[2].error, '서버 오류가 발생했습니다.');
    });
  });

  group('fetchMore', () {
    test('append 정상 동작 + offset 증가', () async {
      // 1페이지
      when(
        () => mockUseCase.execute(limit: 10, offset: 0),
      ).thenAnswer((_) async => Right(dummyList));

      // 2페이지
      final nextList = List.generate(10, (i) => createDummyPortfolio(i + 10));

      when(
        () => mockUseCase.execute(limit: 10, offset: 10),
      ).thenAnswer((_) async => Right(nextList));

      await controller.fetchPortfolio();
      await controller.fetchMore();

      final state = controller.state;

      expect(state.portfolios.length, 20);
      expect(state.portfolios, [...dummyList, ...nextList]);
      expect(state.hasMore, true);
    });

    test('hasMore=false면 호출 안됨', () async {
      when(() => mockUseCase.execute(limit: 10, offset: 0)).thenAnswer(
        (_) async => Right(List.generate(5, (i) => createDummyPortfolio(i))),
      );

      await controller.fetchPortfolio();
      await controller.fetchMore();

      // 추가 호출 없음
      verify(() => mockUseCase.execute(limit: 10, offset: 0)).called(1);
    });

    test('isLoading=true면 호출 안됨', () async {
      when(
        () => mockUseCase.execute(limit: 10, offset: 0),
      ).thenAnswer((_) async => Right(dummyList));

      controller.state = controller.state.copyWith(isLoading: true);

      await controller.fetchMore();

      verifyNever(
        () => mockUseCase.execute(
          limit: any(named: 'limit'),
          offset: any(named: 'offset'),
        ),
      );
    });

    test('실패 시 error 세팅', () async {
      when(
        () => mockUseCase.execute(limit: 10, offset: 0),
      ).thenAnswer((_) async => Right(dummyList));

      when(
        () => mockUseCase.execute(limit: 10, offset: 10),
      ).thenAnswer((_) async => Left(NetworkFailure('network error')));

      await controller.fetchPortfolio();
      await controller.fetchMore();

      expect(controller.state.error, '네트워크 오류가 발생했습니다.');
    });
  });
}
