import { handleSimulation } from './monteCarloSimulationController.ts';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
};

Deno.serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response(null, {
      status: 204,
      headers: corsHeaders,
    });
  }

  if (req.method === 'POST') {
    return await handleSimulation(req);
  }

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
