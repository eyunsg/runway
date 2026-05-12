import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

function createAuthClient(authHeader: string) {
  return createClient(Deno.env.get('SUPABASE_URL')!, Deno.env.get('SUPABASE_ANON_KEY')!, {
    global: { headers: { Authorization: authHeader } },
  });
}

export async function softDeleteCommentRepo(
  authHeader: string,
  commentId: string
): Promise<boolean> {
  const client = createAuthClient(authHeader);

  const { error, status } = await client
    .from('comments')
    .update({
      deleted_at: new Date().toISOString(),
    })
    .eq('id', commentId);

  if (error) {
    console.error(`[DeleteCommentRepo Error]: ${error.message}`);
    throw new Error(`DATABASE_ERROR: ${error.message}`);
  }

  // 성공 시 보통 204 또는 200 응답
  return status >= 200 && status < 300;
}
