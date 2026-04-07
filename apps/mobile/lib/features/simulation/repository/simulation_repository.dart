import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:runway/features/simulation/types/simulation_request_dto.dart';

abstract class SimulationRepository {
  Future<dynamic> runMonteCarlo(GoalAnalysisSimulationRequestDto request);
}

class SimulationRepositoryImpl implements SimulationRepository {
  final SupabaseClient _client;

  SimulationRepositoryImpl({required SupabaseClient client}) : _client = client;

  @override
  Future<dynamic> runMonteCarlo(
    GoalAnalysisSimulationRequestDto request,
  ) async {
    try {
      final response = await _client.functions.invoke(
        'simulations',
        body: request.toJson(),
        method: HttpMethod.post,
      );

      if (response.status == 200) {
        return response.data;
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
