const MAX_ANALYSIS_LIMIT = 600;

interface AssetParams {
  assetName: string;
  assetType: string;
  initialPrice: number;
  expectedAnnualPriceGrowthRate: number;
  initialInvestmentAmount: number;
  monthlyContributionAmount: number;
  isDividendAsset: boolean;
  dividendPerShare: number;
  expectedAnnualDividendGrowthRate: number;
  dividendFrequency: number;
  isReinvestDividends: boolean;
}

interface SimulationGoal {
  targetPortfolioValue: number;
  targetMonthlyDividend: number;
  investmentPeriodMonths: number;
}

interface AssetState {
  asset_id: string;
  current_price: number; // 현재 주가
  held_shares: number; // 보유 수량
  cash_balance: number; // 매수 후 남은 잔액 (거스름돈)
  dps: number; // 주당 배당금
  m_ret: number; // 월 복리 수익률
  m_div_growth: number; // 월 복리 배당성장률
  div_frequency: number; // 연간 배당 횟수
  is_dividend_asset: boolean;
  is_reinvest_dividends: boolean;
  initial_investment: number; // 초기 투자금 (1월차용)
  monthly_contribution: number; // 월 적립금
}

export class GoalAnalysisSimulationService {
  public analyzeGoalAchievement(assets: AssetParams[], goal: SimulationGoal) {
    // 전처리: 상태 초기화 (initializeSimulationState)
    const states = this.initializeSimulationState(assets);
    let reached_value_month: number | null = null;
    let reached_dividend_month: number | null = null;

    const has_div_assets = this.hasDividendAssets(states);

    // 메인 시뮬레이션 루프 (1..600) - Concurrent Update
    for (let m = 1; m <= MAX_ANALYSIS_LIMIT; m++) {
      let total_value = 0;
      let total_monthly_dividend_capacity = 0;

      for (const state of states) {
        // 시장 성장 반영 (growAssetPriceAndDividend)
        if (m > 1) {
          this.growAssetPriceAndDividend(state);
        }

        // 가용 투자금 산출 (calculateInvestableFunds) 및 매수 집행 (executeMonthlyTrade)
        const investable_funds = this.calculateInvestableFunds(state, m);
        this.executeMonthlyTrade(state, investable_funds);

        // 포트폴리오 지표 합산 (Aggregation / Query)
        total_value += this.calculateCurrentAssetValue(state);
        total_monthly_dividend_capacity += this.calculateMonthlyEquivalentDividend(state);
      }

      // 목표 도달 여부 확인 (Query)
      if (reached_value_month === null && total_value >= goal.targetPortfolioValue) {
        reached_value_month = m;
      }

      if (
        has_div_assets &&
        reached_dividend_month === null &&
        total_monthly_dividend_capacity >= goal.targetMonthlyDividend
      ) {
        reached_dividend_month = m;
      }

      // 종료 조건: 모든 활성화된 목표 도달 시 조기 종료 (isAllGoalsReached)
      if (this.isAllGoalsReached(reached_value_month, reached_dividend_month, has_div_assets)) {
        break;
      }
    }

    // 결과 반환 (formatGoalAnalysisResponse)
    return {
      reachedValueMonth: reached_value_month,
      reachedDividendMonth: reached_dividend_month,
    };
  }

  // Analysis & Validation Layer
  // 초기 상태 설정 (initializeSimulationState)
  private initializeSimulationState(assets: AssetParams[]): AssetState[] {
    return assets.map((asset, index) => ({
      asset_id: `asset_${index}`,
      current_price: asset.initialPrice,
      held_shares: 0,
      cash_balance: 0,
      dps: asset.dividendPerShare,
      // 연 -> 월 복리 수익률 환산 (설계서 2항 반영)
      m_ret: Math.pow(1 + asset.expectedAnnualPriceGrowthRate / 100, 1 / 12) - 1,
      m_div_growth: Math.pow(1 + asset.expectedAnnualDividendGrowthRate / 100, 1 / 12) - 1,
      div_frequency: asset.dividendFrequency,
      is_dividend_asset: asset.isDividendAsset,
      is_reinvest_dividends: asset.isReinvestDividends,
      initial_investment: asset.initialInvestmentAmount,
      monthly_contribution: asset.monthlyContributionAmount,
    }));
  }

  // 현재 자산 가치 산출 (calculateCurrentAssetValue)
  private calculateCurrentAssetValue(state: AssetState): number {
    return state.current_price * state.held_shares + state.cash_balance;
  }

  // 목표 판정용 월 환산 배당금 산출 (calculateMonthlyEquivalentDividend)
  private calculateMonthlyEquivalentDividend(state: AssetState): number {
    if (!state.is_dividend_asset) return 0;
    // (Shares * DPS * Frequency) / 12
    return (state.held_shares * state.dps * state.div_frequency) / 12;
  }

  // 배당 분석 가능 자산 존재 여부 확인 (hasDividendAssets)
  private hasDividendAssets(states: AssetState[]): boolean {
    return states.some((s) => s.is_dividend_asset);
  }

  // 모든 활성화된 목표 도달 여부 판단 (isAllGoalsReached)
  private isAllGoalsReached(
    val_month: number | null,
    div_month: number | null,
    has_div_assets: boolean
  ): boolean {
    const is_val_reached = val_month !== null;
    const is_div_reached = !has_div_assets || div_month !== null;
    return is_val_reached && is_div_reached;
  }

  // 최종 응답 데이터 변환 (formatGoalAnalysisResponse)
  private formatGoalAnalysisResponse(val_month: number | null, div_month: number | null) {
    return {
      portfolioValueGoal: val_month ? { expectedMonthsToTarget: val_month } : null,
      monthlyDividendGoal: div_month ? { expectedMonthsToTarget: div_month } : null,
    };
  }

  // Core Execution Engine (Market & Trade)
  // 주가 및 DPS 갱신 (growAssetPriceAndDividend)
  private growAssetPriceAndDividend(state: AssetState): void {
    state.current_price *= 1 + state.m_ret;
    state.dps *= 1 + state.m_div_growth;
  }

  // 가용 투자 금액 산출 (calculateInvestableFunds)
  private calculateInvestableFunds(state: AssetState, m: number): number {
    let invest_pool = state.cash_balance;

    if (m === 1) {
      // 최초 매수: 초기 투자금만 적용
      invest_pool += state.initial_investment;
    } else {
      // 1개월 이후: 월 적립금 추가
      invest_pool += state.monthly_contribution;
    }

    // 배당 발생 및 재투자 처리
    const is_div_month = m % (12 / state.div_frequency) === 0;
    if (state.is_dividend_asset && state.is_reinvest_dividends && is_div_month) {
      const div_cash = state.held_shares * state.dps;
      invest_pool += div_cash;
    }

    return invest_pool;
  }

  // 매수 집행 및 잔액 관리 (executeMonthlyTrade)
  private executeMonthlyTrade(state: AssetState, funds: number): void {
    const buyable_shares = Math.floor(funds / state.current_price);
    if (buyable_shares > 0) {
      state.held_shares += buyable_shares;
      state.cash_balance = funds - buyable_shares * state.current_price;
    } else {
      state.cash_balance = funds;
    }
  }
}
