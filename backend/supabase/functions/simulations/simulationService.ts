import { AssetType } from '../../../shared/domain/AssetType.ts';
import {
  SimulationRequestDto,
  AssetInputDto,
  SimulationGoalDto,
} from '../../../shared/dto/simulations/SimulationRequest.dto.ts';
import { PercentileResultDto } from '../../../shared/dto/simulations/SimulationResponse.dto.ts';

const numSimulations = 10000;
const annualDividendGrowthVolatility = 0.02; // 배당성장률의 연간 변동성 (2%)
const maxAnalysisLimitMonths = 600; // 분석 한계치 (50년)

const monthlyVolatilityMap: Record<AssetType, number> = {
  [AssetType.STOCK]: 0.08,
  [AssetType.CRYPTO]: 0.2,
  [AssetType.INDEX]: 0.035,
  [AssetType.COMMODITY]: 0.06,
  [AssetType.GOLD]: 0.02,
};

// 몬테카를로 분석(확률적)과 목표 달성 분석(결정론적) 통합 수행
export class SimulationService {
  // 통합 시뮬레이션을 실행하고 분위수 결과 및 목표 도달 시점 반환
  public runSimulation(dto: SimulationRequestDto) {
    // 1. 몬테카를로 시뮬레이션 (확률적 모델 - 분석 기간 기준)
    const mcResults = this.runMonteCarloAnalysis(
      dto.goal.investmentPeriodMonths,
      dto.assets,
      dto.seed
    );

    // 2. 목표 달성 분석 (결정론적 모델 - 목표 금액 기준 기댓값 경로 추적)
    const goalResults = this.analyzeGoalAchievement(dto.assets, dto.goal);

    return {
      percentiles: mcResults,
      goalAnalysis: goalResults,
    };
  }

  // 10,000회 시뮬레이션을 통해 포트폴리오의 분위수 결과 도출
  private runMonteCarloAnalysis(
    investmentPeriodMonths: number,
    assets: AssetInputDto[],
    seed?: string
  ) {
    const portfolioValueResults = new Float64Array(numSimulations);
    const monthlyDividendResults = new Float64Array(numSimulations);

    for (let simulationIndex = 0; simulationIndex < numSimulations; simulationIndex++) {
      let iterationPortfolioTotalValue = 0;
      let iterationDividendTotalAmount = 0;

      for (let assetIndex = 0; assetIndex < assets.length; assetIndex++) {
        const asset = assets[assetIndex];
        const deterministicAssetSeed = seed
          ? `${seed}-${simulationIndex}-${assetIndex}`
          : undefined;
        // 자산별 독립적인 RNG 주입 (전역 상태 공유 방지)
        const getNextRandom = this.createRandomGenerator(deterministicAssetSeed);

        const { finalValue, totalDividendIncome } = this.simulateStochasticTrajectory(
          investmentPeriodMonths,
          this.correctAssetData(asset),
          getNextRandom
        );

        iterationPortfolioTotalValue += finalValue;
        iterationDividendTotalAmount += totalDividendIncome;
      }

      portfolioValueResults[simulationIndex] = iterationPortfolioTotalValue;
      // 월평균 배당금 환산
      monthlyDividendResults[simulationIndex] =
        iterationDividendTotalAmount / investmentPeriodMonths;
    }

    const results = {
      portfolioValue: this.calculatePercentiles(portfolioValueResults),
      monthlyDividend: this.calculatePercentiles(monthlyDividendResults),
    };

    // 최종 결과 유효성 검증 (p10 <= p50 <= p90)
    this.checkValidity('Portfolio Value', results.portfolioValue);
    this.checkValidity('Monthly Dividend', results.monthlyDividend);

    return results;
  }

