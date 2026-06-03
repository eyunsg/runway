import { softDeleteCommentRepo } from './deleteCommentRepository.ts';

export async function deleteCommentService(authHeader: string, commentId: string): Promise<void> {
  await softDeleteCommentRepo(authHeader, commentId);
}
