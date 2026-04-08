import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';

import 'package:runway/features/portfolio/usecase/get_portfolio_usecase.dart';
import 'package:runway/features/portfolio/repository/get_portfolio_repository.dart';
import 'package:runway/domain/entity/portfolio.dart';
import 'package:runway/core/error/failure.dart';

class MockGetPortfolioRepository extends Mock
    implements GetPortfolioRepository {}

void main() {
  late GetPortfolioUseCase usecase;
  late MockGetPortfolioRepository mockRepository;

  Portfolio createDummyPortfolio(int i) {
    return Portfolio(
      id: i,
      name: 'portfolio_$i',
      assetCount: 1,
      periodMonths: 120,
      updatedAt: DateTime(2024, 1, 1),
    );
  }

  setUp(() {
    mockRepository = MockGetPortfolioRepository();
    usecase = GetPortfolioUseCase(mockRepository);
  });

  group('GetPortfolioUseCase', () {
    test('성공 케이스: repository 결과 그대로 반환', () async {
      final dummyList = List.generate(10, createDummyPortfolio);

      when(
        () => mockRepository.getPortfolio(),
      ).thenAnswer((_) async => Right(dummyList));

      final result = await usecase.execute();

      verify(() => mockRepository.getPortfolio()).called(1);

      expect(result.isRight(), true);

      result.fold((_) => fail('Right가 와야 함'), (list) {
        expect(list.length, 10);
        expect(list, dummyList);
      });
    });

    test('실패 케이스: repository Failure 그대로 반환', () async {
      const errorMsg = 'server error';

      when(
        () => mockRepository.getPortfolio(),
      ).thenAnswer((_) async => Left(ServerFailure(errorMsg)));

      final result = await usecase.execute();

      expect(result.isLeft(), true);

      result.fold(
        (failure) => expect(failure.message, errorMsg),
        (_) => fail('Left가 와야 함'),
      );
    });
  });
}
