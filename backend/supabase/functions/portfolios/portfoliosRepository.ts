import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';
import { Portfolio } from '../../../shared/domain/portfolios/Portfolios.ts';

function createAuthClient(authHeader: string) {
  return createClient(Deno.env.get('SUPABASE_URL')!, Deno.env.get('SUPABASE_ANON_KEY')!, {
    global: {
      headers: {
        Authorization: authHeader,
      },
    },
  });
}

export async function savePortfolioRepo(
  authHeader: string,
  portfolio: Portfolio
): Promise<string | null> {
  const client = createAuthClient(authHeader);
  type PortfolioAsset = Portfolio['simulationInput']['assets'][number];

  const { data, error } = await client
    .from('portfolios')
    .insert({
      user_id: portfolio.userId,
      name: portfolio.name,
      simulation_input: {
        goal: {
          investment_period_months: portfolio.simulationInput.goal.investmentPeriodMonths,
          target_portfolio_value: portfolio.simulationInput.goal.targetPortfolioValue,
          target_monthly_dividend: portfolio.simulationInput.goal.targetMonthlyDividend,
        },
        assets: portfolio.simulationInput.assets.map((asset: PortfolioAsset) => ({
          asset_name: asset.assetName,
          asset_type: asset.assetType,
          initial_price: asset.initialPrice,
          expected_annual_price_growth_rate: asset.expectedAnnualPriceGrowthRate,
          initial_investment_amount: asset.initialInvestmentAmount,
          monthly_contribution_amount: asset.monthlyContributionAmount,
          is_dividend_asset: asset.isDividendAsset,
          dividend_per_share: asset.dividendPerShare,
          expected_annual_dividend_growth_rate: asset.expectedAnnualDividendGrowthRate,
          dividend_frequency: asset.dividendFrequency,
          is_reinvest_dividends: asset.isReinvestDividends,
        })),
      },
      simulation_result: {
        percentiles: {
          portfolio_value: portfolio.simulationResult.percentiles.portfolioValue,
          monthly_dividend: portfolio.simulationResult.percentiles.monthlyDividend,
        },
        goal_analysis: {
          // 내부 필드인 expectedMonthsToTarget까지 snake_case로 매핑하여 DB 일관성 유지
          portfolio_value_goal: {
            expected_months_to_target:
              portfolio.simulationResult.goalAnalysis.portfolioValueGoal.expectedMonthsToTarget,
          },
          monthly_dividend_goal: {
            expected_months_to_target:
              portfolio.simulationResult.goalAnalysis.monthlyDividendGoal.expectedMonthsToTarget,
          },
        },
      },
    })
    .select('id')
    .single();

  if (error || !data) {
    console.error(`[PortfolioRepo Error]: ${error?.message}`);
    return null;
  }

  return data.id;
}

export async function updatePortfolioRepo(
  authHeader: string,
  portfolio: Portfolio,
  portfolioId: string
): Promise<boolean> {
  const client = createAuthClient(authHeader);
  type PortfolioAsset = Portfolio['simulationInput']['assets'][number];

  const { data, error } = await client
    .from('portfolios')
    .update({
      name: portfolio.name,
      simulation_input: {
        goal: {
          investment_period_months: portfolio.simulationInput.goal.investmentPeriodMonths,
          target_portfolio_value: portfolio.simulationInput.goal.targetPortfolioValue,
          target_monthly_dividend: portfolio.simulationInput.goal.targetMonthlyDividend,
        },
        assets: portfolio.simulationInput.assets.map((asset: PortfolioAsset) => ({
          asset_name: asset.assetName,
          asset_type: asset.assetType,
          initial_price: asset.initialPrice,
          expected_annual_price_growth_rate: asset.expectedAnnualPriceGrowthRate,
          initial_investment_amount: asset.initialInvestmentAmount,
          monthly_contribution_amount: asset.monthlyContributionAmount,
          is_dividend_asset: asset.isDividendAsset,
          dividend_per_share: asset.dividendPerShare,
          expected_annual_dividend_growth_rate: asset.expectedAnnualDividendGrowthRate,
          dividend_frequency: asset.dividendFrequency,
          is_reinvest_dividends: asset.isReinvestDividends,
        })),
      },
      simulation_result: {
        percentiles: {
          portfolio_value: portfolio.simulationResult.percentiles.portfolioValue,
          monthly_dividend: portfolio.simulationResult.percentiles.monthlyDividend,
        },
        goal_analysis: {
          portfolio_value_goal: {
            expected_months_to_target:
              portfolio.simulationResult.goalAnalysis.portfolioValueGoal.expectedMonthsToTarget,
          },
          monthly_dividend_goal: {
            expected_months_to_target:
              portfolio.simulationResult.goalAnalysis.monthlyDividendGoal.expectedMonthsToTarget,
          },
        },
      },
      updated_at: new Date().toISOString(), // 수정 시각 갱신
    })
    .eq('id', portfolioId)
    .eq('user_id', portfolio.userId) // 보안: 본인 소유 확인
    .is('deleted_at', null)
    .select();

  if (error || !data || data.length === 0) {
    console.error(`[PortfolioRepo Error - Update]: ${error?.message}`);
    return false;
  }
  return true;
}

