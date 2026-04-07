import { Portfolio } from '../../../shared/domain/portfolios/Portfolios.ts';
import { AddPortfolioRequestDto } from '../../../shared/dto/portfolios/PostPortfoliosRequest.dto.ts';
import {
  savePortfolioRepo,
  getPortfoliosRepo,
  getPortfolioDetailRepo,
} from './portfoliosRepository.ts';
import {
  GetPortfoliosResponseDto,
  PortfolioSummaryDto,
} from '../../../shared/dto/portfolios/GetPortfoliosResponse.dto.ts';
import { GetPortfolioDetailResponseDto } from '../../../shared/dto/portfolios/GetPortfoliosDetailResponse.dto.ts';

interface RawPortfolioRecord {
  id: string;
  name: string;
  simulation_input: {
    goal?: {
      investment_period_months?: number;
    };
    assets?: unknown[]; // 자산의 개수만 필요하므로 unknown 배열로 정의
  };
  updated_at: string;
}

// 상세조회를 위한 인터페이스
interface RawPortfolioDetailRecord {
  id: string;
  user_id: string;
  name: string;
  simulation_input: {
    goal: {
      investment_period_months: number;
      target_portfolio_value: number;
      target_monthly_dividend: number;
    };
    assets: Array<{
      asset_name: string;
      asset_type: string;
      initial_price: number;
      expected_annual_price_growth_rate: number;
      initial_investment_amount: number;
      monthly_contribution_amount: number;
      is_dividend_asset: boolean;
      dividend_per_share: number;
      expected_annual_dividend_growth_rate: number;
      dividend_frequency: number;
      is_reinvest_dividends: boolean;
    }>;
  };
  simulation_result: {
    percentiles: {
      portfolio_value: { p10: number; p50: number; p90: number };
      monthly_dividend: { p10: number; p50: number; p90: number };
    };
    goal_analysis: {
      portfolio_value_goal: {
        achievement_probability?: number;
        expected_months_to_target: number;
      };
      monthly_dividend_goal: {
        achievement_probability?: number;
        expected_months_to_target: number;
      };
    };
  };
  created_at: string;
  updated_at: string;
}

export async function addPortfolioService(
  userId: string,
  dto: AddPortfolioRequestDto
): Promise<string> {
  // 1. DTO 데이터를 도메인 모델로 변환
  // 이 과정에서 Portfolio 클래스 내부의 validate()가 호출되어 이름, 자산 개수 등 검증
  const portfolio = new Portfolio(userId, dto.name, dto.simulationInput, dto.simulationResult);

  // 2. 도메인 객체를 리포지토리에 전달하여 저장 위임
  const portfolioId = await savePortfolioRepo(portfolio);

  // 3. 저장 실패 시 예외 발생 (Entry Point에서 500 에러로 처리됨)
  if (!portfolioId) {
    throw new Error('DATABASE_ERROR: 포트폴리오 저장 실패');
  }

  return portfolioId;
}

export async function getPortfoliosService(userId: string): Promise<GetPortfoliosResponseDto> {
  // 1. 리포지토리에서 해당 사용자의 데이터 조회 (배열 형태)
  const rawData = await getPortfoliosRepo(userId);

  if (!rawData) {
    throw new Error('DATABASE_ERROR: 포트폴리오 목록 조회 실패');
  }

  // 2. DB 로우 데이터를 PortfolioSummaryDto 형식으로 매핑
  const summaries = (rawData as RawPortfolioRecord[]).map((item: RawPortfolioRecord) => {
    // DB의 snake_case 구조에서 필요한 값을 추출
    const assets = item.simulation_input?.assets || [];
    const goal = item.simulation_input?.goal || {};

    const assetCount = assets.length;
    const investmentPeriodMonths = goal.investment_period_months || 0;

    return new PortfolioSummaryDto(
      item.id,
      item.name,
      assetCount,
      investmentPeriodMonths,
      item.updated_at
    );
  });

  // 3. 최종 DTO를 생성하여 반환
  return new GetPortfoliosResponseDto(summaries);
}

export async function getPortfolioDetailService(
  userId: string,
  portfolioId: string
): Promise<GetPortfolioDetailResponseDto> {
  const rawData = await getPortfolioDetailRepo(userId, portfolioId);

  // 데이터가 없거나 권한이 없는 경우
  if (!rawData) {
    throw new Error('NOT_FOUND: 요청하신 포트폴리오를 찾을 수 없습니다.');
  }

  const data = rawData as unknown as RawPortfolioDetailRecord;
  const input = data.simulation_input;
  const result = data.simulation_result;

  // DB(snake_case) 구조에서 응답(camelCase) 구조로 정밀 매핑
  const simulationInput = {
    goal: {
      investmentPeriodMonths: input.goal.investment_period_months,
      targetPortfolioValue: input.goal.target_portfolio_value,
      targetMonthlyDividend: input.goal.target_monthly_dividend,
    },
    assets: input.assets.map((asset) => ({
      assetName: asset.asset_name,
      assetType: asset.asset_type,
      initialPrice: asset.initial_price,
      expectedAnnualPriceGrowthRate: asset.expected_annual_price_growth_rate,
      initialInvestmentAmount: asset.initial_investment_amount,
      monthlyContributionAmount: asset.monthly_contribution_amount,
      isDividendAsset: asset.is_dividend_asset,
      dividendPerShare: asset.dividend_per_share,
      expectedAnnualDividendGrowthRate: asset.expected_annual_dividend_growth_rate,
      dividendFrequency: asset.dividend_frequency,
      isReinvestDividends: asset.is_reinvest_dividends,
    })),
  };

  const simulationResult = {
    percentiles: {
      portfolioValue: {
        p10: result.percentiles.portfolio_value.p10,
        p50: result.percentiles.portfolio_value.p50,
        p90: result.percentiles.portfolio_value.p90,
      },
      monthlyDividend: {
        p10: result.percentiles.monthly_dividend.p10,
        p50: result.percentiles.monthly_dividend.p50,
        p90: result.percentiles.monthly_dividend.p90,
      },
    },
    goalAnalysis: {
      portfolioValueGoal: {
        target: input.goal.target_portfolio_value,
        achievementProbability:
          result.goal_analysis.portfolio_value_goal.achievement_probability || 0,
        expectedMonthsToTarget: result.goal_analysis.portfolio_value_goal.expected_months_to_target,
      },
      monthlyDividendGoal: {
        target: input.goal.target_monthly_dividend,
        achievementProbability:
          result.goal_analysis.monthly_dividend_goal.achievement_probability || 0,
        expectedMonthsToTarget:
          result.goal_analysis.monthly_dividend_goal.expected_months_to_target,
      },
    },
  };

  // 최종 DTO 생성 및 반환
  return new GetPortfolioDetailResponseDto(data.name, simulationInput, simulationResult);
}
