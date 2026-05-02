import 'package:dartz/dartz.dart';
import 'package:runway/core/error/failure.dart';
import 'package:runway/features/post/dto/create_post_request_dto.dart';
import 'package:runway/features/post/repository/create_post_repository.dart';

class CreatePostUseCase {
  final CreatePostRepository repository;

  CreatePostUseCase(this.repository);

  Future<Either<Failure, void>> execute({
    required String content,
    String? portfolioId,
  }) async {
    final String trimmedContent = content.trim();
    final String? trimmedPortfolioId = portfolioId?.trim();

    if (trimmedContent.isEmpty) {
      return const Left(ServerFailure('게시물 내용을 입력해주세요.'));
    }

    if (trimmedContent.length > 5000) {
      return const Left(ServerFailure('게시물 내용은 5000자 이내여야 합니다.'));
    }

    final CreatePostRequestDto requestDto = CreatePostRequestDto(
      portfolioId: trimmedPortfolioId == null || trimmedPortfolioId.isEmpty
          ? null
          : trimmedPortfolioId,
      content: trimmedContent,
    );

    final result = await repository.createPost(requestDto);

    return result;
  }
}
