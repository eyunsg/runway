import { Profile } from '../../../shared/domain/profile/Profile.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

function createAdminClient() {
  return createClient(Deno.env.get('SUPABASE_URL')!, Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!);
}

export async function findUserById(userId: string): Promise<Profile | null> {
  const client = createAdminClient();

  const { data: profileData, error: profileError } = await client
    .from('profiles')
    .select('display_name')
    .eq('id', userId)
    .single();

  if (profileError || !profileData) return null;

  const { data: authData, error: authError } = await client.auth.admin.getUserById(userId);

  if (authError || !authData?.user?.email) return null;

  return new Profile(authData.user.email, profileData.display_name);
}

export async function updateProfileRepo(
  userId: string,
  updateData: { display_name?: string }
): Promise<Profile | null> {
  const client = createAdminClient();

  // 1. DB의 profiles 테이블 업데이트 실행
  const { error } = await client.from('profiles').update(updateData).eq('id', userId);

  if (error) {
    console.error('DB_UPDATE_ERROR:', error.message);
    return null;
  }

  // 2. 업데이트 완료 후 최신 정보를 다시 조회하여 반환 (무결성 보장)
  return await findUserById(userId);
}

export async function deleteProfileRepo(userId: string) {
  const client = createAdminClient();

  const { error } = await client.from('profiles').delete().eq('id', userId);
  return !error;
}

export async function deleteAuthRepo(userId: string) {
  const client = createAdminClient();

  const { error } = await client.auth.admin.deleteUser(userId);
  return !error;
}
