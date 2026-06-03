import { handleGetProfile, handleUpdateProfile, handleDeleteProfile } from './profileController.ts';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'GET, POST, PATCH, PUT, DELETE, OPTIONS',
};

Deno.serve((req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response(null, {
      status: 204,
      headers: corsHeaders,
    });
  }

  if (req.method === 'GET') {
    return handleGetProfile(req);
  }

  if (req.method === 'POST') {
    return handleUpdateProfile(req);
  }

  if (req.method === 'DELETE') {
    return handleDeleteProfile(req);
  }

  return new Response('Not Found', {
    status: 404,
    headers: corsHeaders,
  });
});
