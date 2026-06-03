import 'package:dartz/dartz.dart';
import 'package:runway/core/error/failure.dart';
import 'package:runway/core/error/validation_failure.dart';
import 'package:runway/features/post/model/post.dart';
import 'package:runway/features/post/repository/get_post_detail_repository.dart';

class GetPostDetailUsecase {
  final GetPostDetailRepository repository;

  GetPostDetailUsecase(this.repository);

  Future<Either<Failure, Post>> execute(String postId) async {
    if (postId.trim().isEmpty) {
      return Left(PortfolioValidationFailure('유효한 게시물 ID가 필요합니다.'));
    }

    return repository.getPostDetail(postId);
  }
}
