import 'package:dartz/dartz.dart';
import 'package:runway/core/error/failure.dart';
import 'package:runway/features/profile/data/dto/profile_dto.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GetProfileRepository {
  final SupabaseClient _client;

  GetProfileRepository({required SupabaseClient client}) : _client = client;

  Future<Either<Failure, ProfileDto>> getProfile() async {
    try {
      final response = await _client.functions.invoke(
        'profile',
        method: HttpMethod.get,
      );

      if (response.status != 200) {
        return Left(ServerFailure('Failed to fetch profile'));
      }

      final data = response.data;
      if (data == null || data is! Map<String, dynamic>) {
        return Left(ServerFailure('Invalid response format'));
      }

      final dto = ProfileDto.fromJson(data);

      return Right(dto);
    }
    // 인증 에러
    on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    }
    // DB / 서버 에러
    on PostgrestException catch (e) {
      return Left(ServerFailure(e.message));
    }
    // 기타
    catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
