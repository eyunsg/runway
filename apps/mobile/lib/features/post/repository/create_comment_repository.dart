import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:runway/core/error/failure.dart';
import 'package:runway/features/post/dto/create_comment_request_dto.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CreateCommentRepository {
  final SupabaseClient _client;

  CreateCommentRepository({required SupabaseClient client}) : _client = client;

  Future<Either<Failure, void>> createComment({
    required String postId,
    required CreateCommentRequestDto requestDto,
  }) async {
    try {
      final session = _client.auth.currentSession;
      final accessToken = session?.accessToken;

      if (accessToken == null || accessToken.isEmpty) {
        return const Left(AuthFailure('로그인이 필요합니다.'));
      }

      final supabaseUrl = dotenv.env['SUPABASE_URL'];
      final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

      if (supabaseUrl == null || supabaseUrl.isEmpty) {
        return const Left(ServerFailure('SUPABASE_URL 환경변수가 설정되지 않았습니다.'));
      }

      if (supabaseAnonKey == null || supabaseAnonKey.isEmpty) {
        return const Left(ServerFailure('SUPABASE_ANON_KEY 환경변수가 설정되지 않았습니다.'));
      }

      final uri = Uri.parse(
        '$supabaseUrl/functions/v1/create-comment/posts/$postId/comments',
      );

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
          'apikey': supabaseAnonKey,
        },
        body: jsonEncode(requestDto.toJson()),
      );

      final data = _tryDecodeJson(response.body);

      if (response.statusCode != 201) {
        final message = _extractErrorMessage(data);
        return Left(ServerFailure(message ?? '댓글 등록에 실패했습니다.'));
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

  dynamic _tryDecodeJson(String body) {
    if (body.isEmpty) return null;

    try {
      return jsonDecode(body);
    } catch (_) {
      return body;
    }
  }

  String? _extractErrorMessage(dynamic data) {
    if (data == null) return null;

    if (data is Map) {
      final error = data['error'];

      if (error is Map) {
        final message = error['message'];
        if (message is String && message.isNotEmpty) {
          return message;
        }
      }

      final message = data['message'];
      if (message is String && message.isNotEmpty) {
        return message;
      }
    }

    if (data is String && data.isNotEmpty) {
      return data;
    }

    return null;
  }
}
