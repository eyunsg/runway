import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';

import 'package:runway/features/portfolio/usecase/get_recent_portfolio_usecase.dart';
import 'package:runway/features/portfolio/repository/get_portfolio_repository.dart';

import 'package:runway/domain/entity/portfolio.dart';
import 'package:runway/core/error/failure.dart';

class MockGetPortfolioRepository extends Mock
    implements GetPortfolioRepository {}

void main() {
  late GetRecentPortfolioUseCase usecase;
  late MockGetPortfolioRepository mockRepository;

  final dummyPortfolio = Portfolio(
    id: 'portfolio-id',
    name: '테스트 포트폴리오',
    assetCount: 1,
    periodMonths: 120,
    updatedAt: DateTime(2024, 1, 1),
  );

  setUp(() {
    mockRepository = MockGetPortfolioRepository();

    usecase = GetRecentPortfolioUseCase(mockRepository);
  });

  group('GetRecentPortfolioUseCase', () {
    test('성공 케이스: repository 결과 그대로 반환', () async {
      when(
        () => mockRepository.getRecentPortfolio(),
      ).thenAnswer((_) async => Right(dummyPortfolio));

      final result = await usecase.execute();

      verify(() => mockRepository.getRecentPortfolio()).called(1);

      expect(result.isRight(), true);

      result.fold((_) => fail('Right가 와야 함'), (portfolio) {
        expect(portfolio, dummyPortfolio);
      });
    });

    test('실패 케이스: repository Failure 그대로 반환', () async {
      const errorMsg = 'server error';

      when(
        () => mockRepository.getRecentPortfolio(),
      ).thenAnswer((_) async => Left(ServerFailure(errorMsg)));

      final result = await usecase.execute();

      expect(result.isLeft(), true);

      result.fold((failure) {
        expect(failure.message, errorMsg);
      }, (_) => fail('Left가 와야 함'));
    });
  });
}
