import 'package:dartz/dartz.dart';
import 'package:runway/core/error/failure.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DeleteCommentRepository {
  final SupabaseClient _client;

  DeleteCommentRepository({required SupabaseClient client}) : _client = client;

  Future<Either<Failure, bool>> deleteComment(String commentId) async {
    try {
      final response = await _client.functions.invoke(
        'delete-comments/comments/$commentId',
        method: HttpMethod.delete,
      );

      if (response.status != 204) {
        final data = response.data;

        if (data is Map &&
            data['error'] is Map &&
            data['error']['message'] != null) {
          return Left(ServerFailure(data['error']['message'].toString()));
        }

        return Left(ServerFailure('댓글 삭제 실패'));
      }

      return const Right(true);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on FunctionException catch (e) {
      final dynamic details = e.details;
      final String message = details?.toString().trim().isNotEmpty == true
          ? details.toString()
          : '댓글 삭제 실패';
      return Left(ServerFailure(message));
    } on PostgrestException catch (e) {
      return Left(ServerFailure(e.message));
    } on FormatException catch (e) {
      return Left(ServerFailure(e.message));
    } on Exception catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
