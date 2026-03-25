import { AssetInputDto } from '../../../shared/dto/montecarlo/MonteCarloSimulationRequest.dto.ts';

const NUM_SIMULATIONS = 10000;
const DGR_VOLATILITY_ANNUAL = 0.02; // 모든 자산 공통 연 변동성 2%

const VOLATILITY_MAP: Record<string, number> = {
  '개별 주식': 0.08,
  암호화폐: 0.2,
  '인덱스형 자산': 0.035,
  원자재: 0.06,
  금: 0.02,
};

// 난수 관리용 (Box-Muller)
let spareZ: number | null = null;

function generateBoxMullerPair(): number[] {
  const u = 1 - Math.random();
  const v = 1 - Math.random();
  const r = Math.sqrt(-2.0 * Math.log(u));
  const theta = 2.0 * Math.PI * v;
  return [r * Math.cos(theta), r * Math.sin(theta)];
}

function getNextRandom(): number {
  if (spareZ !== null) {
    const z = spareZ;
    spareZ = null;
    return z;
  }
  const [z1, z2] = generateBoxMullerPair();
  spareZ = z2;
  return z1;
}

function checkClampRange(g: number, frequency: number): number {
  const annual_g = Math.pow(1 + g, frequency) - 1;
  const clamped_annual_g = Math.max(-0.2, Math.min(0.15, annual_g));
  return Math.pow(1 + clamped_annual_g, 1 / frequency) - 1;
}

function calculatePeriodG(annual_dgr: number, frequency: number, z: number): number {
  const period_dgr = Math.pow(1 + annual_dgr / 100, 1 / frequency) - 1;
  const theta_period = DGR_VOLATILITY_ANNUAL / Math.sqrt(frequency);
  return period_dgr + theta_period * z;
}

function calculateNextPrice(
  current_price: number,
  monthly_return: number,
  monthly_volatility: number,
  z: number
): number {
  return current_price * (1 + (monthly_return + monthly_volatility * z));
}

function executeMonthlyTrade(
  invest_pool: number,
  price: number
): { shares: number; balance: number } {
  return {
    shares: Math.floor(invest_pool / price),
    balance: invest_pool % price,
  };
}

// 단일 시나리오 시뮬레이션 (Value + Dividend Flow 통합)
function simulateTrajectory(months: number, asset: AssetInputDto): number {
  let price = asset.initialPrice;
  let shares = 0;
  let balance = 0;
  let dps = asset.dividendPerShare;
  let cumulative_dividend = 0;

  const monthly_return = Math.pow(1 + asset.expectedAnnualPriceGrowthRate / 100, 1 / 12) - 1;
  const monthly_volatility = VOLATILITY_MAP[asset.assetType] || 0.05;

  for (let m = 1; m <= months; m++) {
    if (m === 1) {
      // 3.1 최초 매수: 주가 상승률 적용 없이 초기 투자금만 투입
      const trade = executeMonthlyTrade(asset.initialInvestmentAmount, price);
      shares = trade.shares;
      balance = trade.balance;
    } else {
      // 1. 난수 확보
      const z = getNextRandom();

      // 2. 주가 정보 갱신
      price = calculateNextPrice(price, monthly_return, monthly_volatility, z);

      // 3. 배당 및 재투자 로직
      let invest_pool = asset.monthlyContributionAmount + balance;

      if (asset.isDividendAsset && m % (12 / asset.dividendFrequency) === 0) {
        const z_dgr = getNextRandom();
        const raw_g = calculatePeriodG(
          asset.expectedAnnualDividendGrowthRate,
          asset.dividendFrequency,
          z_dgr
        );
        const g = checkClampRange(raw_g, asset.dividendFrequency);

        dps *= 1 + g;
        const div_cash = shares * dps;

        if (asset.isReinvestDividends) {
          invest_pool += div_cash;
        } else {
          cumulative_dividend += div_cash;
        }
      }

      // 4. 매수 집행 및 잔액 이월
      const trade = executeMonthlyTrade(invest_pool, price);
      shares += trade.shares;
      balance = trade.balance;
    }
  }

  // 최종 가치 = (최종 가격 * 보유수량) + 누적 배당금 + 최종 잔액
  return price * shares + cumulative_dividend + balance;
}

export function runMonteCarloSimulation(months: number, assets: AssetInputDto[]) {
  let aggregator_p10 = 0;
  let aggregator_p50 = 0;
  let aggregator_p90 = 0;

  for (const asset of assets) {
    const results = new Float64Array(NUM_SIMULATIONS);
    for (let i = 0; i < NUM_SIMULATIONS; i++) {
      spareZ = null; // 시나리오마다 난수 상태 초기화
      results[i] = simulateTrajectory(months, asset);
    }

    results.sort();

    // 개별 자산의 Percentiles 도출 및 합산 (Aggregator)
    aggregator_p10 += results[1000];
    aggregator_p50 += results[5000];
    aggregator_p90 += results[9000];
  }

  return {
    portfolioValue: { p10: aggregator_p10, p50: aggregator_p50, p90: aggregator_p90 },
    monthlyDividend: { p10: 0, p50: 0, p90: 0 }, // v1 placeholder
  };
}
