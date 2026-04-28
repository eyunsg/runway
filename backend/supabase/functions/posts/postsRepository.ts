import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';
import { Post } from '../../../shared/domain/posts/Post.ts';

function createAdminClient() {
  return createClient(Deno.env.get('SUPABASE_URL')!, Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!);
}

export async function createPortfolioSnapshotRepo(
  userId: string,
  portfolioId: string
): Promise<string | null> {
  const client = createAdminClient();

  // 1. 원본 포트폴리오 데이터 조회
  const { data: portfolio, error: fetchError } = await client
    .from('portfolios')
    .select('name, simulation_input, simulation_result')
    .eq('id', portfolioId)
    .eq('user_id', userId)
    .is('deleted_at', null)
    .single();

  if (fetchError || !portfolio) {
    console.error(`[PostsRepo Error - Fetch Portfolio]: ${fetchError?.message}`);
    return null;
  }

  // 2. 스냅샷 생성 (게시 시점의 데이터 보존)
  const { data: snapshot, error: insertError } = await client
    .from('portfolio_snapshots')
    .insert({
      portfolio_id: portfolioId,
      snapshot_data: {
        name: portfolio.name,
        simulation_input: portfolio.simulation_input,
        simulation_result: portfolio.simulation_result,
      },
    })
    .select('id')
    .single();

  if (insertError || !snapshot) {
    console.error(`[PostsRepo Error - Create Snapshot]: ${insertError?.message}`);
    return null;
  }

  return snapshot.id;
}

export async function savePostRepo(post: Post): Promise<string | null> {
  const client = createAdminClient();

  const { data, error } = await client
    .from('posts')
    .insert({
      user_id: post.userId,
      portfolio_snapshot_id: post.portfolioSnapshotId,
      content: post.content,
      comments_count: 0,
    })
    .select('id')
    .single();

  if (error || !data) {
    console.error(`[PostsRepo Error - Save Post]: ${error?.message}`);
    return null;
  }

  return data.id;
}
