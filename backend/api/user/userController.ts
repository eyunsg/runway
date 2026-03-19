import { getProfile } from './userService';

export async function handleGetProfile(req: Request) {
  try {
    const userId = new URL(req.url).searchParams.get('userId');
    if (!userId) return new Response('Missing userId', { status: 400 });

    const responseDto = await getProfile(userId);
    return new Response(JSON.stringify(responseDto), {
      status: 200,
      headers: { 'Content-Type': 'application/json' },
    });
  } catch (err) {
    return new Response(String(err), { status: 500 });
  }
}
