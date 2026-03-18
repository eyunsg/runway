import { createClient } from 'jsr:@supabase/supabase-js';

const supabase = createClient(Deno.env.get('SUPABASE_URL')!, Deno.env.get('SUPABASE_ANON_KEY')!);

export async function findUserById(userId: string) {
  const { data, error } = await supabase.from('profiles').select('*').eq('id', userId).single();

  if (error) {
    throw error;
  }

  return data;
}
