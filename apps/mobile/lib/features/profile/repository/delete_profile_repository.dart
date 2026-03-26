import 'package:http/http.dart';
import 'package:runway/core/error/failure.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dartz/dartz.dart';

class DeleteProfileRepository {
  final SupabaseClient _client;

  DeleteProfileRepository({required SupabaseClient client}) : _client = client;

  Future<Either<Failure, void>> deleteProfile() async {
    try {
      final response = await _client.functions.invoke(
        'profile',
        method: HttpMethod.delete,
      );

      if (response.status != 204) {
        return Left(ServerFailure('Delete failed'));
      }

      await _client.auth.signOut();

      return Right(null);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
