import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import 'package:runway/core/error/failure.dart';
import 'package:runway/features/post/dto/my_post_response_dto.dart';
import 'package:runway/features/post/model/post.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GetMyPostRepository {
  final SupabaseClient _client;

  GetMyPostRepository({required SupabaseClient client}) : _client = client;

  Future<Either<Failure, List<Post>>> getMyPost() async {
    try {
      final session = _client.auth.currentSession;
      final accessToken = session?.accessToken;

      if (accessToken == null || accessToken.isEmpty) {
        return Left(AuthFailure('로그인이 필요합니다.'));
      }

      final projectUrl = Supabase.instance.client.rest.url.replaceFirst(
        '/rest/v1',
        '',
      );
      final functionUrl = '$projectUrl/functions/v1/posts/me';

      final response = await http.get(
        Uri.parse(functionUrl),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        return Left(ServerFailure('조회 실패'));
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        return Left(ServerFailure('게시글 목록 응답 형식이 올바르지 않습니다.'));
      }

      final postsDto = MyPostResponseDto.listFromResponseJson(decoded);
      final posts = postsDto.map((e) => e.toModel()).toList();

      return Right(posts);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on FormatException catch (e) {
      return Left(ServerFailure(e.message));
    } on Exception catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
