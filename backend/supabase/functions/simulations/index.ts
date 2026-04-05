import { handleSimulation } from './monteCarloSimulationController.ts';
import { handleGoalAnalysis } from './goalAnalysisSimulationController.ts';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
};

//에러 응답 표준 포맷터
function errorResponse(message: string, status: number) {
  return new Response(
    JSON.stringify({
      data: null,
      error: { message },
    }),
    {
      status,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    }
  );
}

Deno.serve(async (req: Request) => {
  const url = new URL(req.url);

  // CORS 프리플라이트 처리
  if (req.method === 'OPTIONS') {
    return new Response(null, { status: 204, headers: corsHeaders });
  }

  try {
    if (req.method === 'POST') {
      if (url.pathname.endsWith('/goal-analysis')) {
        return await handleGoalAnalysis(req);
      }

      // 그 외 기본 POST 요청은 몬테카를로 시뮬레이션 핸들러 호출
      return await handleSimulation(req);
    }

    return errorResponse('Method not allowed or endpoint not found', 405);
  } catch (err: unknown) {
    // 검증 실패, 통계 오류 등 모든 에러를 여기서 중앙 집중 처리
    const message = err instanceof Error ? err.message : 'Internal Server Error';

    // 에러 메시지 키워드를 통해 클라이언트 에러(400)와 서버 에러(500)를 구분
    const isClientError =
      message.includes('must') ||
      message.includes('invalid') ||
      message.includes('required') ||
      message.includes('Statistical') ||
      message.includes('누락') ||
      message.includes('VALIDATION_ERROR');

    return errorResponse(message, isClientError ? 400 : 500);
  }
});
