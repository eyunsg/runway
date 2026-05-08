import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';
import { Post } from '../../../shared/domain/posts/Post.ts';

function createAdminClient() {
  return createClient(Deno.env.get('SUPABASE_URL')!, Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!);
}

//마이그레이션에 정의된 RLS 정책을 활성화하여 조회할 때 사용
function createAuthClient(authHeader: string) {
  return createClient(Deno.env.get('SUPABASE_URL')!, Deno.env.get('SUPABASE_ANON_KEY')!, {
    global: { headers: { Authorization: authHeader } },
  });
}

// 모든 게시글 조회
export async function findAllPostsRepo(authHeader: string) {
  const client = createAuthClient(authHeader);

  const { data, error } = await client
    .from('posts')
    .select(
      `
      id,
      user_id,
      portfolio_snapshot_id,
      content,
      comments_count,
      created_at,
      profiles:user_id (display_name),
      portfolio_snapshots:portfolio_snapshot_id (
        id,
        portfolios:portfolio_id (
          name,
          simulation_input
        )
      )
    `
    )
    .is('deleted_at', null)
    .order('created_at', { ascending: false });

  if (error) {
    console.error(`[PostsRepo Error - Find All]: ${error.message}`);
    throw new Error(`DATABASE_ERROR: ${error.message}`);
  }
  return data;
}

export async function findPostByIdRepo(authHeader: string, postId: string) {
  const client = createAuthClient(authHeader);

  const { data, error } = await client
    .from('posts')
    .select(
      `
      id,
      user_id,
      portfolio_snapshot_id,
      content,
      comments_count,
      created_at,
      profiles:user_id (display_name),
      portfolio_snapshots:portfolio_snapshot_id (
        id,
        snapshot_data,
        portfolios:portfolio_id (
          name,
          simulation_input
        )
      )
    `
    )
    .eq('id', postId)
    .is('deleted_at', null)
    .single();

  if (error) {
    // 결과가 없는 경우 null 반환 (PGRST116: JSON object requested, but 0 rows returned)
    if (error.code === 'PGRST116') return null;

    console.error(`[PostsRepo Error - Find By Id]: ${error.message}`);
    throw new Error(`DATABASE_ERROR: 게시글 정보를 불러오는 중 오류가 발생했습니다.`);
  }
  return data;
}

export async function updatePostRepo(
  authHeader: string,
  postId: string,
  content: string
): Promise<boolean> {
  const client = createAuthClient(authHeader);

  const { data, error } = await client
    .from('posts')
    .update({
      content,
      updated_at: new Date().toISOString(),
    })
    .eq('id', postId)
    .is('deleted_at', null)
    .select(); // RLS 정책에 의해 본인이 아니면 수정 결과가 반환되지 않음

  if (error) {
    console.error(`[PostsRepo Error - Update]: ${error.message}`);
    throw new Error(`DATABASE_ERROR: 게시글 수정 중 오류가 발생했습니다.`);
  }

  // 데이터가 1개라도 반환되었다면 권한이 있고 수정에 성공했다는 의미
  return data !== null && data.length > 0;
}

export async function findAllMyPostsRepo(authHeader: string, userId: string) {
  const client = createAuthClient(authHeader);

  const { data, error } = await client
    .from('posts')
    .select(
      `
      id,
      content,
      user_id,
      comments_count,
      created_at,
      profiles:user_id (display_name),
      portfolio_snapshots:portfolio_snapshot_id (
        portfolios:portfolio_id (
          name,
          simulation_input
        )
      )
    `
    )
    .eq('user_id', userId)
    .is('deleted_at', null)
    .order('created_at', { ascending: false });

  if (error) {
    console.error(`[PostsRepo Error - Find My Posts]: ${error.message}`);
    throw new Error(`DATABASE_ERROR: 내 게시글 목록을 불러오는 중 오류가 발생했습니다.`);
  }
  return data;
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
