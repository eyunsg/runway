import 'package:dartz/dartz.dart';
import 'package:runway/core/error/failure.dart';
import 'package:runway/core/error/validation_failure.dart';
import 'package:runway/features/comment/model/comment.dart';
import 'package:runway/features/comment/repository/get_comments_repository.dart';

class GetCommentsUsecase {
  final GetCommentsRepository repository;

  GetCommentsUsecase(this.repository);

  Future<Either<Failure, List<Comment>>> execute(String postId) async {
    if (postId.trim().isEmpty) {
      return Left(PortfolioValidationFailure('유효한 게시물 ID가 필요합니다.'));
    }

    return repository.getComments(postId);
  }
}
