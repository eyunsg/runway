import 'package:flutter_test/flutter_test.dart';
import 'package:runway/features/portfolio/model/create_portfolio_input.dart';
import 'package:runway/features/simulation/types/simulation_request_dto.dart';
import 'package:runway/features/simulation/types/simulation_response_dto.dart';

void main() {
  test('CreatePortfolioInput.fromSimulation은 시뮬레이션 요청/응답을 저장용 모델로 변환한다', () {
    final request = GoalAnalysisSimulationRequestDto(
      goal: SimulationGoalDto(
        investmentPeriodMonths: 120,
        targetPortfolioValue: 100000000,
        targetMonthlyDividend: 300000,
      ),
      assets: [
        AssetInputDto(
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
    );

    final response = SimulationResponseDto(
      percentiles: SimulationPercentilesDto(
        portfolioValue: SimulationPercentileValueDto(
          p10: 80000000,
          p50: 100000000,
          p90: 130000000,
        ),
        monthlyDividend: SimulationPercentileValueDto(
          p10: 200000,
          p50: 300000,
          p90: 400000,
        ),
      ),
      goalAnalysis: SimulationGoalAnalysisDto(
        portfolioValueGoal: SimulationGoalMetricDto(
          expectedMonthsToTarget: 100,
        ),
        monthlyDividendGoal: SimulationGoalMetricDto(
          expectedMonthsToTarget: null,
        ),
      ),
    );

    final result = CreatePortfolioInput.fromSimulation(
      name: '포트폴리오',
      request: request,
      response: response,
    );

    expect(result.name, '포트폴리오');
    expect(result.simulationInput.goal.investmentPeriodMonths, 120);
    expect(result.simulationInput.assets.first.dividendFrequency, 4);
    expect(result.simulationResult.percentiles.portfolioValue.p50, 100000000);
    expect(
      result
          .simulationResult
          .goalAnalysis
          .monthlyDividendGoal
          .expectedMonthsToTarget,
      isNull,
    );
  });
}
