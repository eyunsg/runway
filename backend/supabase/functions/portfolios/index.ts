import {
  handleCreatePortfolio,
  handleGetPortfolios,
  handleGetPortfolioDetail,
  handleUpdatePortfolio,
  handleDeletePortfolio,
} from './portfolioController.ts';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'GET, POST, PATCH, DELETE, OPTIONS',
};

Deno.serve(async (req: Request) => {
  const { method } = req;
  const url = new URL(req.url);
  const pathSegments = url.pathname.split('/').filter(Boolean);

  // CORS Preflight 요청 처리
  if (method === 'OPTIONS') {
    return new Response(null, {
      status: 204,
      headers: corsHeaders,
    });
  }

  try {
    // GET 요청 처리: 목록 조회 vs 상세 조회
    if (method === 'GET') {
      // 경로가 /portfolios 이면 전체 목록 조회 (API-PORT-002)
      // 경로에 ID가 포함되어 있으면 상세 조회 (API-PORT-003)
      if (pathSegments.length > 1) {
        return await handleGetPortfolioDetail(req);
      }
      return await handleGetPortfolios(req);
    }

    // POST 요청 처리: 신규 생성 (API-PORT-001)
    if (method === 'POST') {
      return await handleCreatePortfolio(req);
    }

    // PATCH 요청 처리: 정보 수정 (API-PORT-005)
    if (method === 'PATCH') {
      return await handleUpdatePortfolio(req);
    }

    // DELETE 요청 처리: 소프트 삭제 (API-PORT-006)
    if (method === 'DELETE') {
      return await handleDeletePortfolio(req);
    }

    // 정의되지 않은 메서드 처리
    return new Response(JSON.stringify({ error: { message: 'Method Not Allowed' } }), {
      status: 405,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  } catch (err) {
    // 예기치 못한 서버 에러 처리
    return new Response(JSON.stringify({ error: { message: String(err) } }), {
      status: 500,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  }
});
