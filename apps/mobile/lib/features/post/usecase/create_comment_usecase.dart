import 'package:dartz/dartz.dart';
import 'package:runway/core/error/failure.dart';
import 'package:runway/features/post/dto/create_comment_request_dto.dart';
import 'package:runway/features/post/repository/create_comment_repository.dart';

class CreateCommentUsecase {
  final CreateCommentRepository repository;

  CreateCommentUsecase(this.repository);

  Future<Either<Failure, void>> execute({
    required String postId,
    required String content,
  }) async {
    final String trimmedPostId = postId.trim();
    final String trimmedContent = content.trim();

    if (trimmedPostId.isEmpty) {
      return const Left(ServerFailure('유효한 게시물 ID가 필요합니다.'));
    }

    if (trimmedContent.isEmpty) {
      return const Left(ServerFailure('댓글 내용을 입력해주세요.'));
    }

    if (trimmedContent.length > 1000) {
      return const Left(ServerFailure('댓글 내용은 1000자 이내여야 합니다.'));
    }

    final CreateCommentRequestDto requestDto = CreateCommentRequestDto(
      content: trimmedContent,
    );

    return repository.createComment(
      postId: trimmedPostId,
      requestDto: requestDto,
    );
  }
}
