import 'package:dartz/dartz.dart';
import 'package:runway/core/error/failure.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DeletePostRepository {
  final SupabaseClient _client;

  DeletePostRepository({required SupabaseClient client}) : _client = client;

  Future<Either<Failure, void>> deletePost(String postId) async {
    try {
      final response = await _client.functions.invoke(
        'posts/$postId',
        method: HttpMethod.delete,
      );

      if (response.status != 204) {
        final errorMessage =
            response.data?['error']?['message'] ?? 'Delete failed';
        return Left(ServerFailure(errorMessage));
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
