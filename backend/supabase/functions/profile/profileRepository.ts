import { Profile } from '../../../shared/domain/profile/Profile.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const supabase = createClient(
  Deno.env.get('SUPABASE_URL')!,
  Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
);

export async function findUserById(userId: string): Promise<Profile | null> {
  const { data: profileData, error: profileError } = await supabase
    .from('profiles')
    .select('display_name')
    .eq('id', userId)
    .single();

  if (profileError || !profileData) return null;

  const { data: authData, error: authError } = await supabase.auth.admin.getUserById(userId);

  if (authError || !authData?.user?.email) return null;

  return new Profile(authData.user.email, profileData.display_name);
}

export async function deleteProfileRepo(client: any, userId: string) {
  const { error } = await client.from('profiles').delete().eq('id', userId);

  return !error;
}

export async function deleteAuthRepo(client: any, userId: string) {
  const { error } = await client.auth.admin.deleteUser(userId);
  return !error;
}
