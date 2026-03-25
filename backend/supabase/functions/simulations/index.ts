import { handleSimulation } from './monteCarloSimulationController.ts';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
};

Deno.serve(async (req: Request) => {
  // 1. CORS Preflight 처리
  if (req.method === 'OPTIONS') {
    return new Response(null, {
      status: 204,
      headers: corsHeaders,
    });
  }

  // 2. 라우팅
  if (req.method === 'POST') {
    // 컨트롤러가 표준 응답 규격(data/error)과 에러 처리를 담당하므로 직접 호출합니다.
    return await handleSimulation(req);
  }

  // 3. 허용되지 않은 Method 또는 잘못된 경로 처리
  return new Response(
    JSON.stringify({
      data: null,
      error: { message: 'Method not allowed or endpoint not found' },
    }),
    {
      status: 405,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    }
  );
});
