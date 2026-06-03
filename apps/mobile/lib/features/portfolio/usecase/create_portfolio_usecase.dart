import 'package:dartz/dartz.dart';
import 'package:runway/core/error/failure.dart';
import 'package:runway/core/error/validation_failure.dart';
import 'package:runway/features/portfolio/model/create_portfolio_input.dart';
import 'package:runway/features/portfolio/repository/create_portfolio_repository.dart';
import 'package:runway/features/portfolio/dto/create_portfolio_request_dto.dart'
    as dto;

class CreatePortfolioUseCase {
  final CreatePortfolioRepository repository;

  CreatePortfolioUseCase(this.repository);

  Future<Either<Failure, void>> execute(CreatePortfolioInput input) async {
    // 검증
    if (input.simulationInput.assets.isEmpty) {
      return Left(EmptyAssetsFailure('assets must not be empty'));
    }

    // 배당 자산 검증
    for (final asset in input.simulationInput.assets) {
      if (asset.isDividendAsset) {
        if (asset.dividendPerShare == null ||
            asset.expectedAnnualDividendGrowthRate == null ||
            asset.dividendFrequency == null ||
            asset.isReinvestDividends == null) {
          return const Left(
            InvalidAssetFailure('Dividend asset fields are missing'),
          );
        }

        if (_normalizeDividendFrequency(asset.dividendFrequency) == null) {
          return Left(
            InvalidAssetFailure('Dividend frequency must be 1, 2, 4, or 12'),
          );
        }
      }
    }

    // DTO 변환
    final dto = _toDto(input);

    // Repository 호출
    return await repository.createPortfolio(dto);
  }

  dto.CreatePortfolioRequestDto _toDto(CreatePortfolioInput input) {
    return dto.CreatePortfolioRequestDto(
      name: input.name,
      simulationInput: dto.SimulationInput(
        goal: dto.Goal(
          investmentPeriodMonths:
              input.simulationInput.goal.investmentPeriodMonths,
          targetPortfolioValue: input.simulationInput.goal.targetPortfolioValue,
          targetMonthlyDividend:
              input.simulationInput.goal.targetMonthlyDividend,
        ),
        assets: input.simulationInput.assets.map((a) {
          return dto.Asset(
            assetName: a.assetName,
            assetType: a.assetType,
            initialPrice: a.initialPrice,
            expectedAnnualPriceGrowthRate: a.expectedAnnualPriceGrowthRate,
            initialInvestmentAmount: a.initialInvestmentAmount,
            monthlyContributionAmount: a.monthlyContributionAmount,
            isDividendAsset: a.isDividendAsset,
            dividendPerShare: a.dividendPerShare,
            expectedAnnualDividendGrowthRate:
                a.expectedAnnualDividendGrowthRate,
            dividendFrequency: _normalizeDividendFrequency(a.dividendFrequency),
            isReinvestDividends: a.isReinvestDividends,
          );
        }).toList(),
      ),
      simulationResult: dto.SimulationResult(
        percentiles: dto.Percentiles(
          portfolioValue: dto.PortfolioValue(
            p10: input.simulationResult.percentiles.portfolioValue.p10,
            p50: input.simulationResult.percentiles.portfolioValue.p50,
            p90: input.simulationResult.percentiles.portfolioValue.p90,
          ),
          monthlyDividend: dto.MonthlyDividend(
            p10: input.simulationResult.percentiles.monthlyDividend.p10,
            p50: input.simulationResult.percentiles.monthlyDividend.p50,
            p90: input.simulationResult.percentiles.monthlyDividend.p90,
          ),
        ),
        goalAnalysis: dto.GoalAnalysis(
          portfolioValueGoal: dto.PortfolioValueGoal(
            expectedMonthsToTarget: input
                .simulationResult
                .goalAnalysis
                .portfolioValueGoal
                .expectedMonthsToTarget,
          ),
          monthlyDividendGoal: dto.MonthlyDividendGoal(
            expectedMonthsToTarget: input
                .simulationResult
                .goalAnalysis
                .monthlyDividendGoal
                .expectedMonthsToTarget,
          ),
        ),
      ),
    );
  }

  int? _normalizeDividendFrequency(String? value) {
    final raw = (value ?? '').trim().toUpperCase();

    switch (raw) {
      case '12':
      case 'MONTHLY':
      case '매월':
      case '월':
        return 12;

      case '4':
      case 'QUARTERLY':
      case '분기':
      case '분기별':
        return 4;

      case '2':
      case 'BIANNUAL':
      case 'BIMONTHLY':
        return 2;

      case '1':
      case 'ANNUAL':
      case 'YEARLY':
      case '연간':
      case '매년':
        return 1;

      default:
        return null;
    }
  }
}
