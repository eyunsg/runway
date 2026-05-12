import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';
import { Comment, type CommentDbRow } from '../../../shared/domain/get_comments/Comment.ts';

function createAuthClient(authHeader: string) {
  return createClient(Deno.env.get('SUPABASE_URL')!, Deno.env.get('SUPABASE_ANON_KEY')!, {
    global: { headers: { Authorization: authHeader } },
  });
}

export async function findCommentsByPostIdRepo(authHeader: string, postId: string) {
  const client = createAuthClient(authHeader);

  const { data, error } = await client
    .from('comments')
    .select(
      `
      id,
      post_id,
      content,
      created_at,
      user_id,
      profiles:user_id (display_name)
    `
    )
    .eq('post_id', postId)
    .is('deleted_at', null)
    .order('created_at', { ascending: true });

  if (error) {
    console.error(`[GetCommentsRepo Error - Find By Post Id]: ${error.message}`);
    throw new Error(`DATABASE_ERROR: ${error.message}`);
  }

  const rows = (data ?? []) as unknown as CommentDbRow[];
  return Comment.fromDbRows(rows);
}
