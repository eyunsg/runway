import 'package:dartz/dartz.dart';
import 'package:runway/core/error/failure.dart';
import 'package:runway/features/post/dto/create_post_request_dto.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CreatePostRepository {
  final SupabaseClient _client;

  CreatePostRepository({required SupabaseClient client}) : _client = client;

  Future<Either<Failure, void>> createPost(
    CreatePostRequestDto requestDto,
  ) async {
    try {
      /// TODO(RUNWAY-227):
      /// 프론트 정책상 portfolioId 는 optional 이어야 한다.
      /// 하지만 현재 백엔드 PostPostsRequestDto 는 portfolioId 를 required 로 검증하고 있다.
      /// 백엔드가 optional 로 수정되기 전까지는 repository 에서 임시 방어한다.
      if (requestDto.portfolioId == null) {
        return const Left(
          ServerFailure(
            '현재 서버에서는 포트폴리오를 선택한 경우에만 게시글 등록이 가능합니다. 백엔드 수정 후 해제 예정입니다.',
          ),
        );
      }

      final response = await _client.functions.invoke(
        'posts',
        method: HttpMethod.post,
        body: requestDto.toJson(),
      );

      if (response.status != 201) {
        final message = _extractErrorMessage(response.data);

        return Left(ServerFailure(message ?? '게시글 등록에 실패했습니다.'));
      }

      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on FunctionException catch (e) {
      return Left(
        ServerFailure(
          e.details?.toString() ??
              e.reasonPhrase ??
              '게시글 등록 중 함수 호출 에러가 발생했습니다.',
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
