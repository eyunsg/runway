import { GoalAnalysisSimulationService } from '../supabase/functions/simulations/goalAnalysisSimulationService';

describe('GoalAnalysisSimulationService - Comprehensive Scenario Testing', () => {
  let service: GoalAnalysisSimulationService;

  const mockBaseAsset = {
    assetName: '테스트 자산',
    assetType: '인덱스형 자산',
    initialPrice: 10000,
    expectedAnnualPriceGrowthRate: 0,
    initialInvestmentAmount: 0,
    monthlyContributionAmount: 0,
    isDividendAsset: false,
    dividendPerShare: 0,
    expectedAnnualDividendGrowthRate: 0,
    dividendFrequency: 12,
    isReinvestDividends: false,
  };

  beforeEach(() => {
    service = new GoalAnalysisSimulationService();
  });

  // --- 시나리오 1: 단기 도달 테스트 ---

  it('시나리오 A: 1개월 차에 초기 투자금만으로 목표를 즉시 달성해야 한다', () => {
    const assets = [
      {
        ...mockBaseAsset,
        initialPrice: 1000,
        initialInvestmentAmount: 10000, // 시작하자마자 10000원
        monthlyContributionAmount: 1000,
      },
    ];

    const goal = {
      targetPortfolioValue: 10000,
      targetMonthlyDividend: 0,
      investmentPeriodMonths: 12,
    };

    const result = service.analyzeGoalAchievement(assets, goal);
    expect(result.reachedValueMonth).toBe(1);
  });

  it('시나리오 B: 1월차엔 부족하지만, 2월차 적립금이 합산되어 목표를 달성해야 한다', () => {
    const assets = [
      {
        ...mockBaseAsset,
        initialPrice: 1000,
        initialInvestmentAmount: 5000,
        monthlyContributionAmount: 1000, // 2월차에 1000원 추가되어 6000원 됨
      },
    ];

    const goal = {
      targetPortfolioValue: 6000,
      targetMonthlyDividend: 0,
      investmentPeriodMonths: 12,
    };

    const result = service.analyzeGoalAchievement(assets, goal);
    // 1월차(5000) -> 2월차(5000 + 1000 = 6000)
    expect(result.reachedValueMonth).toBe(2);
  });

  // --- 시나리오 2: 중장기 복리 및 적립 테스트 ---

  it('시나리오 C: 낮은 초기금으로 시작해, 주가 성장과 적립을 통해 1년(12개월) 뒤 목표에 도달해야 한다', () => {
    const assets = [
      {
        ...mockBaseAsset,
        initialPrice: 1000,
        initialInvestmentAmount: 1000,
        monthlyContributionAmount: 500,
        expectedAnnualPriceGrowthRate: 10, // 연 10% 성장
      },
    ];

    const goal = {
      targetPortfolioValue: 7000,
      targetMonthlyDividend: 0,
      investmentPeriodMonths: 24,
    };

    const result = service.analyzeGoalAchievement(assets, goal);

    // 단순 합산으로는 12개월차에 1000 + (500 * 11) = 6500원이지만,
    // 주가 상승이 더해져 약 12~13개월 사이에 도달하는지 확인
    expect(result.reachedValueMonth).toBeGreaterThanOrEqual(12);
    expect(result.reachedValueMonth).toBeLessThanOrEqual(14);
  });

  // --- 시나리오 3: 배당금 목표 테스트 ---

  it('시나리오 D: 배당금 재투자를 통해 월 배당금 목표에 점진적으로 도달해야 한다', () => {
    const assets = [
      {
        ...mockBaseAsset,
        initialPrice: 10000,
        initialInvestmentAmount: 1000000, // 100주로 시작
        monthlyContributionAmount: 100000, // 매달 10주 추가 매수
        isDividendAsset: true,
        dividendPerShare: 100, // 주당 100원 (월 1만원 배당 시작)
        dividendFrequency: 12,
        isReinvestDividends: true, // 재투자로 주식 수 증가 가속
        expectedAnnualDividendGrowthRate: 5, // 배당금도 매달 조금씩 성장
      },
    ];

    const goal = {
      targetPortfolioValue: 999999999,
      targetMonthlyDividend: 30000, // 월 배당 3만원이 목표
      investmentPeriodMonths: 60,
    };

    const result = service.analyzeGoalAchievement(assets, goal);

    // 초기 1만 -> 적립 및 재투자로 주식 수가 늘어나 3만에 도달하는 시점 검증
    expect(result.reachedDividendMonth).not.toBeNull();
    expect(result.reachedDividendMonth).toBeGreaterThan(10); // 어느 정도 시간이 걸려야 함
  });

  // --- 시나리오 4: 한계점 및 예외 테스트 ---

  it('시나리오 E: 분석 한계치(600개월) 직전에 도달하거나 초과하는 경우', () => {
    const assets = [
      {
        ...mockBaseAsset,
        initialInvestmentAmount: 100,
        monthlyContributionAmount: 1, // 아주 느린 성장
      },
    ];

    const goal = {
      targetPortfolioValue: 1000000, // 도달 불가능한 높은 목표
      targetMonthlyDividend: 0,
      investmentPeriodMonths: 600,
    };

    const result = service.analyzeGoalAchievement(assets, goal);

    // 600개월 내에 도달하지 못하면 null이어야 함
    expect(result.reachedValueMonth).toBeNull();
  });
});
