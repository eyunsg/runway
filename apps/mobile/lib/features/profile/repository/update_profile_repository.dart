import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:runway/core/error/failure.dart';
import 'package:dartz/dartz.dart';

class UpdateProfileRepository {
  final SupabaseClient _client;

  UpdateProfileRepository({required SupabaseClient client}) : _client = client;

  Future<Either<Failure, void>> updateProfile(String newDisplayName) async {
    try {
      final response = await _client.functions.invoke(
        'profile',
        body: {'displayName': newDisplayName},
      );

      if (response.status != 204) {
        return Left(ServerFailure('Update failed'));
      }

      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on PostgrestException catch (e) {
      return Left(ServerFailure(e.message));
    } on Exception catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
