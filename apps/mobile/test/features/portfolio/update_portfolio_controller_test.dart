import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:runway/core/error/failure.dart';
import 'package:runway/features/portfolio/controller/update_portfolio_controller.dart';
import 'package:runway/features/portfolio/model/create_portfolio_input.dart';
import 'package:runway/features/portfolio/types/create_portfolio_state.dart';
import 'package:runway/features/portfolio/usecase/update_portfolio_usecase.dart';

class MockUpdatePortfolioUseCase extends Mock
    implements UpdatePortfolioUseCase {}

class CreatePortfolioInputFake extends Fake implements CreatePortfolioInput {}

void main() {
  late UpdatePortfolioController controller;
  late MockUpdatePortfolioUseCase mockUseCase;

  final dummyInput = CreatePortfolioInput(
    name: '포트폴리오',
    simulationInput: SimulationInput(
      goal: GoalInput(
        investmentPeriodMonths: 120,
        targetPortfolioValue: 100000000,
        targetMonthlyDividend: 300000,
      ),
      assets: [
        AssetInput(
          assetName: 'SPY',
          assetType: 'ETF',
          initialPrice: 500,
          expectedAnnualPriceGrowthRate: 0.07,
          initialInvestmentAmount: 1000000,
          monthlyContributionAmount: 500000,
          isDividendAsset: true,
          dividendPerShare: 5,
          expectedAnnualDividendGrowthRate: 0.05,
          dividendFrequency: 'QUARTERLY',
          isReinvestDividends: true,
        ),
      ],
    ),
    simulationResult: SimulationResult(
      percentiles: PercentilesInput(
        portfolioValue: PortfolioValueInput(
          p10: 80000000,
          p50: 100000000,
          p90: 130000000,
        ),
        monthlyDividend: MonthlyDividendInput(
          p10: 200000,
          p50: 300000,
          p90: 400000,
        ),
      ),
      goalAnalysis: GoalAnalysisInput(
        portfolioValueGoal: PortfolioValueGoalInput(
          expectedMonthsToTarget: 100,
        ),
        monthlyDividendGoal: MonthlyDividendGoalInput(
          expectedMonthsToTarget: 90,
        ),
      ),
    ),
  );

  setUpAll(() {
    registerFallbackValue(CreatePortfolioInputFake());
  });

  setUp(() {
    mockUseCase = MockUpdatePortfolioUseCase();
    controller = UpdatePortfolioController(useCase: mockUseCase);
  });

  group('updatePortfolio', () {
    test('성공 시 loading -> success 상태로 변경된다', () async {
      when(
        () => mockUseCase.execute(any(), any<CreatePortfolioInput>()),
      ).thenAnswer((_) async => const Right(null));

      final states = <PortfolioState>[];
      controller.addListener(states.add);

      await controller.updatePortfolio('portfolio-id', dummyInput);

      verify(() => mockUseCase.execute('portfolio-id', dummyInput)).called(1);
      expect(states.length, 3);
      expect(states[1].isLoading, true);
      expect(states[2].isLoading, false);
      expect(states[2].isSuccess, true);
      expect(states[2].error, isNull);
    });

    test('ServerFailure -> 에러 메시지 반환', () async {
      when(
        () => mockUseCase.execute(any(), any<CreatePortfolioInput>()),
      ).thenAnswer((_) async => Left(ServerFailure('server error')));

      final states = <PortfolioState>[];
      controller.addListener(states.add);

      await controller.updatePortfolio('portfolio-id', dummyInput);

      expect(states[2].isSuccess, false);
      expect(states[2].error, '서버 오류가 발생했습니다.');
    });
  });
}
