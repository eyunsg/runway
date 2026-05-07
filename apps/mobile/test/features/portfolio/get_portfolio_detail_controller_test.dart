import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';

import 'package:runway/features/portfolio/controller/get_portfolio_detail_controller.dart';
import 'package:runway/features/portfolio/usecase/get_portfolio_detail_usecase.dart';
import 'package:runway/features/portfolio/types/get_portfolio_detail_state.dart';
import 'package:runway/domain/entity/portfolio_detail.dart';
import 'package:runway/core/error/failure.dart';

class MockGetPortfolioDetailUseCase extends Mock
    implements GetPortfolioDetailUseCase {}

void main() {
  late GetPortfolioDetailController controller;
  late MockGetPortfolioDetailUseCase mockUseCase;

  PortfolioDetail createDummyDetail() {
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
        achievementProbability: 0.7,
        expectedMonthsToTarget: 240,
      ),
      monthlyDividendGoal: GoalTarget(
        target: 5000000,
        achievementProbability: 0.6,
        expectedMonthsToTarget: 240,
      ),
    );

    return PortfolioDetail(
      name: 'portfolio_1',
      simulationInput: SimulationInput(goal: goal, assets: [asset]),
      simulationResult: SimulationResult(
        percentiles: percentiles,
        goalAnalysis: goalAnalysis,
      ),
    );
  }

  setUp(() {
    mockUseCase = MockGetPortfolioDetailUseCase();
    controller = GetPortfolioDetailController(useCase: mockUseCase);
  });

  group('getPortfolioDetail', () {
    const portfolioId = 'portfolio_1';

    test('성공 시 loading → success 상태 + 데이터 세팅', () async {
      final dummyDetail = createDummyDetail();

      when(
        () => mockUseCase.execute(portfolioId: portfolioId),
      ).thenAnswer((_) async => Right(dummyDetail));

      final states = <GetPortfolioDetailState>[];
      controller.addListener((state) => states.add(state));

      await controller.getPortfolioDetail(portfolioId);

      verify(() => mockUseCase.execute(portfolioId: portfolioId)).called(1);

      expect(states.length, 3);

      expect(states[0].isLoading, false);

      expect(states[1].isLoading, true);
      expect(states[1].isSuccess, false);
      expect(states[1].error, isNull);

      expect(states[2].isLoading, false);
      expect(states[2].isSuccess, true);
      expect(states[2].portfolioDetail, dummyDetail);
      expect(states[2].error, isNull);
    });

    test('실패 시 error 세팅', () async {
      when(
        () => mockUseCase.execute(portfolioId: portfolioId),
      ).thenAnswer((_) async => Left(ServerFailure('server error')));

      final states = <GetPortfolioDetailState>[];
      controller.addListener((state) => states.add(state));

      await controller.getPortfolioDetail(portfolioId);

      expect(states.length, 3);

      expect(states[0].isLoading, false);

      expect(states[1].isLoading, true);

      expect(states[2].isLoading, false);
      expect(states[2].isSuccess, false);
      expect(states[2].error, 'server error');
    });
  });
}
