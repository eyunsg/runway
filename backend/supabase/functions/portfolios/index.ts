import {
  handleAddPortfolio,
  handleGetPortfolios,
  handleGetPortfolioDetail,
  handleUpdatePortfolio,
  handleDeletePortfolio,
  UnauthorizedError,
  ValidationError,
} from './portfoliosController.ts';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'GET, POST, PATCH, DELETE, OPTIONS',
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
  // 1. CORS Preflight 요청 처리
  if (req.method === 'OPTIONS') {
    return new Response(null, { status: 204, headers: corsHeaders });
  }

  try {
    const url = new URL(req.url);
    const pathParts = url.pathname.split('/').filter(Boolean); // 예: ["portfolios", "uuid"]

    // 2. GET 요청 라우팅
    if (req.method === 'GET') {
      // 상세 조회: /portfolios/{id} (경로 조각이 2개인 경우)
      if (pathParts.length > 1) {
        return await handleGetPortfolioDetail(req, pathParts[1]);
      }
      // 목록 조회: /portfolios
      return await handleGetPortfolios(req);
    }

    // 3. POST 요청 라우팅
    if (req.method === 'POST') {
      return await handleAddPortfolio(req);
    }

    // 4. PATCH 요청 라우팅 (수정)
    if (req.method === 'PATCH') {
      if (pathParts.length > 1) {
        return await handleUpdatePortfolio(req, pathParts[1]);
      }
      return errorResponse('포트폴리오 ID가 필요합니다.', 400);
    }

    // 5. DELETE 요청 라우팅
    if (req.method === 'DELETE') {
      if (pathParts.length > 1) {
        return await handleDeletePortfolio(req, pathParts[1]);
      }
      return errorResponse('삭제할 포트폴리오 ID가 필요합니다.', 400);
    }

    // 6. 허용되지 않은 메서드 처리
    return errorResponse('GET, POST, PATCH, DELETE 또는 OPTIONS 요청만 허용됩니다.', 405);
  } catch (err: unknown) {
    // 6. 전역 에러 핸들링
    let status = 500;
    let message = '알 수 없는 서버 에러가 발생했습니다.';

    if (err instanceof ValidationError) {
      // 컨트롤러/DTO에서 명시적으로 던진 검증 에러
      status = 400;
      message = err.message;
    } else if (err instanceof UnauthorizedError) {
      // 인증 실패 에러
      status = 401;
      message = err.message;
    } else if (err instanceof Error) {
      // DTO, 도메인, 서비스에서 던진 일반 에러 처리
      if (err.message.includes('VALIDATION_ERROR')) {
        status = 400;
        message = err.message.replace('VALIDATION_ERROR: ', '');
      } else if (err.message.includes('NOT_FOUND')) {
        // 4. 리소스 없음 에러 처리 (404)
        status = 404;
        message = err.message.replace('NOT_FOUND: ', '');
      } else if (err.message.includes('DATABASE_ERROR')) {
        status = 500;
        message = '데이터 저장 중 오류가 발생했습니다.';
      } else {
        message = err.message;
      }
    }

    console.error(`[Global Error Log]: ${message}`);
    return errorResponse(message, status);
  }
});
