import { AssetType } from '../../../shared/domain/AssetType.ts';
import { AssetInputDto } from '../../../shared/dto/simulations/MonteCarloSimulationRequest.dto.ts';

const numSimulations = 10000;
const annualDividendGrowthRateVolatility = 0.02; // 모든 자산 공통 연 변동성 2%

const volatilityMap: Record<AssetType, number> = {
  [AssetType.STOCK]: 0.08,
  [AssetType.CRYPTO]: 0.2,
  [AssetType.INDEX]: 0.035,
  [AssetType.COMMODITY]: 0.06,
  [AssetType.GOLD]: 0.02,
};

function createRandomGenerator() {
  let spare: number | null = null;
  function generatePair(): number[] {
    const u = 1 - Math.random();
    const v = 1 - Math.random();
    const r = Math.sqrt(-2.0 * Math.log(u));
    const theta = 2.0 * Math.PI * v;
    return [r * Math.cos(theta), r * Math.sin(theta)];
  }
  return function getNextRandom(): number {
    if (spare !== null) {
      const value = spare;
      spare = null;
      return value;
    }
    const [z1, z2] = generatePair();
    spare = z2;
    return z1;
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

function calculateNextPrice(
  currentPrice: number,
  monthlyReturnRate: number,
  monthlyVolatility: number,
  z: number
): number {
  return currentPrice * (1 + (monthlyReturnRate + monthlyVolatility * z));
}

function executeMonthlyTrade(
  investPoolAmount: number,
  price: number
): { shares: number; balance: number } {
  return {
    shares: Math.floor(investPoolAmount / price),
    balance: investPoolAmount % price,
  };
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
      const trade = executeMonthlyTrade(asset.initialInvestmentAmount, currentPrice);
      sharesCount = trade.shares;
      cashBalanceAmount = trade.balance;
    } else {
      const z = getNextRandom();
      currentPrice = calculateNextPrice(currentPrice, monthlyReturnRate, monthlyVolatility, z);

      let monthlyInvestmentPoolAmount = asset.monthlyContributionAmount + cashBalanceAmount;

      if (asset.isDividendAsset && m % (12 / asset.dividendFrequency) === 0) {
        const rawDividendGrowthRate = calculatePeriodDividendGrowthRate(
          asset.expectedAnnualDividendGrowthRate,
          asset.dividendFrequency,
          getNextRandom
        );
        const growthRate = calculateClampedDividendGrowthRate(
          rawDividendGrowthRate,
          asset.dividendFrequency
        );

        dividendPerShareAmount *= 1 + growthRate;
        const dividendCashAmount = sharesCount * dividendPerShareAmount;

        if (asset.isReinvestDividends) {
          monthlyInvestmentPoolAmount += dividendCashAmount;
        } else {
          accumulatedDividendIncomeAmount += dividendCashAmount;
        }
      }

      const trade = executeMonthlyTrade(monthlyInvestmentPoolAmount, currentPrice);
      sharesCount += trade.shares;
      cashBalanceAmount = trade.balance;
    }
  }

  return {
    finalValue: currentPrice * sharesCount + accumulatedDividendIncomeAmount + cashBalanceAmount,
    totalDividendIncome: accumulatedDividendIncomeAmount,
  };
}

export function runMonteCarloSimulation(investmentPeriodMonths: number, assets: AssetInputDto[]) {
  const portfolioValueResults = new Float64Array(numSimulations);
  const monthlyDividendResults = new Float64Array(numSimulations);

  for (let i = 0; i < numSimulations; i++) {
    let iterationPortfolioTotalAmount = 0;
    let iterationDividendTotalAmount = 0;

    for (const asset of assets) {
      const getNextRandom = createRandomGenerator();
      const { finalValue, totalDividendIncome } = simulateTrajectory(
        investmentPeriodMonths,
        asset,
        getNextRandom
      );

      iterationPortfolioTotalAmount += finalValue;
      iterationDividendTotalAmount += totalDividendIncome;
    }

    portfolioValueResults[i] = iterationPortfolioTotalAmount;
    monthlyDividendResults[i] = iterationDividendTotalAmount / investmentPeriodMonths;
  }

  return {
    portfolioValue: calculatePercentiles(portfolioValueResults),
    monthlyDividend: calculatePercentiles(monthlyDividendResults),
  };
}

function calculatePercentiles(results: Float64Array) {
  results.sort();

  return {
    p10: Math.round(results[Math.floor(numSimulations * 0.1)]),
    p50: Math.round(results[Math.floor(numSimulations * 0.5)]),
    p90: Math.round(results[Math.floor(numSimulations * 0.9)]),
  };
}
