import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

export interface CommentInsertRow {
  content: string;
  post_id: string;
  user_id: string;
  created_at?: string;
}

function createAuthClient(authHeader: string) {
  return createClient(Deno.env.get('SUPABASE_URL')!, Deno.env.get('SUPABASE_ANON_KEY')!, {
    global: { headers: { Authorization: authHeader } },
  });
}

export async function createCommentRepo(authHeader: string, dbRow: CommentInsertRow) {
  const client = createAuthClient(authHeader);

  const { error } = await client.from('comments').insert(dbRow);

  if (error) {
    console.error(`[CreateCommentRepo Error]: ${error.message}`);
    throw new Error(`DATABASE_ERROR: ${error.message}`);
  }
}
