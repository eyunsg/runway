import { CommentDto, GetCommentsResponseDto } from '../../../shared/dto/get_comments/CommentDto.ts';
import { findCommentsByPostIdRepo } from './getCommentRepository.ts';
import { Comment } from '../../../shared/domain/get_comments/Comment.ts';

export async function getCommentsService(
  authHeader: string,
  postId: string
): Promise<GetCommentsResponseDto> {
  const domainComments = await findCommentsByPostIdRepo(authHeader, postId);

  if (!domainComments) {
    throw new Error('DATABASE_ERROR: 댓글 목록을 불러오지 못했습니다.');
  }

  const comments = (domainComments as Comment[]).map((comment: Comment) => {
    const model = comment.toResponseModel();
    return new CommentDto(model.commentId, model.content, model.authorDisplayName, model.createdAt);
  });

  return new GetCommentsResponseDto(comments);
}
