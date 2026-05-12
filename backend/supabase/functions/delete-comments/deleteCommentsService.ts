import { softDeleteCommentRepo } from './deleteCommentRepository.ts';

export async function deleteCommentService(authHeader: string, commentId: string): Promise<void> {
  const isSuccess = await softDeleteCommentRepo(authHeader, commentId);

  if (!isSuccess) {
    throw new Error('DATABASE_ERROR: 댓글 삭제 처리에 실패했습니다.');
  }
}