  // 결정론적 모델 기반 목표 도달 시점 계산 (동시 업데이트 모델) - 변동성 배제, 기대 성장률만 사용
  private analyzeGoalAchievement(assets: AssetInputDto[], goal: SimulationGoalDto) {
    const states = assets.map((a) => ({
      currentPrice: a.initialPrice,
      heldShares: 0,
      cashBalance: 0,
      currentDps: a.dividendPerShare,
      accumulatedDiv: 0,
    }));

    let portfolioValueReachedMonths: number | null = null;
    let monthlyDividendReachedMonths: number | null = null;
    const hasDivAssets = assets.some((a) => a.isDividendAsset);

    for (let m = 1; m <= maxAnalysisLimitMonths; m++) {
      let currentTotalPortfolioValue = 0;
      let currentTotalMonthlyDividend = 0;

      // 자산별 동시 업데이트 (Concurrent Update)
      for (let i = 0; i < assets.length; i++) {
        const asset = assets[i];
        const state = states[i];

        if (m > 1) {
          const annualPriceGrowthRateDecimal = asset.expectedAnnualPriceGrowthRate / 100;
          const annualDivGrowthRateDecimal = asset.expectedAnnualDividendGrowthRate / 100;
          // 기대 성장률 반영
          const mPriceReturn = Math.pow(1 + annualPriceGrowthRateDecimal, 1 / 12) - 1;
          const mDivGrowth = Math.pow(1 + annualDivGrowthRateDecimal, 1 / 12) - 1;
          state.currentPrice *= 1 + mPriceReturn;
          state.currentDps *= 1 + mDivGrowth;
        }

        let pool = m === 1 ? asset.initialInvestmentAmount : asset.monthlyContributionAmount;
        pool += state.cashBalance;

        // 배당금 수령 및 재투자 처리
        if (asset.isDividendAsset && m % (12 / asset.dividendFrequency) === 0) {
          const divCash = state.heldShares * state.currentDps;
          if (asset.isReinvestDividends) pool += divCash;
          else state.accumulatedDiv += divCash;
        }

        // 매수 집행
        state.heldShares += Math.floor(pool / state.currentPrice);
        state.cashBalance = pool % state.currentPrice;

        // 포트폴리오 가치 합산
        currentTotalPortfolioValue +=
          state.currentPrice * state.heldShares + state.cashBalance + state.accumulatedDiv;
        if (asset.isDividendAsset) {
          currentTotalMonthlyDividend +=
            (state.heldShares * state.currentDps * asset.dividendFrequency) / 12;
        }
      }

      // 목표 도달 여부 체크 (Query)
      if (
        portfolioValueReachedMonths === null &&
        currentTotalPortfolioValue >= goal.targetPortfolioValue
      ) {
        portfolioValueReachedMonths = m;
      }
      if (
        hasDivAssets &&
        monthlyDividendReachedMonths === null &&
        currentTotalMonthlyDividend >= goal.targetMonthlyDividend
      ) {
        monthlyDividendReachedMonths = m;
      }

      // 모든 목표 달성 시 조기 종료
      if (
        portfolioValueReachedMonths !== null &&
        (!hasDivAssets || monthlyDividendReachedMonths !== null)
      )
        break;
    }

    return {
      portfolioValueGoal: { expectedMonthsToTarget: portfolioValueReachedMonths },
      monthlyDividendGoal: { expectedMonthsToTarget: monthlyDividendReachedMonths },
    };
  }

  // --- Core Utility Helpers ---

  // Box-Muller 변환을 이용한 클로저 기반 난수 생성기
  private createRandomGenerator(seedStr?: string) {
    // 1. 시드가 없을 경우 기존 Math.random 사용 (기존 동작 유지)
    if (!seedStr) {
      return this.wrapStandardNormal(Math.random);
    }
    // 2. 문자열 시드를 32비트 정수로 변환 (FNV-1a 스타일 해시)
    let h = 2166136261 >>> 0;
    for (let i = 0; i < seedStr.length; i++) {
      h = Math.imul(h ^ seedStr.charCodeAt(i), 16777619);
    }
    let s = h >>> 0;

    // 3. Mulberry32 알고리즘 (균등분포 난수 생성)
    const mulberry32 = () => {
      let t = (s += 0x6d2b79f5);
      t = Math.imul(t ^ (t >>> 15), t | 1);
      t ^= t + Math.imul(t ^ (t >>> 7), t | 61);
      return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
    };
    return this.wrapStandardNormal(mulberry32);
  }
  // 균등분포 난수 생성기를 Box-Muller 변환을 통해 표준정규분포로 변환
  private wrapStandardNormal(generateUniformRandom: () => number) {
    let cachedNormalValue: number | null = null;

    return (): number => {
      if (cachedNormalValue !== null) {
        const storedValue = cachedNormalValue;
        cachedNormalValue = null;
        return storedValue;
      }

      const uniformRandom1 = 1 - generateUniformRandom();
      const uniformRandom2 = 1 - generateUniformRandom();

      const magnitude = Math.sqrt(-2.0 * Math.log(uniformRandom1));
      const angle = 2.0 * Math.PI * uniformRandom2;

      cachedNormalValue = magnitude * Math.sin(angle);
      return magnitude * Math.cos(angle);
    };
  }

