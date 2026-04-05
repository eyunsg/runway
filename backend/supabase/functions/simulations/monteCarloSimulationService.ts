import { AssetType } from '../../../shared/domain/AssetType.ts';
import {
  RunMonteCarloSimulationRequestDto,
  AssetInputDto,
} from '../../../shared/dto/simulations/MonteCarloSimulationRequest.dto.ts';

const numSimulations = 10000;
const annualDividendGrowthRateVolatility = 0.02;

const volatilityMap: Record<AssetType, number> = {
  [AssetType.STOCK]: 0.08,
  [AssetType.CRYPTO]: 0.2,
  [AssetType.INDEX]: 0.035,
  [AssetType.COMMODITY]: 0.06,
  [AssetType.GOLD]: 0.02,
};

function validateStatisticalConsistency(
  label: string,
  p: { p10: number; p50: number; p90: number }
): void {
  if (p.p10 > p.p50 || p.p50 > p.p90) {
    throw new Error(
      `Statistical Validity Error [${label}]: p10 <= p50 <= p90 조건을 위반했습니다.`
    );
  }
}

export function runMonteCarloSimulation(dto: RunMonteCarloSimulationRequestDto) {
  const { investmentPeriodMonths, assets } = dto;
  const portfolioValueResults = new Float64Array(numSimulations);
  const monthlyDividendResults = new Float64Array(numSimulations);

  for (let i = 0; i < numSimulations; i++) {
    let iterationPortfolioTotalAmount = 0;
    let iterationDividendTotalAmount = 0;

    for (const asset of assets) {
      const getNextRandom = createRandomGenerator();

      // 데이터 보정 (Data Correction) 로직 - Service 레이어에서 수행
      const simulationAsset = { ...asset };
      if (!simulationAsset.isDividendAsset) {
        simulationAsset.dividendPerShare = 0;
        simulationAsset.expectedAnnualDividendGrowthRate = 0;
        simulationAsset.dividendFrequencyPerYear = 0;
      }

      const { finalValue, totalDividendIncome } = simulateTrajectory(
        investmentPeriodMonths,
        simulationAsset,
        getNextRandom
      );

      iterationPortfolioTotalAmount += finalValue;
      iterationDividendTotalAmount += totalDividendIncome;
    }

    portfolioValueResults[i] = iterationPortfolioTotalAmount;
    monthlyDividendResults[i] = iterationDividendTotalAmount / investmentPeriodMonths;
  }

  // 결과 생성
  const results = {
    portfolioAmount: calculatePercentiles(portfolioValueResults),
    monthlyDividendAmount: calculatePercentiles(monthlyDividendResults),
  };

  // 반환 전 최종 통계적 타당성 검증
  validateStatisticalConsistency('Portfolio Amount', results.portfolioAmount);
  validateStatisticalConsistency('Monthly Dividend Amount', results.monthlyDividendAmount);

  return results;
}

// --- Helper Functions ---

function calculatePercentiles(results: Float64Array) {
  results.sort();
  return {
    p10: Math.round(results[1000]),
    p50: Math.round(results[5000]),
    p90: Math.round(results[9000]),
  };
}

function createRandomGenerator() {
  let spare: number | null = null;
  return function getNextRandom(): number {
    if (spare !== null) {
      const v = spare;
      spare = null;
      return v;
    }
    const u = 1 - Math.random(),
      v = 1 - Math.random();
    const r = Math.sqrt(-2.0 * Math.log(u)),
      theta = 2.0 * Math.PI * v;
    spare = r * Math.sin(theta);
    return r * Math.cos(theta);
  };
}

function calculateClampedDividendGrowthRate(growthRate: number, frequencyPerYear: number): number {
  const annualGrowthRate = Math.pow(1 + growthRate, frequencyPerYear) - 1;
  const clampedAnnualRate = Math.max(-0.2, Math.min(0.15, annualGrowthRate));
  return Math.pow(1 + clampedAnnualRate, 1 / frequencyPerYear) - 1;
}

function calculatePeriodDividendGrowthRate(
  annualDividendGrowthRate: number,
  frequencyPerYear: number,
  getNextRandom: () => number
): number {
  const periodGrowthRate = Math.pow(1 + annualDividendGrowthRate / 100, 1 / frequencyPerYear) - 1;
  const periodVolatility = annualDividendGrowthRateVolatility / Math.sqrt(frequencyPerYear);
  return periodGrowthRate + periodVolatility * getNextRandom();
}

function simulateTrajectory(
  investmentPeriodMonths: number,
  asset: AssetInputDto,
  getNextRandom: () => number
): { finalValue: number; totalDividendIncome: number } {
  let currentPrice = asset.initialPrice;
  let sharesCount = 0;
  let cashBalanceAmount = 0;
  let dividendPerShareAmount = asset.dividendPerShare;
  let accumulatedDividendIncomeAmount = 0;

  const monthlyReturnRate = Math.pow(1 + asset.expectedAnnualPriceGrowthRate / 100, 1 / 12) - 1;
  const annualVolatility = volatilityMap[asset.assetType as AssetType] || 0.05;
  const monthlyVolatility = annualVolatility / Math.sqrt(12);

  for (let m = 1; m <= investmentPeriodMonths; m++) {
    if (m === 1) {
      sharesCount = Math.floor(asset.initialInvestmentAmount / currentPrice);
      cashBalanceAmount = asset.initialInvestmentAmount % currentPrice;
    } else {
      const z = getNextRandom();
      currentPrice *= 1 + (monthlyReturnRate + monthlyVolatility * z);

      let monthlyInvestmentPoolAmount = asset.monthlyContributionAmount + cashBalanceAmount;

      // [피드백 반영] dividendFrequencyPerYear 네이밍 사용
      if (asset.isDividendAsset && m % (12 / asset.dividendFrequencyPerYear) === 0) {
        const rawGrowth = calculatePeriodDividendGrowthRate(
          asset.expectedAnnualDividendGrowthRate,
          asset.dividendFrequencyPerYear,
          getNextRandom
        );
        const clampedGrowth = calculateClampedDividendGrowthRate(
          rawGrowth,
          asset.dividendFrequencyPerYear
        );

        dividendPerShareAmount *= 1 + clampedGrowth;
        const dividendCashAmount = sharesCount * dividendPerShareAmount;

        if (asset.isReinvestDividends) {
          monthlyInvestmentPoolAmount += dividendCashAmount;
        } else {
          accumulatedDividendIncomeAmount += dividendCashAmount;
        }
      }

      const buyableShares = Math.floor(monthlyInvestmentPoolAmount / currentPrice);
      sharesCount += buyableShares;
      cashBalanceAmount = monthlyInvestmentPoolAmount % currentPrice;
    }
  }

  return {
    finalValue: currentPrice * sharesCount + accumulatedDividendIncomeAmount + cashBalanceAmount,
    totalDividendIncome: accumulatedDividendIncomeAmount,
  };
}
