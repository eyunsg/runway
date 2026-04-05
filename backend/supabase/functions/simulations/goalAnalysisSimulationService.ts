import { AssetInputDto } from '../../../shared/dto/simulations/MonteCarloSimulationRequest.dto.ts';
import { SimulationGoalDto } from '../../../shared/dto/simulations/GoalAnalysisSimulationRequest.dto.ts';

const MAX_LIMIT_MONTHS = 600;

interface AssetState {
  price: number;
  shares: number;
  cash: number;
  dividendPerShare: number;
  accumulatedDividends: number; // 재투자하지 않은 배당금 누적액
}

export class GoalAnalysisSimulationService {
  /**
   * [API-SIM-001] 목표 달성 분석 서비스
   * 명확한 변수명(Amount, Month 등)을 사용하여 비즈니스 로직의 가독성을 높였습니다.
   */
  public analyzeGoalAchievement(assets: AssetInputDto[], goal: SimulationGoalDto) {
    // 1. 각 자산별 상태 초기화
    const states: AssetState[] = assets.map((a) => ({
      price: a.initialPrice,
      shares: 0,
      cash: 0,
      dividendPerShare: a.dividendPerShare,
      accumulatedDividends: 0,
    }));

    let reachedPortfolioAmountMonth: number | null = null;
    let reachedMonthlyDividendAmountMonth: number | null = null;

    const hasDividendAssets = assets.some((a) => a.isDividendAsset);

    // 2. 최대 600개월까지 월 단위 시뮬레이션 수행
    for (let m = 1; m <= MAX_LIMIT_MONTHS; m++) {
      let currentTotalPortfolioAmount = 0;
      let currentTotalMonthlyDividendAmount = 0;

      for (let i = 0; i < assets.length; i++) {
        const asset = assets[i];
        const state = states[i];

        // 2-1. 가격 및 배당금 성장 반영 (2개월차부터 적용)
        if (m > 1) {
          const monthlyGrowth = Math.pow(1 + asset.expectedAnnualPriceGrowthRate / 100, 1 / 12) - 1;
          const monthlyDivGrowth =
            Math.pow(1 + asset.expectedAnnualDividendGrowthRate / 100, 1 / 12) - 1;
          state.price *= 1 + monthlyGrowth;
          state.dividendPerShare *= 1 + monthlyDivGrowth;
        }

        // 2-2. 가용 투자금 확보 (초기 투자금 또는 매월 적립금)
        let investPool = m === 1 ? asset.initialInvestmentAmount : asset.monthlyContributionAmount;
        investPool += state.cash;

        // 2-3. 배당금 수령 및 재투자 처리
        const isDividendMonth = m % (12 / asset.dividendFrequencyPerYear) === 0;
        if (asset.isDividendAsset && isDividendMonth) {
          const receivedDiv = state.shares * state.dividendPerShare;
          if (asset.isReinvestDividends) {
            investPool += receivedDiv;
          } else {
            // [에러 방지] 재투자하지 않는 배당금은 별도 자산으로 누적하여 전체 가치에 포함시킵니다.
            state.accumulatedDividends += receivedDiv;
          }
        }

        // 2-4. 주식 매수 수행 (정수 단위)
        const buyableShares = Math.floor(investPool / state.price);
        state.shares += buyableShares;
        state.cash = investPool % state.price;

        // 2-5. 현재 시점 포트폴리오 가치 합산 (주식 가치 + 잔여 현금 + 누적 배당금)
        currentTotalPortfolioAmount +=
          state.price * state.shares + state.cash + state.accumulatedDividends;

        if (asset.isDividendAsset) {
          // 월평균 환산 배당금 합산
          currentTotalMonthlyDividendAmount +=
            (state.shares * state.dividendPerShare * asset.dividendFrequencyPerYear) / 12;
        }
      }

      // 3. 목표 도달 여부 체크 (부동 소수점 오차 방지를 위해 미세한 여유값 적용)
      if (
        reachedPortfolioAmountMonth === null &&
        currentTotalPortfolioAmount >= goal.targetPortfolioAmount - 0.00001
      ) {
        reachedPortfolioAmountMonth = m;
      }

      if (
        hasDividendAssets &&
        reachedMonthlyDividendAmountMonth === null &&
        currentTotalMonthlyDividendAmount >= goal.targetMonthlyDividendAmount - 0.00001
      ) {
        reachedMonthlyDividendAmountMonth = m;
      }

      // 4. 모든 목표 달성 시 루프 조기 종료
      if (
        reachedPortfolioAmountMonth !== null &&
        (!hasDividendAssets || reachedMonthlyDividendAmountMonth !== null)
      ) {
        break;
      }
    }

    return {
      reachedPortfolioAmountMonth,
      reachedMonthlyDividendAmountMonth,
    };
  }
}
