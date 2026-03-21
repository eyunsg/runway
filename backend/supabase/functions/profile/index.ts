import { handleGetProfile } from './profileController.ts';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'GET, PATCH, OPTIONS',
};

Deno.serve((req: Request) => {
  console.log('index.ts: ', req);

  if (req.method === 'OPTIONS') {
    return new Response(null, {
      status: 204,
      headers: corsHeaders,
    });
  }

  if (req.method === 'GET') {
    return handleGetProfile(req);
  }

  return new Response('Not Found', {
    status: 404,
    headers: corsHeaders,
  });
});
