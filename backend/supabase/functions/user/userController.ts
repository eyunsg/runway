import { getProfile } from './userService.ts';

export async function handleGetProfile(req: Request): Promise<Response> {
  try {
    const url = new URL(req.url);
    const userId = url.searchParams.get('userId');

    if (!userId) {
      throw new Error('userId가 없습니다.');
    }

    const profile = await getProfile(userId);

    return new Response(
      JSON.stringify({
        data: profile,
        error: null,
      }),
      {
        status: 200,
        headers: { 'Content-Type': 'application/json' },
      }
    );
  } catch (err: unknown) {
    const error = err as Error;
    console.error(error.message ?? error);

    return new Response(
      JSON.stringify({
        data: null,
        error: error.message ?? '알 수 없는 에러',
      }),
      {
        status: 500,
      }
    );
  }
}
