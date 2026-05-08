import 'package:dartz/dartz.dart';
import 'package:runway/core/error/failure.dart';
import 'package:runway/features/post/dto/post_detail_response_dto.dart';
import 'package:runway/features/post/model/post.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GetPostDetailRepository {
  final SupabaseClient _client;

  GetPostDetailRepository({required SupabaseClient client}) : _client = client;

  Future<Either<Failure, Post>> getPostDetail(String postId) async {
    try {
      final response = await _client.functions.invoke(
        'posts/$postId',
        method: HttpMethod.get,
      );

      if (response.status != 200) {
        return Left(ServerFailure('게시물 상세 조회 실패'));
      }

      final data = response.data;
      if (data is! Map) {
        return Left(ServerFailure('게시글 상세 응답 형식이 올바르지 않습니다.'));
      }

      final postDto = PostDetailResponseDto.fromJson(
        Map<String, dynamic>.from(data),
      );

      return Right(postDto.post.toModel());
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