  // 확률적 단일 경로 시뮬레이션
  private simulateStochasticTrajectory(
    months: number,
    asset: AssetInputDto,
    getNextRandom: () => number
  ) {
    let price = asset.initialPrice;
    let shares = 0;
    let balance = 0;
    let dps = asset.dividendPerShare;
    let accumulatedDiv = 0;
    let totalGeneratedDividend = 0;

    const annualPriceGrowthRateDecimal = asset.expectedAnnualPriceGrowthRate / 100;
    const mGrowth = Math.pow(1 + annualPriceGrowthRateDecimal, 1 / 12) - 1;
    const monthlyVolatility = monthlyVolatilityMap[asset.assetType];

    for (let m = 1; m <= months; m++) {
      if (m === 1) {
        shares = Math.floor(asset.initialInvestmentAmount / price);
        balance = asset.initialInvestmentAmount % price;
      } else {
        // 난수 적용 주가 갱신
        price *= 1 + mGrowth + monthlyVolatility * getNextRandom();

        let pool = asset.monthlyContributionAmount + balance;

        if (asset.isDividendAsset && m % (12 / asset.dividendFrequency) === 0) {
          // 배당 성장 시뮬레이션 및 Clamp 적용
          const rawG = this.calculatePeriodG(
            asset.dividendFrequency,
            asset.expectedAnnualDividendGrowthRate / 100,
            getNextRandom
          );
          dps *= 1 + this.checkClampRange(rawG, asset.dividendFrequency);

          const divCash = shares * dps;
          totalGeneratedDividend += divCash;
          if (asset.isReinvestDividends) pool += divCash;
          else accumulatedDiv += divCash;
        }

        shares += Math.floor(pool / price);
        balance = pool % price;
      }
    }

    return {
      finalValue: price * shares + balance + accumulatedDiv,
      totalDividendIncome: totalGeneratedDividend,
    };
  }

  private calculatePeriodG(
    frequency: number,
    annualDgr: number,
    getNextRandom: () => number
  ): number {
    const periodG = Math.pow(1 + annualDgr, 1 / frequency) - 1;
    const periodVol = annualDividendGrowthVolatility / Math.sqrt(frequency);
    return periodG + periodVol * getNextRandom();
  }

  private checkClampRange(rawG: number, frequency: number): number {
    const annualEquivalent = Math.pow(1 + rawG, frequency) - 1;
    const clampedAnnual = Math.max(-0.2, Math.min(0.15, annualEquivalent));
    return Math.pow(1 + clampedAnnual, 1 / frequency) - 1;
  }

  // 시뮬레이션 결과 데이터에서 백분위수 지표 추출
  private calculatePercentiles(data: Float64Array): PercentileResultDto {
    data.sort();
    return {
      p10: Math.round(data[Math.floor(numSimulations * 0.1)]),
      p50: Math.round(data[Math.floor(numSimulations * 0.5)]),
      p90: Math.round(data[Math.floor(numSimulations * 0.9)]),
    };
  }

  private correctAssetData(asset: AssetInputDto): AssetInputDto {
    if (asset.isDividendAsset) return asset;
    return {
      ...asset,
      dividendPerShare: 0,
      expectedAnnualDividendGrowthRate: 0,
      dividendFrequency: 1,
    };
  }

  // 통계적 유효성 검증 (p10 <= p50 <= p90)
  private checkValidity(label: string, p: PercentileResultDto) {
    if (p.p10 > p.p50 || p.p50 > p.p90) {
      throw new Error(
        `Statistical Validity Error [${label}]: p10 <= p50 <= p90 조건을 위반했습니다.`
      );
    }
  }
}