export async function getPortfoliosRepo(authHeader: string, userId: string) {
  const client = createAuthClient(authHeader);

  const { data, error } = await client
    .from('portfolios')
    .select('id, name, simulation_input, updated_at')
    .eq('user_id', userId)
    .is('deleted_at', null)
    .order('updated_at', { ascending: false });

  if (error) {
    console.error(`[PortfolioRepo Error - Fetch]: ${error.message}`);
    return null;
  }

  return data;
}

export async function getPortfolioDetailRepo(
  authHeader: string,
  userId: string,
  portfolioId: string
) {
  const client = createAuthClient(authHeader);

  const { data, error } = await client
    .from('portfolios')
    .select('*') // 상세 조물이므로 모든 컬럼(*)을 가져옵니다.
    .eq('id', portfolioId)
    .eq('user_id', userId)
    .is('deleted_at', null)
    .single();

  if (error) {
    console.error(`[PortfolioRepo Error - Detail]: ${error.message}`);
    return null;
  }

  return data;
}

export async function getPortfolioSnapshotDetailRepo(
  authHeader: string,
  portfolioSnapshotId: string
) {
  const client = createAuthClient(authHeader);

  const { data, error } = await client
    .from('portfolio_snapshots')
    .select('snapshot_data')
    .eq('id', portfolioSnapshotId)
    .is('deleted_at', null)
    .single();

  if (error) {
    console.error(`[PortfolioRepo Error - Snapshot Detail]: ${error.message}`);
    return null;
  }

  return data;
}

export async function deletePortfolioRepo(
  authHeader: string,
  userId: string,
  portfolioId: string
): Promise<boolean> {
  const client = createAuthClient(authHeader);

  const { data, error } = await client
    .from('portfolios')
    .update({ deleted_at: new Date().toISOString() })
    .eq('id', portfolioId)
    .eq('user_id', userId) // 보안: 본인 소유 확인
    .is('deleted_at', null)
    .select();

  if (error || !data || data.length === 0) {
    console.error(`[PortfolioRepo Error - Delete]: ${error?.message}`);
    return false;
  }

  return true;
}

//특정 사용자의 최신 포트폴리오를 지정한 수량(limit)만큼 가져옴
//deleted_at이 null이고, updated_at 컬럼을 기준으로 내림차순 정렬하여 최신 데이터를 우선 조회
export async function getRecentPortfoliosRepo(authHeader: string, userId: string, limit: number) {
  const client = createAuthClient(authHeader);

  const { data, error } = await client
    .from('portfolios')
    .select('id, name, simulation_input, updated_at')
    .eq('user_id', userId)
    .is('deleted_at', null)
    .order('updated_at', { ascending: false })
    .limit(limit);

  if (error) {
    console.error(`[PortfolioRepo Error - Recent Fetch]: ${error.message}`);
    return null;
  }

  return data;
}
