import 'package:dartz/dartz.dart';
import 'package:runway/core/error/failure.dart';
import 'package:runway/features/post/model/post.dart';
import 'package:runway/features/post/repository/get_post_repository.dart';

class GetRecentPostUsecase {
  final GetPostRepository repository;

  GetRecentPostUsecase(this.repository);

  Future<Either<Failure, List<Post>>> execute() async {
    final result = await repository.getPost();

    return result.fold(
      (failure) => Left(failure),
      (posts) => Right(posts.take(3).toList()),
    );
  }
}
