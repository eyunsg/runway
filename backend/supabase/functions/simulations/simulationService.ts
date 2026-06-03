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
const minimumAbsolutePrice = 1;

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

    // 2. 목표 달성 분석 (결정론적 모델 - 기대 성장률 기반 최단 경로 추적)
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
      let iterationDividendTerminalMonthly = 0;

      for (let assetIndex = 0; assetIndex < assets.length; assetIndex++) {
        const asset = assets[assetIndex];
        const deterministicAssetSeed = seed
          ? `${seed}-${simulationIndex}-${assetIndex}`
          : undefined;

        // 자산별 독립적인 RNG 주입 (전역 상태 공유 방지)
        const getNextRandom = this.createRandomGenerator(deterministicAssetSeed);

        const { finalValue, terminalMonthlyDividend } = this.simulateStochasticTrajectory(
          investmentPeriodMonths,
          this.correctAssetData(asset),
          getNextRandom
        );

        iterationPortfolioTotalValue += finalValue;
        iterationDividendTerminalMonthly += terminalMonthlyDividend;
      }

      portfolioValueResults[simulationIndex] = iterationPortfolioTotalValue;
      monthlyDividendResults[simulationIndex] = iterationDividendTerminalMonthly;
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
    // [수정 1] 비배당 자산의 배당 관련 필드를 0으로 보정한 뒤 사용
    const correctedAssets = assets.map((a) => this.correctAssetData(a));

    // Month 0: 초기 투자 금액으로 주식 선매수 후 시작 상태 설정
    const states = correctedAssets.map((a) => {
      const price = a.initialPrice;
      const initialPool = a.initialInvestmentAmount;
      const shares = Math.floor(initialPool / price);
      const balance = initialPool % price;

      return {
        currentPrice: price,
        heldShares: shares,
        cashBalance: balance,
        currentDps: a.dividendPerShare,
        // [수정 2] 비재투자 배당금을 포트폴리오 가치와 분리해서 추적
        // accumulatedDiv는 이미 인출된 현금이므로 포트폴리오 가치에 포함하지 않음
        accumulatedDiv: 0,
      };
    });

    let portfolioValueReachedMonths: number | null = null;
    let monthlyDividendReachedMonths: number | null = null;
    const hasDivAssets = correctedAssets.some((a) => a.isDividendAsset);

    for (let m = 1; m <= maxAnalysisLimitMonths; m++) {
      let currentTotalPortfolioValue = 0;
      let currentTotalMonthlyDividend = 0;

      // 자산별 동시 업데이트 (Concurrent Update)
      for (let i = 0; i < correctedAssets.length; i++) {
        const asset = correctedAssets[i];
        const state = states[i];

        // 1. 자산 가격 반영 (1개월 복리 성장)
        const annualPriceGrowthRateDecimal = asset.expectedAnnualPriceGrowthRate / 100;
        const mPriceReturn = Math.pow(1 + annualPriceGrowthRateDecimal, 1 / 12) - 1;
        state.currentPrice *= 1 + mPriceReturn;

        // [수정 3] dps 성장을 매달 반영 (배당 지급 여부와 무관)
        // 배당 빈도와 관계없이 모든 자산의 dps 기준 시점을 동일하게 유지
        const annualDivGrowthRateDecimal = asset.expectedAnnualDividendGrowthRate / 100;
        const mDivGrowth = Math.pow(1 + annualDivGrowthRateDecimal, 1 / 12) - 1;
        state.currentDps *= 1 + mDivGrowth;

        // 2. 투자 풀 구성 (매월 적립금 + 직전 잔돈)
        let pool = asset.monthlyContributionAmount + state.cashBalance;

        // 3. 배당금 수령 및 재투자 여부 처리 (지급 달에만 실행)
        if (asset.isDividendAsset && m % (12 / asset.dividendFrequency) === 0) {
          // dps는 이미 매달 성장 중이므로 지급 달에는 지급만 처리
          const divCash = state.heldShares * state.currentDps;
          if (asset.isReinvestDividends) {
            pool += divCash;
          } else {
            state.accumulatedDiv += divCash;
          }
        }

        // 4. 새로운 가격으로 주식 추가 매수 집행
        const newShares = Math.floor(pool / state.currentPrice);
        state.heldShares += newShares;
        state.cashBalance = pool % state.currentPrice;

        // 5. 포트폴리오 가치 집계
        // [수정 2] accumulatedDiv 제거 - 인출된 배당금은 포트폴리오 가치에 포함하지 않음
        currentTotalPortfolioValue += state.currentPrice * state.heldShares + state.cashBalance;

        // 6. 월 배당금 집계
        // dps가 매달 갱신되므로 frequency로 나눠 월 환산하면 자산 간 기준이 일치
        if (asset.isDividendAsset) {
          currentTotalMonthlyDividend +=
            (state.heldShares * state.currentDps * asset.dividendFrequency) / 12;
        }
      }

      // 목표 도달 여부 판단
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

      // 모든 목표가 완료되면 루프 탈출
      if (
        portfolioValueReachedMonths !== null &&
        (!hasDivAssets || monthlyDividendReachedMonths !== null)
      ) {
        break;
      }
    }

    return {
      portfolioValueGoal: { expectedMonthsToTarget: portfolioValueReachedMonths },
      monthlyDividendGoal: { expectedMonthsToTarget: monthlyDividendReachedMonths },
    };
  }

  // --- Core Utility Helpers ---

  // Box-Muller 변환을 이용한 클로저 기반 난수 생성기
  private createRandomGenerator(seedStr?: string) {
    if (!seedStr) {
      return this.wrapStandardNormal(Math.random);
    }

    // FNV-1a 해싱 알고리즘을 통한 시드 정수화
    let h = 2166136261 >>> 0;
    for (let i = 0; i < seedStr.length; i++) {
      h = Math.imul(h ^ seedStr.charCodeAt(i), 16777619);
    }
    let s = h >>> 0;

    // Mulberry32 알고리즘 (균등분포 난수)
    const mulberry32 = () => {
      let t = (s += 0x6d2b79f5);
      t = Math.imul(t ^ (t >>> 15), t | 1);
      t ^= t + Math.imul(t ^ (t >>> 7), t | 61);
      return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
    };
    return this.wrapStandardNormal(mulberry32);
  }

  // 균등분포 난수를 표준정규분포로 변환 (Box-Muller)
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

  // 기하 브라운 운동(GBM) 기반의 확률적 단일 경로 시뮬레이션
  private simulateStochasticTrajectory(
    months: number,
    asset: AssetInputDto,
    getNextRandom: () => number
  ) {
    // Month 0: 초기 투자 금액으로 주식 선매수 후 시작 상태 설정
    let price = asset.initialPrice;
    let shares = Math.floor(asset.initialInvestmentAmount / price);
    let balance = asset.initialInvestmentAmount % price;
    let dps = asset.dividendPerShare;
    let accumulatedDiv = 0; // 비재투자 배당금은 즉시 인출된 것으로 간주하여 finalValue에 포함하지 않음

    const annualPriceGrowthRateDecimal = asset.expectedAnnualPriceGrowthRate / 100;
    const mGrowth = Math.pow(1 + annualPriceGrowthRateDecimal, 1 / 12) - 1;
    const monthlyVolatility = monthlyVolatilityMap[asset.assetType];

    for (let m = 1; m <= months; m++) {
      // 1. 기하 브라운 운동(GBM) 공식 적용 및 드리프트 보정 (Drift Correction)
      // 평균 성장률이 정확히 mGrowth를 추종하도록 통계적 편향 제거
      const driftCorrection = -0.5 * Math.pow(monthlyVolatility, 2);
      const randomShock = monthlyVolatility * getNextRandom();
      price = price * (1 + mGrowth) * Math.exp(driftCorrection + randomShock);
      price = this.normalizeSimulatedPrice(price);

      // 2. 투자 풀 구성 (매월 적립금 + 직전 잔돈)
      let pool = asset.monthlyContributionAmount + balance;

      // 3. 배당금 수령 및 재투자 처리
      if (asset.isDividendAsset && m % (12 / asset.dividendFrequency) === 0) {
        const rawG = this.calculatePeriodG(
          asset.dividendFrequency,
          asset.expectedAnnualDividendGrowthRate / 100,
          getNextRandom
        );
        dps *= 1 + this.checkClampRange(rawG, asset.dividendFrequency);

        const divCash = shares * dps;
        if (asset.isReinvestDividends) {
          pool += divCash;
        } else {
          accumulatedDiv += divCash;
        }
      }

      // 4. 새로운 주가로 추가 매수 집행
      const newShares = Math.floor(pool / price);
      shares += newShares;
      balance = pool % price;
    }

    // 최종 월 배당금 환산 (Run-rate 방식)
    // dps는 지급 달에만 갱신되므로 frequency로 나눠 월 환산
    const terminalMonthlyDividend = asset.isDividendAsset
      ? (shares * dps * asset.dividendFrequency) / 12
      : 0;

    return {
      finalValue: price * shares + balance,
      terminalMonthlyDividend,
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

  private normalizeSimulatedPrice(nextPrice: number): number {
    if (!Number.isFinite(nextPrice) || nextPrice < minimumAbsolutePrice) {
      return minimumAbsolutePrice;
    }
    return nextPrice;
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
