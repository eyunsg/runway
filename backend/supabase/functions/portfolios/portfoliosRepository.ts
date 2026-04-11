import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';
import { Portfolio } from '../../../shared/domain/portfolios/Portfolios.ts';

function createAdminClient() {
  return createClient(Deno.env.get('SUPABASE_URL')!, Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!);
}

export async function savePortfolioRepo(portfolio: Portfolio): Promise<string | null> {
  const client = createAdminClient();
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

export async function getPortfoliosRepo(userId: string) {
  const client = createAdminClient();

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
