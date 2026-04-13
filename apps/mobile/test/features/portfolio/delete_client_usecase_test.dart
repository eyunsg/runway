import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:runway/core/error/failure.dart';
import 'package:runway/features/portfolio/repository/delete_portfolio_repository.dart';
import 'package:runway/features/portfolio/usecase/delete_portfolio_usecase.dart';

class MockDeletePortfolioRepository extends Mock
    implements DeletePortfolioRepository {}

void main() {
  late DeletePortfolioUsecase usecase;
  late MockDeletePortfolioRepository mockRepository;

  const testPortfolioId = 'test-id';

  setUp(() {
    mockRepository = MockDeletePortfolioRepository();
    usecase = DeletePortfolioUsecase(repository: mockRepository);
  });

  group('DeletePortfolioUsecase', () {
    test('성공 케이스: repository 결과를 그대로 반환', () async {
      when(
        () => mockRepository.deletePortfolio(testPortfolioId),
      ).thenAnswer((_) async => const Right(null));

      final result = await usecase.execute(testPortfolioId);

      verify(() => mockRepository.deletePortfolio(testPortfolioId)).called(1);
      expect(result.isRight(), true);
    });

    test('실패 케이스: repository Failure를 그대로 반환', () async {
      const errorMsg = 'server error';

      when(
        () => mockRepository.deletePortfolio(testPortfolioId),
      ).thenAnswer((_) async => Left(ServerFailure(errorMsg)));

      final result = await usecase.execute(testPortfolioId);

      verify(() => mockRepository.deletePortfolio(testPortfolioId)).called(1);

      expect(result.isLeft(), true);

      result.fold(
        (failure) => expect(failure.message, errorMsg),
        (_) => fail('Left가 와야 함'),
      );
    });
  });
}
