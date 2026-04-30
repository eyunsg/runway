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

    // RUNWAY-227 프론트 정책:
    // - portfolioId 는 optional 이어야 한다.
    // - 따라서 포트폴리오 미선택 상태에서도 requestDto 생성은 허용한다.
    //
    // 현재 백엔드 상태:
    // - backend request dto 는 portfolioId 를 required 로 검증하고 있다.
    // - 이 충돌은 UseCase 에서 막지 않고, Repository 단계에서 임시 방어 / TODO 처리한다.
    //
    // 이유:
    // - UseCase 는 프론트의 비즈니스 요구사항을 기준으로 정책을 가져가야 한다.
    // - 백엔드가 optional 로 수정되면 Repository 일부만 조정해서 바로 연동 가능해야 한다.

    final result = await repository.createPost(requestDto);

    return result;
  }
}
