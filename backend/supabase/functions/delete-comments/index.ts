import { handleDeleteComment, ValidationError } from './deleteCommentsController.ts';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'DELETE, OPTIONS',
};

function errorResponse(message: string, status: number) {
  const codeMap: Record<number, string> = {
    400: 'BAD_REQUEST',
    404: 'NOT_FOUND',
    405: 'METHOD_NOT_ALLOWED',
    500: 'INTERNAL_SERVER_ERROR',
  };

  return new Response(
    JSON.stringify({
      error: {
        code: codeMap[status] || 'UNKNOWN_ERROR',
        message: message,
      },
    }),
    {
      status,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    }
  );
}

Deno.serve(async (req: Request) => {
  // CORS 프리플라이트 처리
  if (req.method === 'OPTIONS') {
    return new Response(null, { status: 204, headers: corsHeaders });
  }

  try {
    const url = new URL(req.url);
    const rawParts = url.pathname.split('/').filter(Boolean);

    // 폴더명이 경로에 포함된 경우 제거
    const pathParts =
      rawParts.length > 0 && rawParts[0] === 'delete-comments' ? rawParts.slice(1) : rawParts;

    // Target Path: /comments/{commentId}
    const isCommentPath = pathParts.length === 2 && pathParts[0] === 'comments';

    if (isCommentPath) {
      const commentId = pathParts[1];

      if (req.method === 'DELETE') {
        return await handleDeleteComment(req, commentId);
      }

      return errorResponse('허용되지 않은 메서드입니다.', 405);
    }

    return errorResponse('요청하신 경로를 찾을 수 없거나 허용되지 않은 메서드입니다.', 404);
  } catch (err: unknown) {
    let status = 500;
    let message = '알 수 없는 서버 에러가 발생했습니다.';

    // 에러 파싱 로직
    if (err instanceof ValidationError) {
      status = 400;
      message = err.message;
    } else if (err instanceof Error) {
      if (err.message.includes('VALIDATION_ERROR')) {
        status = 400;
        message = err.message.replace('VALIDATION_ERROR: ', '');
      } else if (err.message.includes('NOT_FOUND')) {
        status = 404;
        message = err.message.replace('NOT_FOUND: ', '');
      } else if (err.message.includes('DATABASE_ERROR')) {
        status = 500;
        message = '데이터 처리 중 오류가 발생했습니다.';
      } else {
        message = err.message;
      }
    }

    const requestId = crypto.randomUUID();
    console.error(`[DeleteComment Error][${requestId}]: ${message}`);
    return errorResponse(message, status);
  }
});
