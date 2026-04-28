import { Post } from '../../../shared/domain/posts/Post.ts';
import { PostPostsRequestDto } from '../../../shared/dto/posts/PostPostsRequest.dto.ts';
import { createPortfolioSnapshotRepo, savePostRepo } from './postsRepository.ts';

export async function addPostService(userId: string, dto: PostPostsRequestDto): Promise<string> {
  // 1. 게시 시점의 포트폴리오 데이터를 스냅샷으로 생성 (데이터 박제)
  const snapshotId = await createPortfolioSnapshotRepo(userId, dto.portfolioId);

  // 2. 스냅샷 생성 실패 시 예외 발생 (포트폴리오가 없거나 권한이 없는 경우)
  if (!snapshotId) {
    throw new Error('NOT_FOUND: 게시할 포트폴리오를 찾을 수 없거나 접근 권한이 없습니다.');
  }

  // 3. DTO 데이터를 도메인 모델로 변환
  const post = new Post(userId, snapshotId, dto.content);

  // 4. 도메인 객체를 리포지토리에 전달하여 저장 위임
  const postId = await savePostRepo(post);

  // 5. 저장 실패 시 예외 발생 (Entry Point에서 500 에러로 처리됨)
  if (!postId) {
    throw new Error('DATABASE_ERROR: 게시물 저장 중 오류가 발생했습니다.');
  }

  return postId;
}
