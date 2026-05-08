import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';

import 'package:runway/features/portfolio/usecase/get_portfolio_detail_usecase.dart';
import 'package:runway/features/portfolio/repository/get_portfolio_detail_repository.dart';
import 'package:runway/domain/entity/portfolio_detail.dart';
import 'package:runway/core/error/failure.dart';

class MockGetPortfolioDetailRepository extends Mock
    implements GetPortfolioDetailRepository {}

void main() {
  late GetPortfolioDetailUseCase usecase;
  late MockGetPortfolioDetailRepository mockRepository;

  PortfolioDetail createDummyDetail(String name) {
    final goal = Goal(
      investmentPeriodMonths: 240,
      targetPortfolioValue: 1000000000,
      targetMonthlyDividend: 5000000,
    );

    final asset = Asset(
      name: 'Test Asset',
      type: 'INDEX',
      initialPrice: 100.0,
      expectedAnnualPriceGrowthRate: 0.1,
      initialInvestmentAmount: 1000000,
      monthlyContributionAmount: 100000,
      isDividendAsset: true,
      dividendPerShare: 2.0,
      expectedAnnualDividendGrowthRate: 0.05,
      dividendFrequency: 4,
      isReinvestDividends: true,
    );

    final percentiles = Percentiles(
      portfolioValue: Percentile(
        p10: 800000000,
        p50: 1000000000,
        p90: 1200000000,
      ),
      monthlyDividend: Percentile(p10: 4000000, p50: 5000000, p90: 6000000),
    );

    final goalAnalysis = GoalAnalysis(
      portfolioValueGoal: GoalTarget(
        target: 1000000000,
        achievementProbability: 0.75,
        expectedMonthsToTarget: 240,
      ),
      monthlyDividendGoal: GoalTarget(
        target: 5000000,
        achievementProbability: 0.6,
        expectedMonthsToTarget: 240,
      ),
    );

    return PortfolioDetail(
      name: name,
      simulationInput: SimulationInput(goal: goal, assets: [asset]),
      simulationResult: SimulationResult(
        percentiles: percentiles,
        goalAnalysis: goalAnalysis,
      ),
    );
  }

  setUp(() {
    mockRepository = MockGetPortfolioDetailRepository();
    usecase = GetPortfolioDetailUseCase(mockRepository);
  });

  group('GetPortfolioDetailUseCase', () {
    const portfolioId = 'portfolio_1';
    const portfolioSnapshotId = 'portfolio_snapshot_1';

    test('성공 케이스: repository 결과 그대로 반환', () async {
      final dummyDetail = createDummyDetail(portfolioId);

      when(
        () => mockRepository.getPortfolioDetail(portfolioId),
      ).thenAnswer((_) async => Right(dummyDetail));

      final result = await usecase.execute(portfolioId: portfolioId);

      verify(() => mockRepository.getPortfolioDetail(portfolioId)).called(1);

      expect(result.isRight(), true);

      result.fold((_) => fail('Right가 와야 함'), (detail) {
        expect(detail.name, portfolioId);
        expect(detail.simulationInput.goal.targetPortfolioValue, 1000000000);
        expect(detail.simulationInput.assets.length, 1);
        expect(
          detail.simulationResult.percentiles.portfolioValue.p50,
          1000000000,
        );
      });
    });

    test('실패 케이스: repository Failure 그대로 반환', () async {
      const errorMsg = 'server error';

      when(
        () => mockRepository.getPortfolioDetail(portfolioId),
      ).thenAnswer((_) async => Left(ServerFailure(errorMsg)));

      final result = await usecase.execute(portfolioId: portfolioId);

      expect(result.isLeft(), true);

      result.fold(
        (failure) => expect(failure.message, errorMsg),
        (_) => fail('Left가 와야 함'),
      );
    });

    test('성공 케이스(snapshot): repository 결과 그대로 반환', () async {
      final dummyDetail = createDummyDetail(portfolioSnapshotId);

      when(
        () => mockRepository.getPortfolioSnapshotDetail(portfolioSnapshotId),
      ).thenAnswer((_) async => Right(dummyDetail));

      final result = await usecase.executeBySnapshotId(
        portfolioSnapshotId: portfolioSnapshotId,
      );

      verify(
        () => mockRepository.getPortfolioSnapshotDetail(portfolioSnapshotId),
      ).called(1);

      expect(result.isRight(), true);

      result.fold((_) => fail('Right가 와야 함'), (detail) {
        expect(detail.name, portfolioSnapshotId);
      });
    });

    test('실패 케이스(snapshot): repository Failure 그대로 반환', () async {
      const errorMsg = 'server error';

      when(
        () => mockRepository.getPortfolioSnapshotDetail(portfolioSnapshotId),
      ).thenAnswer((_) async => Left(ServerFailure(errorMsg)));

      final result = await usecase.executeBySnapshotId(
        portfolioSnapshotId: portfolioSnapshotId,
      );

      expect(result.isLeft(), true);

      result.fold(
        (failure) => expect(failure.message, errorMsg),
        (_) => fail('Left가 와야 함'),
      );
    });
  });
}
