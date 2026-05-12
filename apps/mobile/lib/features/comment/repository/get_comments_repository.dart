import 'package:dartz/dartz.dart';
import 'package:runway/core/error/failure.dart';
import 'package:runway/features/comment/dto/comment_response_dto.dart';
import 'package:runway/features/comment/model/comment.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GetCommentsRepository {
  final SupabaseClient _client;

  GetCommentsRepository({required SupabaseClient client}) : _client = client;

  Future<Either<Failure, List<Comment>>> getComments(String postId) async {
    try {
      final response = await _client.functions.invoke(
        'get-comments/posts/$postId/comments',
        method: HttpMethod.get,
      );

      if (response.status != 200) {
        return Left(ServerFailure('댓글 조회 실패'));
      }

      final data = response.data;
      if (data is! Map) {
        return Left(ServerFailure('댓글 응답 형식이 올바르지 않습니다.'));
      }

      final dto = GetCommentsResponseDto.fromJson(
        Map<String, dynamic>.from(data),
      );
      final comments = dto.comments.map((e) => e.toModel()).toList();

      return Right(comments);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on PostgrestException catch (e) {
      return Left(ServerFailure(e.message));
    } on FormatException catch (e) {
      return Left(ServerFailure(e.message));
    } on Exception catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
