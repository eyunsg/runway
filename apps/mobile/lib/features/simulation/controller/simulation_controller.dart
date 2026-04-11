import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../usecase/simulation_usecase.dart';
import '../types/simulation_state.dart';
import '../types/simulation_request_dto.dart';

class SimulationController extends StateNotifier<SimulationState> {
  final SimulationUseCase useCase;

  SimulationController({required this.useCase})
    : super(const SimulationState());

  // dropdown 값 -> 배당 주기 숫자 매핑
  int _mapDividendFrequency(dynamic value) {
    final raw = (value ?? '').toString().trim();

    switch (raw) {
      case '월':
      case '매월':
      case 'MONTHLY':
      case 'monthly':
      case '12':
        return 12;

      case '분기':
      case '분기별':
      case 'QUARTERLY':
      case 'quarterly':
      case '4':
        return 4;

      default:
        return 0;
    }
  }

  Future<void> runSimulation({
    required int periodMonths,
    required double targetValue,
    required double targetDividend,
    required List<Map<String, dynamic>> assets,
  }) async {
    try {
      state = state.copyWith(isLoading: true, isSuccess: false, error: null);

      // Request DTO 생성
      final request = GoalAnalysisSimulationRequestDto(
        goal: SimulationGoalDto(
          investmentPeriodMonths: periodMonths,
          targetPortfolioValue: targetValue,
          targetMonthlyDividend: targetDividend,
        ),
        assets: assets.map((asset) {
          return AssetInputDto(
            assetName: (asset['assetName'] ?? '').toString(),
            assetType: (asset['assetType'] ?? '').toString(),
            initialPrice: (asset['price'] as num?)?.toDouble() ?? 0.0,
            expectedAnnualPriceGrowthRate:
                (asset['yield'] as num?)?.toDouble() ?? 0.0,
            initialInvestmentAmount:
                (asset['amount'] as num?)?.toDouble() ?? 0.0,
            monthlyContributionAmount:
                (asset['monthlyContributionAmount'] as num?)?.toDouble() ?? 0.0,
            isDividendAsset: asset['isDividendAsset'] == true,
            dividendPerShare:
                (asset['dividendAmount'] as num?)?.toDouble() ?? 0.0,
            expectedAnnualDividendGrowthRate:
                (asset['dividendGrowth'] as num?)?.toDouble() ?? 0.0,
            dividendFrequency: _mapDividendFrequency(
              asset['dividendPeriod'] ?? asset['dividendFrequency'],
            ),
            isReinvestDividends: asset['isDividendReinvest'] == true,
          );
        }).toList(),
      );

      // UseCase에 DTO 전달
      final result = await useCase.execute(request: request);

      state = state.copyWith(
        isLoading: false,
        isSuccess: true,
        error: null,
        resultData: result,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isSuccess: false,
        error: e.toString(),
      );
    }
  }

  bool validateCanAddAsset(int currentCount) {
    try {
      useCase.validateCanAddAsset(currentCount);
      state = state.copyWith(error: null);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  bool validateCanDeleteAsset(int currentCount) {
    try {
      useCase.validateCanDeleteAsset(currentCount);
      state = state.copyWith(error: null);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  double resolveMonthlyVolatility(String assetType) {
    return useCase.resolveMonthlyVolatility(assetType);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void resetStatus() {
    state = const SimulationState();
  }
}
