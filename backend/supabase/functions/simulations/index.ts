import { handleSimulation } from './simulationController.ts';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
};

class ValidationError extends Error {}
class StatisticalError extends Error {}
class MethodNotAllowedError extends Error {}

function errorResponse(message: string, status: number) {
  const codeMap: Record<number, string> = {
    400: 'BAD_REQUEST',
    405: 'METHOD_NOT_ALLOWED',
    500: 'INTERNAL_SERVER_ERROR',
  };

  return new Response(
    JSON.stringify({
      error: {
        code: codeMap[status] || 'UNKNOWN_ERROR',
        message,
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
    if (req.method === 'POST') {
      return await handleSimulation(req);
    }

    throw new MethodNotAllowedError('POST 또는 OPTIONS 요청만 허용됩니다.');
  } catch (err: unknown) {
    let status = 500;
    let message = 'Unknown Internal Error';

    if (err instanceof ValidationError || err instanceof StatisticalError) {
      status = 400;
      message = err.message;
    } else if (err instanceof MethodNotAllowedError) {
      status = 405;
      message = err.message;
    } else if (err instanceof Error) {
      message = err.message;
    }

    return errorResponse(message, status);
  }
});
