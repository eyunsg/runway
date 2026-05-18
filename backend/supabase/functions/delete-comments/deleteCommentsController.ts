import { deleteCommentService } from './deleteCommentsService.ts';
import { HttpError } from './deleteCommentRepository.ts';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'DELETE, OPTIONS',
};

export class ValidationError extends Error {}

export async function handleDeleteComment(req: Request, commentId: string) {
  try {
    if (!commentId || commentId.trim().length === 0) {
      throw new ValidationError('VALIDATION_ERROR: commentId가 필요합니다.');
    }

    const authHeader = req.headers.get('authorization') ?? '';

    await deleteCommentService(authHeader, commentId);

    return new Response(null, {
      status: 204,
      headers: corsHeaders,
    });
  } catch (error) {
    if (error instanceof ValidationError) {
      return new Response(
        JSON.stringify({
          error: error.message,
        }),
        {
          status: 400,
          headers: {
            ...corsHeaders,
            'Content-Type': 'application/json',
          },
        }
      );
    }

    if (error instanceof HttpError) {
      return new Response(
        JSON.stringify({
          error: error.message,
        }),
        {
          status: error.status,
          headers: {
            ...corsHeaders,
            'Content-Type': 'application/json',
          },
        }
      );
    }

    return new Response(
      JSON.stringify({
        error: 'INTERNAL_SERVER_ERROR',
      }),
      {
        status: 500,
        headers: {
          ...corsHeaders,
          'Content-Type': 'application/json',
        },
      }
    );
  }
}
