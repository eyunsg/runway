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

  // 1. 댓글 조회
  const { data: comment, error: findError } = await client
    .from('comments')
    .select('id, user_id, deleted_at')
    .eq('id', commentId)
    .single();

  if (findError || !comment) {
    throw new Error('COMMENT_NOT_FOUND');
  }

  // 2. 이미 삭제 여부
  if (comment.deleted_at) {
    throw new Error('COMMENT_ALREADY_DELETED');
  }

  // 3. 현재 유저 확인
  const {
    data: { user },
  } = await client.auth.getUser();

  if (!user) {
    throw new Error('UNAUTHORIZED');
  }

  // 4. 작성자 검증
  if (comment.user_id !== user.id) {
    throw new Error('COMMENT_DELETE_FORBIDDEN');
  }

  // 5. soft delete
  const { error: deleteError } = await client
    .from('comments')
    .update({
      deleted_at: new Date().toISOString(),
    })
    .eq('id', commentId);

  if (deleteError) {
    throw new Error(`DATABASE_ERROR: ${deleteError.message}`);
  }

  return true;
}
