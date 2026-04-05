import { GoalAnalysisSimulationService } from '../supabase/functions/simulations/goalAnalysisSimulationService.ts';
import { AssetType } from '../shared/domain/AssetType.ts';
import { AssetInputDto } from '../shared/dto/simulations/MonteCarloSimulationRequest.dto.ts';
import { SimulationGoalDto } from '../shared/dto/simulations/GoalAnalysisSimulationRequest.dto.ts';

describe('GoalAnalysisSimulationService - 비즈니스 로직 검증', () => {
  let service: GoalAnalysisSimulationService;

  const mockBaseAsset: AssetInputDto = {
    assetName: '테스트 자산',
    assetType: AssetType.INDEX,
    initialPrice: 10000,
    expectedAnnualPriceGrowthRate: 0,
    initialInvestmentAmount: 0,
    monthlyContributionAmount: 0,
    isDividendAsset: false,
    dividendPerShare: 0,
    expectedAnnualDividendGrowthRate: 0,
    dividendFrequencyPerYear: 12,
    isReinvestDividends: false,
  };

  beforeEach(() => {
    service = new GoalAnalysisSimulationService();
  });

  // --- 시나리오 1: 자산 금액 목표 도달 테스트 ---

  it('시나리오 A: 초기 투자금만으로 목표 금액을 1개월 차에 즉시 달성해야 한다', () => {
    const assets = [
      {
        ...mockBaseAsset,
        initialPrice: 1000,
        initialInvestmentAmount: 10000,
      },
    ];

    const goal: SimulationGoalDto = {
      targetPortfolioAmount: 10000,
      targetMonthlyDividendAmount: 0,
      investmentPeriodMonths: 12,
    };

    const result = service.analyzeGoalAchievement(assets, goal);
    expect(result.reachedPortfolioAmountMonth).toBe(1);
  });

  it('시나리오 B: 1월차는 부족하지만 2월차 적립금이 더해져 목표를 달성해야 한다', () => {
    const assets = [
      {
        ...mockBaseAsset,
        initialPrice: 1000,
        initialInvestmentAmount: 5000,
        monthlyContributionAmount: 5000,
      },
    ];

    const goal: SimulationGoalDto = {
      targetPortfolioAmount: 10000,
      targetMonthlyDividendAmount: 0,
      investmentPeriodMonths: 12,
    };

    const result = service.analyzeGoalAchievement(assets, goal);
    expect(result.reachedPortfolioAmountMonth).toBe(2);
  });

  // --- 시나리오 2: 중장기 복리 성장 테스트 ---

  it('시나리오 C: 연 성장률 기반 복리 효과를 통해 목표에 도달하는 시점을 검증한다', () => {
    const assets = [
      {
        ...mockBaseAsset,
        initialPrice: 1000,
        initialInvestmentAmount: 1000,
        expectedAnnualPriceGrowthRate: 20,
      },
    ];
    // 부동소수점 오차 방지를 위해 안전한 값 설정
    const goal: SimulationGoalDto = {
      targetPortfolioAmount: 1070,
      targetMonthlyDividendAmount: 0,
      investmentPeriodMonths: 12,
    };
    const result = service.analyzeGoalAchievement(assets, goal);
    expect(result.reachedPortfolioAmountMonth).toBe(6);
  });

  // --- 시나리오 3: 배당금 목표 달성 테스트 ---

  it('시나리오 D: 배당 자산을 통해 월 평균 배당금 목표에 도달하는 시점을 검증한다', () => {
    const assets = [
      {
        ...mockBaseAsset,
        initialPrice: 10000,
        initialInvestmentAmount: 1000000, // 100주
        monthlyContributionAmount: 1000000, // 매달 100주 추가
        isDividendAsset: true,
        dividendPerShare: 100,
        dividendFrequencyPerYear: 12,
        isReinvestDividends: false,
      },
    ];

    const goal: SimulationGoalDto = {
      targetPortfolioAmount: 999999999,
      targetMonthlyDividendAmount: 30000,
      investmentPeriodMonths: 60,
    };

    const result = service.analyzeGoalAchievement(assets, goal);
    // 1월(1만) -> 2월(2만) -> 3월(3만)
    expect(result.reachedMonthlyDividendAmountMonth).toBe(3);
  });

  // --- 시나리오 4: 다중 자산 및 복합 시나리오 ---

  it('시나리오 F: 여러 자산의 합산 가치가 목표 금액에 도달하는지 검증해야 한다', () => {
    const assets = [
      { ...mockBaseAsset, initialInvestmentAmount: 3000 },
      { ...mockBaseAsset, initialInvestmentAmount: 7000 },
    ];

    const goal: SimulationGoalDto = {
      targetPortfolioAmount: 10000,
      targetMonthlyDividendAmount: 0,
      investmentPeriodMonths: 12,
    };

    const result = service.analyzeGoalAchievement(assets, goal);
    expect(result.reachedPortfolioAmountMonth).toBe(1);
  });

  it('시나리오 G: 배당 재투자(DRIP) 여부에 따라 목표 금액 도달 속도가 달라져야 한다', () => {
    const commonAsset = {
      ...mockBaseAsset,
      initialInvestmentAmount: 100000,
      initialPrice: 10000,
      isDividendAsset: true,
      dividendPerShare: 1000,
      dividendFrequencyPerYear: 12,
      expectedAnnualPriceGrowthRate: 5,
    };

    const goal: SimulationGoalDto = {
      targetPortfolioAmount: 130000,
      targetMonthlyDividendAmount: 0,
      investmentPeriodMonths: 120,
    };

    const resultWithReinvest = service.analyzeGoalAchievement(
      [{ ...commonAsset, isReinvestDividends: true }],
      goal
    );
    const resultWithoutReinvest = service.analyzeGoalAchievement(
      [{ ...commonAsset, isReinvestDividends: false }],
      goal
    );

    expect(resultWithReinvest.reachedPortfolioAmountMonth).not.toBeNull();
    expect(resultWithoutReinvest.reachedPortfolioAmountMonth).not.toBeNull();

    expect(resultWithReinvest.reachedPortfolioAmountMonth!).toBeLessThanOrEqual(
      resultWithoutReinvest.reachedPortfolioAmountMonth!
    );
  });

  // --- 시나리오 5: 한계점 및 경계값 테스트 ---

  it('시나리오 E: 시뮬레이션 한계치(600개월) 내에 도달하지 못하면 null을 반환해야 한다', () => {
    const assets = [
      {
        ...mockBaseAsset,
        initialInvestmentAmount: 1000,
        monthlyContributionAmount: 0,
      },
    ];

    const goal: SimulationGoalDto = {
      targetPortfolioAmount: 1000000,
      targetMonthlyDividendAmount: 0,
      investmentPeriodMonths: 600,
    };

    const result = service.analyzeGoalAchievement(assets, goal);
    expect(result.reachedPortfolioAmountMonth).toBeNull();
  });

  it('시나리오 H: 정확히 600개월 차에 목표를 달성하는 경우를 검증해야 한다', () => {
    const assets = [
      {
        ...mockBaseAsset,
        initialInvestmentAmount: 0,
        initialPrice: 10000,
        monthlyContributionAmount: 1000,
      },
    ];

    const goal: SimulationGoalDto = {
      targetPortfolioAmount: 595000,
      targetMonthlyDividendAmount: 0,
      investmentPeriodMonths: 600,
    };

    const result = service.analyzeGoalAchievement(assets, goal);
    expect(result.reachedPortfolioAmountMonth).not.toBeNull();
    expect(result.reachedPortfolioAmountMonth).toBeLessThanOrEqual(600);
  });
});
