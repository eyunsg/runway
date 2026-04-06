import { handleSimulation } from './simulationController.ts';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
};

// 에러 응답 표준 포맷터
function errorResponse(message: string, status: number) {
  return new Response(
    JSON.stringify({
      error: {
        code: 'METHOD_NOT_ALLOWED',
        message: 'POST 또는 OPTIONS 요청만 허용됩니다.',
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
    // 이제 하나의 POST 요청으로 모든 시뮬레이션(몬테카를로 + 목표분석) 처리
    if (req.method === 'POST') {
      return await handleSimulation(req);
    }

    return errorResponse('Method not allowed', 405);
  } catch (err: unknown) {
    // 모든 에러를 중앙 집중 처리
    const message = err instanceof Error ? err.message : 'Unknown Internal Error';

    // 에러 메시지 키워드를 통해 400(클라이언트)과 500(서버) 에러 구분
    const isClientError =
      message.includes('VALIDATION') ||
      message.includes('Statistical') ||
      message.includes('must') ||
      message.includes('invalid') ||
      message.includes('required');

    return errorResponse(message, isClientError ? 400 : 500);
  }
});
