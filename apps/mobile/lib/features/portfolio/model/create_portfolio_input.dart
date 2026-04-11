import 'package:runway/features/simulation/types/simulation_request_dto.dart'
    as simulation_request;
import 'package:runway/features/simulation/types/simulation_response_dto.dart'
    as simulation_response;

class CreatePortfolioInput {
  final String name;

  final SimulationInput simulationInput;
  final SimulationResult simulationResult;

  CreatePortfolioInput({
    required this.name,
    required this.simulationInput,
    required this.simulationResult,
  });

  factory CreatePortfolioInput.fromSimulation({
    required String name,
    required simulation_request.GoalAnalysisSimulationRequestDto request,
    required simulation_response.SimulationResponseDto response,
  }) {
    return CreatePortfolioInput(
      name: name,
      simulationInput: SimulationInput(
        goal: GoalInput(
          investmentPeriodMonths: request.goal.investmentPeriodMonths,
          targetPortfolioValue: request.goal.targetPortfolioValue,
          targetMonthlyDividend: request.goal.targetMonthlyDividend,
        ),
        assets: request.assets
            .map(
              (asset) => AssetInput(
                assetName: asset.assetName,
                assetType: asset.assetType,
                initialPrice: asset.initialPrice,
                expectedAnnualPriceGrowthRate:
                    asset.expectedAnnualPriceGrowthRate,
                initialInvestmentAmount: asset.initialInvestmentAmount,
                monthlyContributionAmount: asset.monthlyContributionAmount,
                isDividendAsset: asset.isDividendAsset,
                dividendPerShare: asset.dividendPerShare,
                expectedAnnualDividendGrowthRate:
                    asset.expectedAnnualDividendGrowthRate,
                dividendFrequency: asset.dividendFrequency,
                isReinvestDividends: asset.isReinvestDividends,
              ),
            )
            .toList(),
      ),
      simulationResult: SimulationResult(
        percentiles: PercentilesInput(
          portfolioValue: PortfolioValueInput(
            p10: response.percentiles.portfolioValue.p10,
            p50: response.percentiles.portfolioValue.p50,
            p90: response.percentiles.portfolioValue.p90,
          ),
          monthlyDividend: MonthlyDividendInput(
            p10: response.percentiles.monthlyDividend.p10,
            p50: response.percentiles.monthlyDividend.p50,
            p90: response.percentiles.monthlyDividend.p90,
          ),
        ),
        goalAnalysis: GoalAnalysisInput(
          portfolioValueGoal: PortfolioValueGoalInput(
            expectedMonthsToTarget:
                response.goalAnalysis.portfolioValueGoal.expectedMonthsToTarget,
          ),
          monthlyDividendGoal: MonthlyDividendGoalInput(
            expectedMonthsToTarget: response
                .goalAnalysis
                .monthlyDividendGoal
                .expectedMonthsToTarget,
          ),
        ),
      ),
    );
  }
}

class SimulationInput {
  final GoalInput goal;
  final List<AssetInput> assets;

  SimulationInput({required this.goal, required this.assets});
}

class GoalInput {
  final int investmentPeriodMonths;
  final num targetPortfolioValue;
  final num targetMonthlyDividend;

  GoalInput({
    required this.investmentPeriodMonths,
    required this.targetPortfolioValue,
    required this.targetMonthlyDividend,
  });
}

class AssetInput {
  final String assetName;
  final String assetType;
  final num initialPrice;
  final num expectedAnnualPriceGrowthRate;
  final num initialInvestmentAmount;
  final num monthlyContributionAmount;
  final bool isDividendAsset;

  final num? dividendPerShare;
  final num? expectedAnnualDividendGrowthRate;
  final int? dividendFrequency;
  final bool? isReinvestDividends;

  AssetInput({
    required this.assetName,
    required this.assetType,
    required this.initialPrice,
    required this.expectedAnnualPriceGrowthRate,
    required this.initialInvestmentAmount,
    required this.monthlyContributionAmount,
    required this.isDividendAsset,
    this.dividendPerShare,
    this.expectedAnnualDividendGrowthRate,
    this.dividendFrequency,
    this.isReinvestDividends,
  });
}

class SimulationResult {
  final PercentilesInput percentiles;
  final GoalAnalysisInput goalAnalysis;

  SimulationResult({required this.percentiles, required this.goalAnalysis});
}

class PercentilesInput {
  final PortfolioValueInput portfolioValue;
  final MonthlyDividendInput monthlyDividend;

  PercentilesInput({
    required this.portfolioValue,
    required this.monthlyDividend,
  });
}

class PortfolioValueInput {
  final num p10;
  final num p50;
  final num p90;

  PortfolioValueInput({
    required this.p10,
    required this.p50,
    required this.p90,
  });
}

class MonthlyDividendInput {
  final num p10;
  final num p50;
  final num p90;

  MonthlyDividendInput({
    required this.p10,
    required this.p50,
    required this.p90,
  });
}

class GoalAnalysisInput {
  final PortfolioValueGoalInput portfolioValueGoal;
  final MonthlyDividendGoalInput monthlyDividendGoal;

  GoalAnalysisInput({
    required this.portfolioValueGoal,
    required this.monthlyDividendGoal,
  });
}

class PortfolioValueGoalInput {
  final int? expectedMonthsToTarget;

  PortfolioValueGoalInput({required this.expectedMonthsToTarget});
}

class MonthlyDividendGoalInput {
  final int? expectedMonthsToTarget;

  MonthlyDividendGoalInput({required this.expectedMonthsToTarget});
}
