import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:runway/features/simulation/usecase/simulation_usecase.dart';
import 'package:runway/features/simulation/repository/simulation_repository.dart';
import 'package:runway/features/simulation/types/simulation_request_dto.dart';
import 'package:runway/features/simulation/types/simulation_response_dto.dart';

class _MockSimulationRepository extends Mock implements SimulationRepository {}

SimulationResponseDto _buildResponse() {
  return SimulationResponseDto(
    percentiles: SimulationPercentilesDto(
      portfolioValue: SimulationPercentileValueDto(p10: 1, p50: 2, p90: 3),
      monthlyDividend: SimulationPercentileValueDto(p10: 4, p50: 5, p90: 6),
    ),
    goalAnalysis: SimulationGoalAnalysisDto(
      portfolioValueGoal: SimulationGoalMetricDto(expectedMonthsToTarget: 10),
      monthlyDividendGoal: SimulationGoalMetricDto(expectedMonthsToTarget: 20),
    ),
  );
}

void main() {
  late SimulationUseCase useCase;
  late _MockSimulationRepository repository;

  GoalAnalysisSimulationRequestDto _buildValidRequest() {
    return GoalAnalysisSimulationRequestDto(
      goal: SimulationGoalDto(
        investmentPeriodMonths: 12,
        targetPortfolioValue: 1000000,
        targetMonthlyDividend: 100000,
      ),
      assets: [
        AssetInputDto(
          assetName: 'TEST',
          assetType: 'STOCK',
          initialPrice: 10000,
          expectedAnnualPriceGrowthRate: 5,
          initialInvestmentAmount: 100000,
          monthlyContributionAmount: 0,
          isDividendAsset: false,
          dividendPerShare: 0,
          expectedAnnualDividendGrowthRate: 0,
          dividendFrequency: 0,
          isReinvestDividends: false,
        ),
      ],
    );
  }

  setUpAll(() {
    registerFallbackValue(
      GoalAnalysisSimulationRequestDto(
        goal: SimulationGoalDto(
          investmentPeriodMonths: 1,
          targetPortfolioValue: 1,
          targetMonthlyDividend: 0,
        ),
        assets: const [],
      ),
    );
  });

  setUp(() {
    repository = _MockSimulationRepository();
    useCase = SimulationUseCase(repository);
  });

  group('SimulationUseCase.validateSimulationInput', () {
    test('periodMonths <= 0 이면 Exception', () {
      final invalid = GoalAnalysisSimulationRequestDto(
        goal: SimulationGoalDto(
          investmentPeriodMonths: 0,
          targetPortfolioValue: 1000000,
          targetMonthlyDividend: 100000,
        ),
        assets: _buildValidRequest().assets,
      );

      expect(
        () => useCase.validateSimulationInput(request: invalid),
        throwsA(isA<Exception>()),
      );
    });

    test('assets 비어 있으면 Exception', () {
      final invalid = GoalAnalysisSimulationRequestDto(
        goal: _buildValidRequest().goal,
        assets: const [],
      );

      expect(
        () => useCase.validateSimulationInput(request: invalid),
        throwsA(isA<Exception>()),
      );
    });

    test('배당 자산인데 dividendFrequency <= 0 이면 Exception', () {
      final invalid = GoalAnalysisSimulationRequestDto(
        goal: _buildValidRequest().goal,
        assets: [
          AssetInputDto(
            assetName: 'DIV',
            assetType: 'STOCK',
            initialPrice: 10000,
            expectedAnnualPriceGrowthRate: 5,
            initialInvestmentAmount: 100000,
            monthlyContributionAmount: 0,
            isDividendAsset: true,
            dividendPerShare: 100,
            expectedAnnualDividendGrowthRate: 3,
            dividendFrequency: 0,
            isReinvestDividends: false,
          ),
        ],
      );

      expect(
        () => useCase.validateSimulationInput(request: invalid),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('SimulationUseCase.execute', () {
    test('유효한 request이면 repository.runMonteCarlo 호출', () async {
      final request = _buildValidRequest();

      when(
        () => repository.runMonteCarlo(any<GoalAnalysisSimulationRequestDto>()),
      ).thenAnswer((_) async => _buildResponse());

      final result = await useCase.execute(request: request);

      expect(result.percentiles.portfolioValue.p50, 2);

      verify(() => repository.runMonteCarlo(request)).called(1);
    });
  });
}
