import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:runway/features/simulation/types/simulation_request_dto.dart';
import 'package:runway/features/simulation/types/simulation_response_dto.dart';

abstract class SimulationRepository {
  Future<SimulationResponseDto> runMonteCarlo(
    GoalAnalysisSimulationRequestDto request,
  );
}

class SimulationRepositoryImpl implements SimulationRepository {
  final SupabaseClient _client;

  SimulationRepositoryImpl({required SupabaseClient client}) : _client = client;

  @override
  Future<SimulationResponseDto> runMonteCarlo(
    GoalAnalysisSimulationRequestDto request,
  ) async {
    try {
      final response = await _client.functions.invoke(
        'simulations',
        body: request.toJson(),
        method: HttpMethod.post,
      );

      if (response.status == 200) {
        final data = response.data;
        if (data == null || data is! Map<String, dynamic>) {
          throw Exception('시뮬레이션 응답 형식이 올바르지 않습니다.');
        }

        return SimulationResponseDto.fromJson(data);
      } else {
        final errorMessage =
            response.data['error']?['message'] ?? '시뮬레이션 요청 중 오류가 발생했습니다.';
        throw Exception(errorMessage);
      }
    } catch (e) {
      rethrow;
    }
  }
}
