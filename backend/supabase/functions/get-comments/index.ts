import { handleGetComments, ValidationError } from './getCommentsController.ts';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'GET, OPTIONS',
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
  if (req.method === 'OPTIONS') {
    return new Response(null, { status: 204, headers: corsHeaders });
  }

  try {
    const url = new URL(req.url);
    const pathParts = url.pathname.split('/').filter(Boolean);
    const lastPart = pathParts[pathParts.length - 1];
    const secondLastPart = pathParts[pathParts.length - 2];
    const thirdLastPart = pathParts[pathParts.length - 3];

    const isPostCommentsPath =
      pathParts.length === 3 && thirdLastPart === 'posts' && lastPart === 'comments';

    if (isPostCommentsPath) {
      const postId = secondLastPart;

      if (req.method === 'GET') {
        return await handleGetComments(req, postId);
      }

      return errorResponse('허용되지 않은 메서드입니다.', 405);
    }

    return errorResponse('요청하신 경로를 찾을 수 없거나 허용되지 않은 메서드입니다.', 404);
  } catch (err: unknown) {
    let status = 500;
    let message = '알 수 없는 서버 에러가 발생했습니다.';

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
    console.error(`[GetComments Error][${requestId}]: ${message}`);
    return errorResponse(message, status);
  }
});
