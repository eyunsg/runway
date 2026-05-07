import 'package:dartz/dartz.dart';
import 'package:runway/core/error/failure.dart';
import 'package:runway/features/post/model/post.dart';
import 'package:runway/features/post/repository/get_my_post_repository.dart';

class GetMyPostUsecase {
  final GetMyPostRepository repository;

  GetMyPostUsecase(this.repository);

  Future<Either<Failure, List<Post>>> execute() async {
    final result = await repository.getMyPost();
    return result;
  }
}
