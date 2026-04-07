import 'package:runway/features/simulation/repository/simulation_repository.dart';
import 'package:runway/features/simulation/types/simulation_request_dto.dart';

class SimulationUseCase {
  final SimulationRepository repository;

  SimulationUseCase(this.repository);

  Future<dynamic> execute({
    required GoalAnalysisSimulationRequestDto request,
  }) async {
    // DTO 기준으로 검증
    validateSimulationInput(request: request);

    // Repository에 DTO 전달
    return await repository.runMonteCarlo(request);
  }

  void validateSimulationInput({
    required GoalAnalysisSimulationRequestDto request,
  }) {
    final periodMonths = request.goal.investmentPeriodMonths;
    final targetValue = request.goal.targetPortfolioValue;
    final targetDividend = request.goal.targetMonthlyDividend;
    final assets = request.assets;

    if (periodMonths <= 0) {
      throw Exception('투자 기간은 최소 1개월 이상이어야 합니다.');
    }

    if (targetValue <= 0) {
      throw Exception('목표 평가금은 0보다 커야 합니다.');
    }

    if (targetDividend < 0) {
      throw Exception('목표 배당금은 0 이상이어야 합니다.');
    }

    if (assets.isEmpty) {
      throw Exception('최소 1개 이상의 자산이 필요합니다.');
    }

    for (final asset in assets) {
      final assetName = asset.assetName.trim();
      final assetType = asset.assetType.trim();
      final price = asset.initialPrice;
      final amount = asset.initialInvestmentAmount;
      final yieldValue = asset.expectedAnnualPriceGrowthRate;
      final isDividendAsset = asset.isDividendAsset;

      if (assetName.isEmpty) {
        throw Exception('자산명을 입력해주세요.');
      }

      if (assetType.isEmpty) {
        throw Exception('자산 타입을 선택해주세요.');
      }

      if (price <= 0) {
        throw Exception('자산 가격은 0보다 커야 합니다.');
      }

      if (amount <= 0) {
        throw Exception('초기 투자금은 0보다 커야 합니다.');
      }

      if (yieldValue < 0) {
        throw Exception('연 성장률은 0 이상이어야 합니다.');
      }

      if (isDividendAsset) {
        final dividendAmount = asset.dividendPerShare;
        final dividendGrowth = asset.expectedAnnualDividendGrowthRate;
        final dividendFrequency = asset.dividendFrequency;

        if (dividendAmount <= 0) {
          throw Exception('배당 자산의 주당 배당금을 입력해주세요.');
        }

        if (dividendGrowth < 0) {
          throw Exception('배당 성장률은 0 이상이어야 합니다.');
        }

        if (dividendFrequency <= 0) {
          throw Exception('배당 주기를 선택해주세요.');
        }
      }
    }
  }

  void validateCanAddAsset(int currentCount) {
    if (currentCount >= 10) {
      throw Exception('자산은 최대 10개까지 추가할 수 있습니다.');
    }
  }

  void validateCanDeleteAsset(int currentCount) {
    if (currentCount <= 1) {
      throw Exception('최소 1개 이상의 자산은 유지해야 합니다.');
    }
  }

  double resolveMonthlyVolatility(String assetType) {
    const volatilityMap = {
      'STOCK': 8.0,
      'CRYPTO': 20.0,
      'INDEX': 3.5,
      'COMMODITY': 6.0,
      'GOLD': 2.0,
    };

    return volatilityMap[assetType] ?? 0.0;
  }
}
