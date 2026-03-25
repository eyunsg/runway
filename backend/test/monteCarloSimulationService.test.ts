import { runMonteCarloSimulation } from '../supabase/functions/simulations/monteCarloSimulationService';
import { AssetInputDto } from '../shared/dto/montecarlo/MonteCarloSimulationRequest.dto';

describe('runMonteCarloSimulation - Service Logic', () => {
  // 테스트를 위한 기본 자산 데이터 (무배당 자산)
  const mockBaseAsset: AssetInputDto = {
    assetName: '테스트 자산',
    assetType: '인덱스형 자산',
    initialPrice: 10000,
    expectedAnnualPriceGrowthRate: 5,
    initialInvestmentAmount: 1000000,
    monthlyContributionAmount: 100000,
    isDividendAsset: false,
    dividendPerShare: 0,
    expectedAnnualDividendGrowthRate: 0,
    dividendFrequency: 12,
    isReinvestDividends: false,
  };

  afterEach(() => {
    jest.clearAllMocks();
  });

  it('시뮬레이션 결과가 통계적 무결성(P10 <= P50 <= P90)을 유지해야 한다', () => {
    const months = 12;
    const assets = [mockBaseAsset];

    // 서비스가 동기 함수이므로 await를 사용하지 않습니다.
    const result = runMonteCarloSimulation(months, assets);

    expect(result.portfolioValue.p10).toBeLessThanOrEqual(result.portfolioValue.p50);
    expect(result.portfolioValue.p50).toBeLessThanOrEqual(result.portfolioValue.p90);
  });

  it('1개월 차에는 주가 상승률이 적용되지 않고 초기 투자금만 정확히 투입되어야 한다 (Rule 3.1)', () => {
    const months = 1;
    const assets: AssetInputDto[] = [
      {
        ...mockBaseAsset,
        initialPrice: 1000,
        initialInvestmentAmount: 2500, // 2주 매수, 500원 잔액 발생 기대
        monthlyContributionAmount: 0,
      },
    ];

    const result = runMonteCarloSimulation(months, assets);

    // 1개월차 결과는 확정적이므로 P10, P50, P90이 모두 동일해야 함 (2주*1000원 + 500원 = 2500원)
    expect(result.portfolioValue.p50).toBe(2500);
    expect(result.portfolioValue.p10).toBe(2500);
    expect(result.portfolioValue.p90).toBe(2500);
  });

  it('배당 재투자(DRIP)를 선택하면 선택하지 않았을 때보다 최종 자산 가치가 높아야 한다', () => {
    const months = 36; // 3년
    const divAsset: AssetInputDto = {
      ...mockBaseAsset,
      isDividendAsset: true,
      dividendPerShare: 500,
      expectedAnnualDividendGrowthRate: 5,
      dividendFrequency: 12,
    };

    const reinvestOn = runMonteCarloSimulation(months, [
      { ...divAsset, isReinvestDividends: true },
    ]);
    const reinvestOff = runMonteCarloSimulation(months, [
      { ...divAsset, isReinvestDividends: false },
    ]);

    // 재투자 시 복리 효과로 인해 중위값(P50)이 더 높아야 함
    expect(reinvestOn.portfolioValue.p50).toBeGreaterThan(reinvestOff.portfolioValue.p50);
  });

  it('배당성장률이 극단적일 경우 클램프 로직(-20% ~ 15%)에 의해 제한되어야 한다', () => {
    const extremeAsset: AssetInputDto = {
      ...mockBaseAsset,
      isDividendAsset: true,
      dividendPerShare: 1000,
      expectedAnnualDividendGrowthRate: 500, // 비정상적인 500% 성장률 입력
      dividendFrequency: 1,
    };

    const result = runMonteCarloSimulation(24, [extremeAsset]);

    // 클램핑이 작동한다면 자산 가치가 비상식적으로 폭등하지 않아야 함
    const maxPossibleWithClamp = 10000000;
    expect(result.portfolioValue.p50).toBeLessThan(maxPossibleWithClamp);
  });

  it('여러 자산이 입력될 경우 각 자산의 결과가 합산(Aggregator)되어야 한다', () => {
    const months = 12;
    const assetA = { ...mockBaseAsset, initialInvestmentAmount: 1000000 };
    const assetB = { ...mockBaseAsset, initialInvestmentAmount: 2000000 };

    const singleAssetA = runMonteCarloSimulation(months, [assetA]);
    const multiAsset = runMonteCarloSimulation(months, [assetA, assetB]);

    // 자산 B가 추가되었으므로 결과값은 단일 자산 A보다 커야 함
    expect(multiAsset.portfolioValue.p50).toBeGreaterThan(singleAssetA.portfolioValue.p50);
  });
});
