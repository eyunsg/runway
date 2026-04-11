import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:runway/core/error/validation_failure.dart';
import 'package:runway/features/portfolio/dto/create_portfolio_request_dto.dart'
    as dto;
import 'package:runway/features/portfolio/model/create_portfolio_input.dart';
import 'package:runway/features/portfolio/repository/update_portfolio_repository.dart';
import 'package:runway/features/portfolio/usecase/update_portfolio_usecase.dart';

class MockUpdatePortfolioRepository extends Mock
    implements UpdatePortfolioRepository {}

class CreatePortfolioRequestDtoFake extends Fake
    implements dto.CreatePortfolioRequestDto {}

void main() {
  setUpAll(() {
    registerFallbackValue(CreatePortfolioRequestDtoFake());
  });

  late UpdatePortfolioUseCase usecase;
  late MockUpdatePortfolioRepository mockRepository;
  late CreatePortfolioInput validInput;

  setUp(() {
    mockRepository = MockUpdatePortfolioRepository();
    usecase = UpdatePortfolioUseCase(mockRepository);

    validInput = CreatePortfolioInput(
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
            dividendFrequency: 4,
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
  });

  group('UpdatePortfolioUseCase', () {
    test('성공 케이스: Repository가 Right(null)을 반환하면 그대로 반환', () async {
      when(
        () => mockRepository.updatePortfolio(any(), any()),
      ).thenAnswer((_) async => const Right(null));

      final result = await usecase.execute('portfolio-id', validInput);

      verify(
        () => mockRepository.updatePortfolio('portfolio-id', any()),
      ).called(1);
      expect(result.isRight(), true);
    });

    test('Validation 실패: 배당 자산 필드 누락 시 InvalidAssetFailure 반환', () async {
      final invalidInput = CreatePortfolioInput(
        name: '포트폴리오',
        simulationInput: SimulationInput(
          goal: validInput.simulationInput.goal,
          assets: [
            AssetInput(
              assetName: 'SPY',
              assetType: 'ETF',
              initialPrice: 500,
              expectedAnnualPriceGrowthRate: 0.07,
              initialInvestmentAmount: 1000000,
              monthlyContributionAmount: 500000,
              isDividendAsset: true,
              dividendPerShare: null,
              expectedAnnualDividendGrowthRate: null,
              dividendFrequency: null,
              isReinvestDividends: null,
            ),
          ],
        ),
        simulationResult: validInput.simulationResult,
      );

      final result = await usecase.execute('portfolio-id', invalidInput);

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<InvalidAssetFailure>()),
        (_) => fail('Left가 와야 함'),
      );
    });
  });
}
