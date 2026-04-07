import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:runway/features/simulation/controller/simulation_controller.dart';
import 'package:runway/features/simulation/usecase/simulation_usecase.dart';
import 'package:runway/features/simulation/types/simulation_state.dart';
import 'package:runway/features/simulation/types/simulation_request_dto.dart';

class _MockSimulationUseCase extends Mock implements SimulationUseCase {}

void main() {
  late _MockSimulationUseCase useCase;
  late SimulationController controller;

  setUp(() {
    useCase = _MockSimulationUseCase();
    controller = SimulationController(useCase: useCase);

    registerFallbackValue(
      GoalAnalysisSimulationRequestDto(
        goal: SimulationGoalDto(
          investmentPeriodMonths: 12,
          targetPortfolioValue: 1000000,
          targetMonthlyDividend: 100000,
        ),
        assets: const [],
      ),
    );
  });

  group('SimulationController.runSimulation', () {
    test('성공 시 isLoading=false, isSuccess=true, resultData 설정', () async {
      when(
        () => useCase.execute(
          request: any<GoalAnalysisSimulationRequestDto>(named: 'request'),
        ),
      ).thenAnswer((_) async => {'result': 'ok'});

      final assets = <Map<String, dynamic>>[
        {
          'assetName': 'TEST',
          'assetType': 'STOCK',
          'price': 10000,
          'yield': 5,
          'amount': 100000,
          'monthlyContributionAmount': 0,
          'isDividendAsset': false,
          'dividendAmount': 0,
          'dividendGrowth': 0,
          'dividendPeriod': 'MONTHLY',
          'isDividendReinvest': false,
        },
      ];

      await controller.runSimulation(
        periodMonths: 12,
        targetValue: 1000000,
        targetDividend: 100000,
        assets: assets,
      );

      final SimulationState state = controller.state;
      expect(state.isLoading, false);
      expect(state.isSuccess, true);
      expect(state.error, isNull);
      expect(state.resultData, {'result': 'ok'});

      verify(
        () => useCase.execute(
          request: any<GoalAnalysisSimulationRequestDto>(named: 'request'),
        ),
      ).called(1);
    });

    test('실패 시 isSuccess=false, error 설정', () async {
      when(
        () => useCase.execute(
          request: any<GoalAnalysisSimulationRequestDto>(named: 'request'),
        ),
      ).thenThrow(Exception('실패'));

      await controller.runSimulation(
        periodMonths: 0,
        targetValue: 0,
        targetDividend: 0,
        assets: const [],
      );

      final state = controller.state;
      expect(state.isLoading, false);
      expect(state.isSuccess, false);
      expect(state.error, isNotNull);
    });
  });

  group('SimulationController.validateCanAdd/DeleteAsset', () {
    test('validateCanAddAsset 성공 시 true 리턴하고 error null', () {
      when(() => useCase.validateCanAddAsset(any())).thenReturn(null);

      final result = controller.validateCanAddAsset(1);

      expect(result, true);
      expect(controller.state.error, isNull);
    });

    test('validateCanAddAsset 예외 시 false 리턴하고 error 설정', () {
      when(
        () => useCase.validateCanAddAsset(any()),
      ).thenThrow(Exception('최대 10개'));

      final result = controller.validateCanAddAsset(10);

      expect(result, false);
      expect(controller.state.error, isNotNull);
    });

    test('validateCanDeleteAsset 성공 시 true 리턴하고 error null', () {
      when(() => useCase.validateCanDeleteAsset(any())).thenReturn(null);

      final result = controller.validateCanDeleteAsset(2);

      expect(result, true);
      expect(controller.state.error, isNull);
    });

    test('validateCanDeleteAsset 예외 시 false 리턴하고 error 설정', () {
      when(
        () => useCase.validateCanDeleteAsset(any()),
      ).thenThrow(Exception('최소 1개 유지'));

      final result = controller.validateCanDeleteAsset(1);

      expect(result, false);
      expect(controller.state.error, isNotNull);
    });
  });

  group('SimulationController 기타', () {
    test('resolveMonthlyVolatility는 useCase 위임', () {
      when(() => useCase.resolveMonthlyVolatility('STOCK')).thenReturn(8.0);

      final v = controller.resolveMonthlyVolatility('STOCK');

      expect(v, 8.0);
      verify(() => useCase.resolveMonthlyVolatility('STOCK')).called(1);
    });

    test('clearError는 state.error를 null로 만든다', () {
      controller = SimulationController(useCase: useCase)
        ..state = controller.state.copyWith(error: '에러');

      controller.clearError();

      expect(controller.state.error, isNull);
    });

    test('resetStatus는 초기 SimulationState로 리셋한다', () {
      controller = SimulationController(useCase: useCase)
        ..state = controller.state.copyWith(
          isLoading: true,
          isSuccess: true,
          error: '에러',
          resultData: {'x': 1},
        );

      controller.resetStatus();

      expect(controller.state.isLoading, false);
      expect(controller.state.isSuccess, false);
      expect(controller.state.error, isNull);
      expect(controller.state.resultData, isNull);
    });
  });
}
