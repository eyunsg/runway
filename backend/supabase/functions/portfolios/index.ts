import {
  handleAddPortfolio,
  handleGetPortfolios,
  handleGetPortfolioDetail,
  handleGetPortfolioSnapshotDetail,
  handleUpdatePortfolio,
  handleDeletePortfolio,
  handleGetRecentPortfolios,
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
    const pathParts = url.pathname.split('/').filter(Boolean);
    const lastPart = pathParts[pathParts.length - 1];
    const secondLastPart = pathParts[pathParts.length - 2];

    const isPortfoliosPath = lastPart === 'portfolios';
    // 최근 포트폴리오 조회 경로 판정 (/portfolios/recent)
    const isPortfolioRecentPath = secondLastPart === 'portfolios' && lastPart === 'recent';
    // 포트폴리오 상세 조회 경로 판정 (recent 및 snapshots 예외 필터링 추가로 라우팅 충돌 원천 해결)
    const isPortfolioDetailPath =
      secondLastPart === 'portfolios' && lastPart !== 'snapshots' && lastPart !== 'recent';
    const isPortfolioSnapshotDetailPath =
      secondLastPart === 'snapshots' && pathParts.includes('portfolios');

    // 2. GET 요청 라우팅
    if (req.method === 'GET') {
      // 최근 포트폴리오 조회: /portfolios/recent
      if (isPortfolioRecentPath) {
        return await handleGetRecentPortfolios(req);
      }

      // 스냅샷 상세 조회: /portfolios/snapshots/{snapshotId}
      if (isPortfolioSnapshotDetailPath) {
        const snapshotId = lastPart;
        return await handleGetPortfolioSnapshotDetail(req, snapshotId);
      }

      // 포트폴리오 상세 조회: /portfolios/{portfolioId}
      if (isPortfolioDetailPath && !isPortfoliosPath) {
        const portfolioId = lastPart;
        return await handleGetPortfolioDetail(req, portfolioId);
      }

      // 포트폴리오 목록 조회: /portfolios
      if (isPortfoliosPath) {
        return await handleGetPortfolios(req);
      }

      return errorResponse('요청하신 경로를 찾을 수 없습니다.', 404);
    }

    // 3. POST 요청 라우팅
    if (req.method === 'POST') {
      if (isPortfoliosPath) {
        return await handleAddPortfolio(req);
      }
      return errorResponse('요청하신 경로를 찾을 수 없습니다.', 404);
    }

    // 4. PATCH 요청 라우팅 (수정)
    if (req.method === 'PATCH') {
      if (isPortfolioDetailPath && !isPortfoliosPath) {
        const portfolioId = lastPart;
        return await handleUpdatePortfolio(req, portfolioId);
      }
      return errorResponse('포트폴리오 ID가 필요합니다.', 400);
    }

    // 5. DELETE 요청 라우팅
    if (req.method === 'DELETE') {
      if (isPortfolioDetailPath && !isPortfoliosPath) {
        const portfolioId = lastPart;
        return await handleDeletePortfolio(req, portfolioId);
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
