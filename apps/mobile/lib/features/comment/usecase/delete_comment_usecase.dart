import 'package:dartz/dartz.dart';
import 'package:runway/core/error/failure.dart';
import 'package:runway/core/error/validation_failure.dart';
import 'package:runway/features/comment/repository/delete_comment_repository.dart';

class DeleteCommentUsecase {
  final DeleteCommentRepository repository;

  DeleteCommentUsecase(this.repository);

  Future<Either<Failure, bool>> execute(String commentId) async {
    if (commentId.trim().isEmpty) {
      return Left(PortfolioValidationFailure('유효한 댓글 ID가 필요합니다.'));
    }

    return repository.deleteComment(commentId);
  }
}
