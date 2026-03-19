import { User } from './domain/user.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const supabase = createClient(
  Deno.env.get('SUPABASE_URL')!,
  Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
);

export async function findUserById(userId: string): Promise<User | null> {
  const { data: profileData, error: profileError } = await supabase
    .from('profiles')
    .select('displayName')
    .eq('id', userId)
    .single();

  if (profileError || !profileData?.displayName) return null;

  const { data: authData, error: authError } = await supabase.auth.admin.getUserById(userId);

  if (authError || !authData?.user?.email) return null;

  return new User(authData.user.email, profileData.displayName);
}
