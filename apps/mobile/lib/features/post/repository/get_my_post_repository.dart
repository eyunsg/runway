import 'package:dartz/dartz.dart';
import 'package:runway/core/error/failure.dart';
import 'package:runway/features/post/dto/my_post_response_dto.dart';
import 'package:runway/features/post/model/post.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GetMyPostRepository {
  final SupabaseClient _client;

  GetMyPostRepository({required SupabaseClient client}) : _client = client;

  Future<Either<Failure, List<Post>>> getMyPost() async {
    try {
      final response = await _client.functions.invoke(
        'posts/me',
        method: HttpMethod.get,
      );

      if (response.status != 200) {
        return Left(ServerFailure('조회 실패'));
      }

      final data = response.data;
      if (data is! Map) {
        return Left(ServerFailure('게시글 목록 응답 형식이 올바르지 않습니다.'));
      }

      final postsDto = MyPostResponseDto.listFromResponseJson(
        Map<String, dynamic>.from(data),
      );

      final posts = postsDto.map((e) => e.toModel()).toList();

      return Right(posts);
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
