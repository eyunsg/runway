import { Post } from '../../../shared/domain/posts/Post.ts';
import { PostPostsRequestDto } from '../../../shared/dto/posts/PostPostsRequest.dto.ts';
import { createPortfolioSnapshotRepo, savePostRepo } from './postsRepository.ts';

export async function addPostService(userId: string, dto: PostPostsRequestDto): Promise<string> {
  let snapshotId: string | null = null;

  if (typeof dto.portfolioId === 'string' && dto.portfolioId.trim().length > 0) {
    snapshotId = await createPortfolioSnapshotRepo(userId, dto.portfolioId);

    if (!snapshotId) {
      throw new Error('NOT_FOUND: 게시할 포트폴리오를 찾을 수 없거나 접근 권한이 없습니다.');
    }
  }

  const post = new Post(userId, snapshotId, dto.content);

  const postId = await savePostRepo(post);

  if (!postId) {
    throw new Error('DATABASE_ERROR: 게시물 저장 중 오류가 발생했습니다.');
  }

  return postId;
}
