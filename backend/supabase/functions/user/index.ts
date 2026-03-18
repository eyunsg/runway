// import 'jsr:@supabase/functions-js/edge-runtime.d.ts';
import { handleGetProfile } from './userController.ts';

Deno.serve((req: Request) => {
  const url = new URL(req.url);

  if (req.method === 'GET' && url.pathname === '/profile') {
    return handleGetProfile(req);
  }

  return new Response('Not Found', { status: 404 });
});
