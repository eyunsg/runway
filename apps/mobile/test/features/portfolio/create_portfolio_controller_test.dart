import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';

import 'package:runway/features/portfolio/controller/create_portfolio_controller.dart';
import 'package:runway/features/portfolio/usecase/create_portfolio_usecase.dart';
import 'package:runway/features/portfolio/types/create_portfolio_state.dart';
import 'package:runway/features/portfolio/model/create_portfolio_input.dart';

import 'package:runway/core/error/failure.dart';
import 'package:runway/core/error/validation_failure.dart';

class MockCreatePortfolioUseCase extends Mock
    implements CreatePortfolioUseCase {}

class CreatePortfolioInputFake extends Fake implements CreatePortfolioInput {}

void main() {
  late CreatePortfolioController controller;
  late MockCreatePortfolioUseCase mockUseCase;

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
    mockUseCase = MockCreatePortfolioUseCase();
    controller = CreatePortfolioController(useCase: mockUseCase);
  });

  group('createPortfolio', () {
    test('성공 시 loading → success 상태로 변경된다', () async {
      when(
        () => mockUseCase.execute(any<CreatePortfolioInput>()),
      ).thenAnswer((_) async => const Right(null));

      final states = <PortfolioState>[];
      controller.addListener(states.add);

      await controller.createPortfolio(dummyInput);

      verify(() => mockUseCase.execute(dummyInput)).called(1);

      expect(states.length, 3);
      expect(states[0].isLoading, false);
      expect(states[1].isLoading, true);
      expect(states[1].isSuccess, false);
      expect(states[2].isLoading, false);
      expect(states[2].isSuccess, true);
      expect(states[2].error, isNull);
    });

    test('EmptyAssetsFailure → 에러 메시지 반환', () async {
      when(
        () => mockUseCase.execute(any<CreatePortfolioInput>()),
      ).thenAnswer((_) async => Left(EmptyAssetsFailure('Empty assets error')));

      final states = <PortfolioState>[];
      controller.addListener(states.add);

      await controller.createPortfolio(dummyInput);

      expect(states.length, 3);
      expect(states[2].isSuccess, false);
      expect(states[2].error, '자산을 최소 1개 이상 추가해야 합니다.');
    });

    test('InvalidAssetFailure → 에러 메시지 반환', () async {
      when(() => mockUseCase.execute(any<CreatePortfolioInput>())).thenAnswer(
        (_) async =>
            Left(InvalidAssetFailure('Dividend asset fields are missing')),
      );

      final states = <PortfolioState>[];
      controller.addListener(states.add);

      await controller.createPortfolio(dummyInput);

      expect(states[2].isSuccess, false);
      expect(states[2].error, '배당 자산 정보가 올바르지 않습니다.');
    });

    test('AuthFailure → 에러 메시지 반환', () async {
      when(
        () => mockUseCase.execute(any<CreatePortfolioInput>()),
      ).thenAnswer((_) async => Left(AuthFailure('auth error')));

      final states = <PortfolioState>[];
      controller.addListener(states.add);

      await controller.createPortfolio(dummyInput);

      expect(states[2].error, '로그인이 필요합니다.');
    });

    test('NetworkFailure → 에러 메시지 반환', () async {
      when(
        () => mockUseCase.execute(any<CreatePortfolioInput>()),
      ).thenAnswer((_) async => Left(NetworkFailure('network error')));

      final states = <PortfolioState>[];
      controller.addListener(states.add);

      await controller.createPortfolio(dummyInput);

      expect(states[2].error, '네트워크 오류가 발생했습니다.');
    });

    test('ServerFailure → 에러 메시지 반환', () async {
      when(
        () => mockUseCase.execute(any<CreatePortfolioInput>()),
      ).thenAnswer((_) async => Left(ServerFailure('server error')));

      final states = <PortfolioState>[];
      controller.addListener(states.add);

      await controller.createPortfolio(dummyInput);

      expect(states[2].error, 'server error');
    });

    test('UnknownFailure → 기본 메시지 반환', () async {
      when(
        () => mockUseCase.execute(any<CreatePortfolioInput>()),
      ).thenAnswer((_) async => Left(UnknownFailure('unknown')));

      final states = <PortfolioState>[];
      controller.addListener(states.add);

      await controller.createPortfolio(dummyInput);

      expect(states[2].error, '알 수 없는 오류가 발생했습니다.');
    });
  });
}
