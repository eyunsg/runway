import 'package:dartz/dartz.dart';
import 'package:runway/core/error/failure.dart';
import 'package:runway/features/post/dto/update_post_request_dto.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UpdatePostRepository {
  final SupabaseClient _client;

  UpdatePostRepository({required SupabaseClient client}) : _client = client;

  Future<Either<Failure, void>> updatePost(
    UpdatePostRequestDto requestDto,
  ) async {
    try {
      // RUNWAY-246 최종 백엔드 스펙용 코드
      // 백엔드에서 post의 portfolioId 변경/삭제를 지원하게 되면
      // 아래 블록을 주석 해제하고 바로 밑의 현재 content only 임시 실행 코드 블록을 제거하면 됨
      /*
      final response = await _client.functions.invoke(
        'posts/${requestDto.postId}',
        method: HttpMethod.patch,
        body: requestDto.toJson(),
      );

      if (response.status != 204) {
        final message = _extractErrorMessage(response.data);

        return Left(ServerFailure(message ?? '게시글 수정에 실패했습니다.'));
      }

      return const Right(null);
      */

      // [현재] content only 임시 실행 코드
      final response = await _client.functions.invoke(
        'posts/${requestDto.postId}',
        method: HttpMethod.patch,
        body: {'content': requestDto.content},
      );

      if (response.status != 204) {
        final message = _extractErrorMessage(response.data);

        return Left(ServerFailure(message ?? '게시글 수정에 실패했습니다.'));
      }

      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on FunctionException catch (e) {
      return Left(
        ServerFailure(
          e.details?.toString() ??
              e.reasonPhrase ??
              '게시글 수정 중 함수 호출 에러가 발생했습니다.',
        ),
      );
    } on PostgrestException catch (e) {
      return Left(ServerFailure(e.message));
    } on Exception catch (e) {
      return Left(UnknownFailure(e.toString()));
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
