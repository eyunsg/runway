import { SimulationService } from '../supabase/functions/simulations/simulationService.ts';
import {
  SimulationRequestDto,
  AssetInputDto,
} from '../shared/dto/simulations/SimulationRequest.dto.ts';
import { AssetType } from '../shared/domain/AssetType.ts';

describe('SimulationService - 통합 시뮬레이션 엔진 검증', () => {
  let service: SimulationService;

  // 테스트용 기본 자산 데이터 (지수형, 5% 성장, 무배당)
  const mockBaseAsset: AssetInputDto = {
    assetName: '테스트 지수',
    assetType: AssetType.INDEX,
    initialPrice: 10000,
    expectedAnnualPriceGrowthRate: 5, // 5%의미
    initialInvestmentAmount: 1000000,
    monthlyContributionAmount: 100000,
    isDividendAsset: false,
    dividendPerShare: 0,
    expectedAnnualDividendGrowthRate: 0,
    dividendFrequency: 12,
    isReinvestDividends: false,
  };

  beforeEach(() => {
    service = new SimulationService();
  });

  describe('Part 1: Monte Carlo Analysis (확률적 분석)', () => {
    it('시나리오 1: 통계적 유효성 (p10 <= p50 <= p90) 및 결과 정수화 확인', () => {
      const requestBody = {
        goal: {
          investmentPeriodMonths: 12,
          targetPortfolioValue: 2000000,
          targetMonthlyDividend: 0,
        },
        assets: [mockBaseAsset],
      };
      const dto = new SimulationRequestDto(requestBody);
      const { percentiles } = service.runSimulation(dto);

      expect(percentiles.portfolioValue.p10).toBeLessThanOrEqual(percentiles.portfolioValue.p50);
      expect(percentiles.portfolioValue.p50).toBeLessThanOrEqual(percentiles.portfolioValue.p90);
      expect(Number.isInteger(percentiles.portfolioValue.p50)).toBe(true);
    });

    // [수정] 현재 서비스는 Month 0에 선매수 후 m=1부터 GBM 가격 변동이 적용됨
    // 따라서 1개월 시뮬레이션이라도 주가 변동이 반영되어 정확히 초기값과 일치하지 않음
    // 대신 변동성(INDEX: 3.5%)을 감안한 합리적 범위 내에 있는지 검증
    it('시나리오 2: 1개월 차 시뮬레이션은 초기 투자금 기준 합리적 범위 내에 있어야 한다', () => {
      const initialInvestmentAmount = 1000000;
      const requestBody = {
        goal: { investmentPeriodMonths: 1, targetPortfolioValue: 5000, targetMonthlyDividend: 0 },
        assets: [{ ...mockBaseAsset, initialInvestmentAmount, monthlyContributionAmount: 0 }],
      };
      const dto = new SimulationRequestDto(requestBody);
      const { percentiles } = service.runSimulation(dto);

      // INDEX 월 변동성 3.5% 기준으로 중위값은 초기 투자금 ±10% 범위 내에 있어야 함
      expect(percentiles.portfolioValue.p50).toBeGreaterThan(initialInvestmentAmount * 0.9);
      expect(percentiles.portfolioValue.p50).toBeLessThan(initialInvestmentAmount * 1.1);
      // p10 <= p50 <= p90 유효성도 함께 확인
      expect(percentiles.portfolioValue.p10).toBeLessThanOrEqual(percentiles.portfolioValue.p50);
      expect(percentiles.portfolioValue.p50).toBeLessThanOrEqual(percentiles.portfolioValue.p90);
    });

    it('시나리오 3: 배당 재투자(DRIP) 여부에 따른 자산 증식 차이 검증', () => {
      const dividendAsset = {
        ...mockBaseAsset,
        isDividendAsset: true,
        dividendPerShare: 1000,
        dividendFrequency: 12,
      };

      const reinvestOnDto = new SimulationRequestDto({
        goal: { investmentPeriodMonths: 36, targetPortfolioValue: 0, targetMonthlyDividend: 0 },
        assets: [{ ...dividendAsset, isReinvestDividends: true }],
      });
      const reinvestOffDto = new SimulationRequestDto({
        goal: { investmentPeriodMonths: 36, targetPortfolioValue: 0, targetMonthlyDividend: 0 },
        assets: [{ ...dividendAsset, isReinvestDividends: false }],
      });

      const onResult = service.runSimulation(reinvestOnDto);
      const offResult = service.runSimulation(reinvestOffDto);

      expect(onResult.percentiles.portfolioValue.p50).toBeGreaterThan(
        offResult.percentiles.portfolioValue.p50
      );
    });

    it('시나리오 4: 배당 재투자 설정 시에도 결과 데이터의 월 배당금(monthlyDividend)이 0보다 커야 한다', () => {
      const dividendAsset = {
        ...mockBaseAsset,
        isDividendAsset: true,
        dividendPerShare: 1000,
        dividendFrequency: 4,
        isReinvestDividends: true, // [중요] 재투자 설정
      };

      const requestBody = {
        goal: { investmentPeriodMonths: 24, targetPortfolioValue: 0, targetMonthlyDividend: 0 },
        assets: [dividendAsset],
      };

      const dto = new SimulationRequestDto(requestBody);
      const { percentiles } = service.runSimulation(dto);

      // 버그 수정 전에는 재투자 시 이 값이 0으로 나왔으나, 이제는 0보다 커야 함
      expect(percentiles.monthlyDividend.p50).toBeGreaterThan(0);
    });

    it('시나리오 5: 극단적 음의 변동성에서도 near-zero 가격으로 수량이 폭증하지 않아야 한다', () => {
      const result = (service as any).simulateStochasticTrajectory(
        24,
        {
          ...mockBaseAsset,
          initialPrice: 40000,
          initialInvestmentAmount: 20000000,
          monthlyContributionAmount: 1000000,
        },
        () => -100
      );

      expect(result.finalValue).toBeGreaterThanOrEqual(0);
      expect(Number.isFinite(result.finalValue)).toBe(true);
      expect(result.finalValue).toBeLessThan(1e15);
    });
  });

  describe('Part 2: Goal Analysis (결정론적 분석 - 정밀 로직 검증)', () => {
    it('시나리오 A: 초기 자산만으로 목표를 즉시 달성하는 경우 (1개월 차)', () => {
      const requestBody = {
        goal: {
          investmentPeriodMonths: 12,
          targetPortfolioValue: 1000000,
          targetMonthlyDividend: 0,
        },
        assets: [{ ...mockBaseAsset, initialInvestmentAmount: 1500000 }],
      };
      const dto = new SimulationRequestDto(requestBody);
      const { goalAnalysis } = service.runSimulation(dto);

      expect(goalAnalysis.portfolioValueGoal.expectedMonthsToTarget).toBe(1);
    });

    it('시나리오 B: 배당 주기에 따른 계단식 자산 증가 및 도달 시점 검증 (분기 배당)', () => {
      const requestBody = {
        goal: {
          investmentPeriodMonths: 12,
          targetPortfolioValue: 1050000,
          targetMonthlyDividend: 0,
        },
        assets: [
          {
            ...mockBaseAsset,
            initialInvestmentAmount: 1000000,
            monthlyContributionAmount: 0,
            expectedAnnualPriceGrowthRate: 0,
            isDividendAsset: true,
            dividendPerShare: 500, // 100주 가정 시 5만원
            dividendFrequency: 4, // 3개월마다 배당
            isReinvestDividends: true, // 재투자해야 포트폴리오 가치 상승으로 목표 도달 가능
          },
        ],
      };
      const dto = new SimulationRequestDto(requestBody);
      const { goalAnalysis } = service.runSimulation(dto);

      // 로직 분석: 1, 2월(배당없음), 3월(첫 분기배당 재투자) -> 105만 도달
      expect(goalAnalysis.portfolioValueGoal.expectedMonthsToTarget).toBe(3);
    });

    // [수정] 비재투자 배당금은 포트폴리오 가치에 포함되지 않음 (인출된 현금으로 간주)
    // 따라서 주가 성장률 0%, 월 적립금 0원 조건에서는 주식 평가액이 그대로이므로
    // 포트폴리오 가치 목표 달성이 아닌, 월 배당금 목표 도달 시점을 검증하도록 수정
    it('시나리오 C: 비재투자(Non-DRIP) 자산의 월 배당금이 매달 발생하는지 검증', () => {
      const requestBody = {
        goal: {
          investmentPeriodMonths: 12,
          targetPortfolioValue: 0,
          targetMonthlyDividend: 50000, // 월 5만원 목표
        },
        assets: [
          {
            ...mockBaseAsset,
            initialInvestmentAmount: 1000000,
            monthlyContributionAmount: 0,
            expectedAnnualPriceGrowthRate: 0,
            isDividendAsset: true,
            dividendPerShare: 500, // 100주 * 500원 = 5만원
            dividendFrequency: 12, // 매달 배당
            expectedAnnualDividendGrowthRate: 0,
            isReinvestDividends: false,
          },
        ],
      };
      const dto = new SimulationRequestDto(requestBody);
      const { goalAnalysis } = service.runSimulation(dto);

      // 1월부터 매달 5만원 배당 발생 → 1개월 차에 목표 달성
      expect(goalAnalysis.monthlyDividendGoal.expectedMonthsToTarget).toBe(1);
    });

    it('시나리오 D: 월 배당금 목표 도달 시점 (배당 성장률 반영)', () => {
      const requestBody = {
        goal: {
          investmentPeriodMonths: 60,
          targetPortfolioValue: 999999999,
          targetMonthlyDividend: 11000,
        },
        assets: [
          {
            ...mockBaseAsset,
            initialInvestmentAmount: 1000000,
            monthlyContributionAmount: 0,
            isDividendAsset: true,
            dividendPerShare: 100,
            dividendFrequency: 12,
            expectedAnnualDividendGrowthRate: 20, // 20% 의미
          },
        ],
      };
      const dto = new SimulationRequestDto(requestBody);
      const { goalAnalysis } = service.runSimulation(dto);
      expect(goalAnalysis.monthlyDividendGoal.expectedMonthsToTarget).not.toBeNull();
      expect(goalAnalysis.monthlyDividendGoal.expectedMonthsToTarget).toBeGreaterThan(1);
    });
  });

  describe('Part 3: Edge Cases & Multi-Asset 시너지', () => {
    it(`시나리오 E: 주식 매수 후 남은 '자투리 현금(Cash Balance)'이 다음 달로 이월되어 합산되는지 검증`, () => {
      const requestBody = {
        goal: { investmentPeriodMonths: 12, targetPortfolioValue: 10000, targetMonthlyDividend: 0 },
        assets: [
          {
            ...mockBaseAsset,
            initialPrice: 7000,
            initialInvestmentAmount: 10000, // 1주 사고 3000원 남음
            monthlyContributionAmount: 4000, // 2월에 4000원 추가되면 7000원이 되어 1주 더 살 수 있음
            expectedAnnualPriceGrowthRate: 0,
          },
        ],
      };
      const dto = new SimulationRequestDto(requestBody);
      const { goalAnalysis } = service.runSimulation(dto);

      expect(goalAnalysis.portfolioValueGoal.expectedMonthsToTarget).toBe(1);
    });

    it('시나리오 F: 다중 자산 합산 시의 목표 도달 시점 검증', () => {
      const assets = [
        { ...mockBaseAsset, initialInvestmentAmount: 500000, monthlyContributionAmount: 0 },
        { ...mockBaseAsset, initialInvestmentAmount: 500000, monthlyContributionAmount: 0 },
      ];
      const requestBody = {
        goal: {
          investmentPeriodMonths: 12,
          targetPortfolioValue: 1000000,
          targetMonthlyDividend: 0,
        },
        assets: assets,
      };
      const dto = new SimulationRequestDto(requestBody);
      const { goalAnalysis } = service.runSimulation(dto);

      expect(goalAnalysis.portfolioValueGoal.expectedMonthsToTarget).toBe(1);
    });

    it('시나리오 G: 분석 한계치(600개월) 초과 시 결과값은 null이어야 한다', () => {
      const requestBody = {
        goal: {
          investmentPeriodMonths: 12,
          targetPortfolioValue: 1000000000,
          targetMonthlyDividend: 0,
        },
        assets: [{ ...mockBaseAsset, initialInvestmentAmount: 100, monthlyContributionAmount: 0 }],
      };
      const dto = new SimulationRequestDto(requestBody);
      const { goalAnalysis } = service.runSimulation(dto);

      expect(goalAnalysis.portfolioValueGoal.expectedMonthsToTarget).toBeNull();
    });
  });

  describe('Part 4: Seeded Deterministic Analysis (결정론적 검증)', () => {
    const seededRequestBody = {
      goal: {
        investmentPeriodMonths: 60,
        targetPortfolioValue: 5000000,
        targetMonthlyDividend: 20000,
      },
      assets: [
        {
          ...mockBaseAsset,
          assetType: AssetType.STOCK,
          expectedAnnualPriceGrowthRate: 7,
          isDividendAsset: true,
          dividendPerShare: 250,
          dividendFrequency: 4,
          expectedAnnualDividendGrowthRate: 5,
          isReinvestDividends: true,
        },
      ],
    };

    it('시드 주입 시 결과가 100% 동일하게 재현되어야 한다', () => {
      const testSeed = 'RUNWAY-402-DETERMINISTIC-TEST';
      const dto1 = new SimulationRequestDto({ ...seededRequestBody, seed: testSeed });
      const dto2 = new SimulationRequestDto({ ...seededRequestBody, seed: testSeed });

      const result1 = service.runSimulation(dto1);
      const result2 = service.runSimulation(dto2);

      expect(result1.percentiles).toEqual(result2.percentiles);
      expect(result1.percentiles.portfolioValue.p50).toBe(result2.percentiles.portfolioValue.p50);
    });

    it('시드가 주입되지 않으면 무작위성에 의해 매번 다른 결과가 나와야 한다', () => {
      const dto1 = new SimulationRequestDto({ ...seededRequestBody });
      const dto2 = new SimulationRequestDto({ ...seededRequestBody });

      const result1 = service.runSimulation(dto1);
      const result2 = service.runSimulation(dto2);

      expect(result1.percentiles.portfolioValue.p50).not.toBe(
        result2.percentiles.portfolioValue.p50
      );
    });

    it('고정된 시드에 대해 통계적 유효성 및 기댓값 범위를 유지해야 한다', () => {
      const fixedSeed = 'SNAPSHOT_VERIFICATION';
      const dto = new SimulationRequestDto({ ...seededRequestBody, seed: fixedSeed });
      const { percentiles } = service.runSimulation(dto);

      expect(percentiles.portfolioValue.p50).toBeGreaterThan(0);
      expect(percentiles.portfolioValue.p10).toBeLessThanOrEqual(percentiles.portfolioValue.p50);
      expect(percentiles.portfolioValue.p50).toBeLessThanOrEqual(percentiles.portfolioValue.p90);
    });
  });
});
