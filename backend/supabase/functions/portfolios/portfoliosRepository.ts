import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';
import { Portfolio } from '../domain/portfolios/portfolios.ts';

function createAdminClient() {
  return createClient(Deno.env.get('SUPABASE_URL')!, Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!);
}

function mapToEntity(data: any): Portfolio {
  return new Portfolio(
    data.id,
    data.user_id,
    data.name,
    data.simulation_input,
    data.simulation_result,
    new Date(data.created_at),
    new Date(data.updated_at),
    data.deleted_at ? new Date(data.deleted_at) : null
  );
}

export async function createPortfolioRepo(
  userId: string,
  data: {
    name: string;
    simulation_input: any;
    simulation_result: any;
  }
): Promise<string> {
  const client = createAdminClient();

  const { data: insertedData, error } = await client
    .from('portfolios')
    .insert({
      user_id: userId,
      name: data.name,
      simulation_input: data.simulation_input,
      simulation_result: data.simulation_result,
    })
    .select('id')
    .single();

  if (error) {
    throw new Error(`DATABASE_ERROR: ${error.message}`);
  }

  return insertedData.id;
}

export async function findPortfolioByIdRepo(portfolioId: string): Promise<Portfolio | null> {
  const client = createAdminClient();

  const { data, error } = await client
    .from('portfolios')
    .select('*')
    .eq('id', portfolioId)
    .single();

  if (error || !data) return null;

  return mapToEntity(data);
}

export async function findPortfoliosByUserIdRepo(userId: string): Promise<Portfolio[]> {
  const client = createAdminClient();

  const { data, error } = await client
    .from('portfolios')
    .select('*')
    .eq('user_id', userId)
    .is('deleted_at', null)
    .order('created_at', { ascending: false });

  if (error || !data) return [];

  return data.map(mapToEntity);
}

export async function updatePortfolioRepo(
  portfolioId: string,
  updateData: {
    name?: string;
    simulation_input?: any;
    simulation_result?: any;
  }
) {
  const client = createAdminClient();

  const { error } = await client
    .from('portfolios')
    .update({
      ...updateData,
      updated_at: new Date().toISOString(),
    })
    .eq('id', portfolioId);

  return !error;
}

export async function deletePortfolioRepo(portfolioId: string) {
  const client = createAdminClient();

  const { error } = await client
    .from('portfolios')
    .update({
      deleted_at: new Date().toISOString(),
      updated_at: new Date().toISOString(),
    })
    .eq('id', portfolioId);

  return !error;
}
