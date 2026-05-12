import { createCommentRepo } from './createCommentRepository.ts';
import { Comment } from '../../../shared/domain/create_comments/Comment.ts';

export async function createCommentService(
  authHeader: string,
  postId: string,
  userId: string,
  content: string
): Promise<void> {
  // 1. 도메인 모델을 통한 유효성 검사 및 객체 생성
  const commentDomain = Comment.create(content, postId, userId);

  // 2. DB 저장을 위한 포맷으로 변환 후 레포지토리 호출
  await createCommentRepo(authHeader, commentDomain.toDbInsertRow());
}
