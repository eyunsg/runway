import 'package:dartz/dartz.dart';
import 'package:runway/core/error/failure.dart';
import 'package:runway/features/post/repository/delete_post_repository.dart';

class DeletePostUsecase {
  final DeletePostRepository repository;

  DeletePostUsecase({required this.repository});

  Future<Either<Failure, void>> execute(String postId) async {
    return await repository.deletePost(postId);
  }
}
