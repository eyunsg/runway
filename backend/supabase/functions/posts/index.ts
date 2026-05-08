import {
  handleAddPost,
  handleGetPosts,
  handleGetMyPosts,
  handleGetPostDetail,
  handlePatchPost,
  UnauthorizedError,
  ValidationError,
} from './postsController.ts';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, GET, PATCH, OPTIONS',
};

function errorResponse(message: string, status: number) {
  const codeMap: Record<number, string> = {
    400: 'BAD_REQUEST',
    401: 'UNAUTHORIZED',
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
  // 1. CORS Preflight
  if (req.method === 'OPTIONS') {
    return new Response(null, { status: 204, headers: corsHeaders });
  }

  try {
    const url = new URL(req.url);
    const pathParts = url.pathname.split('/').filter(Boolean);
    const lastPart = pathParts[pathParts.length - 1];
    const secondLastPart = pathParts[pathParts.length - 2];

    const isMyPostsPath = lastPart === 'me' && secondLastPart === 'posts';
    const isPostsPath = pathParts.length === 1 && lastPart === 'posts';
    const isPostDetailPath =
      pathParts.length === 2 && secondLastPart === 'posts' && lastPart !== 'me';

    if (isMyPostsPath) {
      if (req.method === 'GET') {
        return await handleGetMyPosts(req);
      }
      return errorResponse('허용되지 않은 메서드입니다.', 405);
    }

    if (isPostDetailPath) {
      const postId = lastPart;

      if (req.method === 'GET') {
        return await handleGetPostDetail(req, postId);
      }

      if (req.method === 'PATCH') {
        return await handlePatchPost(req, postId);
      }

      return errorResponse('허용되지 않은 메서드입니다.', 405);
    }

    // 2. 라우팅 로직
    if (isPostsPath) {
      // API-COMM-001: 게시글 작성
      if (req.method === 'POST') {
        return await handleAddPost(req);
      }

      // API-COMM-002: 게시글 목록 조회
      if (req.method === 'GET') {
        return await handleGetPosts(req);
      }

      return errorResponse('허용되지 않은 메서드입니다.', 405);
    }

    // 3. 그 외 경로나 메서드는 404/405 처리
    return errorResponse('요청하신 경로를 찾을 수 없거나 허용되지 않은 메서드입니다.', 404);
  } catch (err: unknown) {
    // 4. 전역 에러 핸들링 (Portfolio 패턴 준수)
    let status = 500;
    let message = '알 수 없는 서버 에러가 발생했습니다.';

    if (err instanceof ValidationError) {
      status = 400;
      message = err.message;
    } else if (err instanceof UnauthorizedError) {
      status = 401;
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
    console.error(`[Posts Error][${requestId}]: ${message}`);
    return errorResponse(message, status);
  }
});
