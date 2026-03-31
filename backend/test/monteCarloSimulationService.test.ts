import { runMonteCarloSimulation } from '../supabase/functions/simulations/monteCarloSimulationService.ts';
import { AssetInputDto } from '../shared/dto/simulations/MonteCarloSimulationRequest.dto.ts';
import { AssetType } from '../shared/domain/AssetType.ts';

describe('runMonteCarloSimulation - Service Logic', () => {
  const mockBaseAsset: AssetInputDto = {
    assetName: '테스트 자산',
    assetType: AssetType.INDEX,
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

  it('시뮬레이션 결과가 통계적 무결성(p10 <= p50 <= p90)을 유지해야 한다', () => {
    const investmentPeriodMonths = 12;
    const assets = [mockBaseAsset];

    const result = runMonteCarloSimulation(investmentPeriodMonths, assets);

    expect(result.portfolioValue.p10).toBeLessThanOrEqual(result.portfolioValue.p50);
    expect(result.portfolioValue.p50).toBeLessThanOrEqual(result.portfolioValue.p90);
  });

  it('1개월 차에는 주가 상승률이 적용되지 않고 초기 투자금만 정확히 투입되어야 한다', () => {
    const investmentPeriodMonths = 1;
    const assets: AssetInputDto[] = [
      {
        ...mockBaseAsset,
        initialPrice: 1000,
        initialInvestmentAmount: 2500, // 2주 매수, 500원 잔액 발생 기대
        monthlyContributionAmount: 0,
      },
    ];

    const result = runMonteCarloSimulation(investmentPeriodMonths, assets);

    expect(result.portfolioValue.p50).toBe(2500);
    expect(result.portfolioValue.p10).toBe(2500);
    expect(result.portfolioValue.p90).toBe(2500);
  });

  it('배당 재투자(DRIP)를 선택하면 선택하지 않았을 때보다 최종 자산 가치가 높아야 한다', () => {
    const investmentPeriodMonths = 36;
    const divAsset: AssetInputDto = {
      ...mockBaseAsset,
      isDividendAsset: true,
      dividendPerShare: 500,
      expectedAnnualDividendGrowthRate: 5,
      dividendFrequency: 12,
    };

    const reinvestOnResult = runMonteCarloSimulation(investmentPeriodMonths, [
      { ...divAsset, isReinvestDividends: true },
    ]);
    const reinvestOffResult = runMonteCarloSimulation(investmentPeriodMonths, [
      { ...divAsset, isReinvestDividends: false },
    ]);

    expect(reinvestOnResult.portfolioValue.p50).toBeGreaterThan(
      reinvestOffResult.portfolioValue.p50
    );
  });

  it('배당성장률이 극단적일 경우 클램프 로직에 의해 제한되어야 한다', () => {
    const extremeAsset: AssetInputDto = {
      ...mockBaseAsset,
      isDividendAsset: true,
      dividendPerShare: 1000,
      expectedAnnualDividendGrowthRate: 500, // 500% 성장률 입력
      dividendFrequency: 1,
    };

    const result = runMonteCarloSimulation(24, [extremeAsset]);
    // 클램핑이 작동한다면 자산 가치가 비정상적으로 폭등하지 않아야 함
    const maxPossibleWithClampAmount = 10000000;
    expect(result.portfolioValue.p50).toBeLessThan(maxPossibleWithClampAmount);
  });

  it('여러 자산이 입력될 경우 포트폴리오 가치가 합산되어 계산되어야 한다', () => {
    const investmentPeriodMonths = 12;
    const assetA = { ...mockBaseAsset, initialInvestmentAmount: 1000000 };
    const assetB = { ...mockBaseAsset, initialInvestmentAmount: 2000000 };

    const singleAssetResult = runMonteCarloSimulation(investmentPeriodMonths, [assetA]);
    const multiAssetResult = runMonteCarloSimulation(investmentPeriodMonths, [assetA, assetB]);

    expect(multiAssetResult.portfolioValue.p50).toBeGreaterThan(
      singleAssetResult.portfolioValue.p50
    );
  });
});
