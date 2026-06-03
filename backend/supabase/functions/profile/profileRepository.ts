import { Profile } from '../../../shared/domain/profile/Profile.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

export function createAuthClient(authHeader: string) {
  return createClient(Deno.env.get('SUPABASE_URL')!, Deno.env.get('SUPABASE_ANON_KEY')!, {
    global: {
      headers: {
        Authorization: authHeader,
      },
    },
  });
}

function createAdminClient() {
  return createClient(Deno.env.get('SUPABASE_URL')!, Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!);
}

export async function findUserById(authHeader: string, userId: string): Promise<Profile | null> {
  const client = createAuthClient(authHeader);

  const { data: profileData, error: profileError } = await client
    .from('profiles')
    .select('display_name')
    .eq('id', userId)
    .single();

  if (profileError || !profileData) return null;

  const {
    data: { user },
    error: authError,
  } = await client.auth.getUser();

  if (authError || !user || !user.email) return null;

  return new Profile(user.email, profileData.display_name);
}

export async function updateProfileRepo(
  authHeader: string,
  userId: string,
  updateData: { display_name?: string }
) {
  const client = createAuthClient(authHeader);

  const { error } = await client.from('profiles').update(updateData).eq('id', userId);
  return !error;
}

export async function deleteProfileRepo(authHeader: string, userId: string) {
  const client = createAuthClient(authHeader);

  const { data, error } = await client.from('profiles').delete().eq('id', userId).select();

  if (error || !data || data.length === 0) return false;
  return true;
}

export async function deleteAuthRepo(userId: string) {
  const client = createAdminClient();

  const { error } = await client.auth.admin.deleteUser(userId);
  return !error;
}
