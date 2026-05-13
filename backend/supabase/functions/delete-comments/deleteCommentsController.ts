import { deleteCommentService } from './deleteCommentsService.ts';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'DELETE, OPTIONS',
};

export class ValidationError extends Error {}

export async function handleDeleteComment(req: Request, commentId: string) {
  if (!commentId || commentId.trim().length === 0) {
    throw new ValidationError('VALIDATION_ERROR: commentId가 필요합니다.');
  }

  const authHeader = req.headers.get('authorization') ?? '';

  await deleteCommentService(authHeader, commentId);

  // API-COMM-008 명세: Status 204, Body N/A
  return new Response(null, {
    status: 204,
    headers: corsHeaders,
  });
}
