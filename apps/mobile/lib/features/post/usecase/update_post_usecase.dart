import 'package:dartz/dartz.dart';
import 'package:runway/core/error/failure.dart';
import 'package:runway/features/post/dto/update_post_request_dto.dart';
import 'package:runway/features/post/repository/update_post_repository.dart';

class UpdatePostUsecase {
  final UpdatePostRepository repository;

  UpdatePostUsecase(this.repository);

  Future<Either<Failure, void>> execute({
    required String postId,
    required String content,

    String? portfolioId,

    required bool isPortfolioRemoved,
  }) async {
    final String trimmedPostId = postId.trim();
    final String trimmedContent = content.trim();

    final String? trimmedPortfolioId = portfolioId?.trim();

    if (trimmedPostId.isEmpty) {
      return const Left(ServerFailure('수정할 게시물 ID가 없습니다.'));
    }

    if (trimmedContent.isEmpty) {
      return const Left(ServerFailure('게시물 내용을 입력해주세요.'));
    }

    if (trimmedContent.length > 5000) {
      return const Left(ServerFailure('게시물 내용은 5000자 이내여야 합니다.'));
    }

    final UpdatePostRequestDto requestDto = UpdatePostRequestDto(
      postId: trimmedPostId,
      content: trimmedContent,
      portfolioId: trimmedPortfolioId == null || trimmedPortfolioId.isEmpty
          ? null
          : trimmedPortfolioId,
      isPortfolioRemoved: isPortfolioRemoved,
    );

    final result = await repository.updatePost(requestDto);

    return result;
  }
}
