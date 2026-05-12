import { getCommentsService } from './getCommentsService.ts';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'GET, OPTIONS',
};

export class ValidationError extends Error {}

export async function handleGetComments(req: Request, postId: string) {
  if (!postId || postId.trim().length === 0) {
    throw new ValidationError('VALIDATION_ERROR: postId가 필요합니다.');
  }

  const authHeader = req.headers.get('authorization') ?? '';

  const responseDto = await getCommentsService(authHeader, postId);

  return new Response(JSON.stringify(responseDto), {
    status: 200,
    headers: {
      ...corsHeaders,
      'Content-Type': 'application/json',
    },
  });
}
