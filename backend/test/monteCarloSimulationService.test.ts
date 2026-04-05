import { runMonteCarloSimulation } from '../supabase/functions/simulations/monteCarloSimulationService.ts';
import {
  RunMonteCarloSimulationRequestDto,
  AssetInputDto,
} from '../shared/dto/simulations/MonteCarloSimulationRequest.dto.ts';
import { AssetType } from '../shared/domain/AssetType.ts';

describe('runMonteCarloSimulation - Service Logic', () => {
  // 테스트를 위한 기본 자산 데이터 (무배당 자산 기준)
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
    dividendFrequencyPerYear: 12,
    isReinvestDividends: false,
  };

  it('시나리오 1: 결과가 통계적 무결성(p10 <= p50 <= p90)을 유지해야 한다', () => {
    const investmentPeriodMonths = 12;
    const assets = [mockBaseAsset];

    const dto = new RunMonteCarloSimulationRequestDto({ investmentPeriodMonths, assets });
    const result = runMonteCarloSimulation(dto);

    expect(result.portfolioAmount.p10).toBeLessThanOrEqual(result.portfolioAmount.p50);
    expect(result.portfolioAmount.p50).toBeLessThanOrEqual(result.portfolioAmount.p90);
    expect(result.monthlyDividendAmount.p10).toBeLessThanOrEqual(result.monthlyDividendAmount.p50);
  });

  it('시나리오 2: 1개월 차에는 주가 상승률이 적용되지 않고 초기 투자금만 정확히 투입되어야 한다 (Rule 3.1)', () => {
    const investmentPeriodMonths = 1;
    const assets: AssetInputDto[] = [
      {
        ...mockBaseAsset,
        initialPrice: 1000,
        initialInvestmentAmount: 2500,
        monthlyContributionAmount: 0,
      },
    ];

    const dto = new RunMonteCarloSimulationRequestDto({ investmentPeriodMonths, assets });
    const result = runMonteCarloSimulation(dto);

    expect(result.portfolioAmount.p50).toBe(2500);
    expect(result.portfolioAmount.p10).toBe(2500);
    expect(result.portfolioAmount.p90).toBe(2500);
  });

  it('시나리오 3: 배당 재투자(DRIP) 시 최종 자산이 비재투자 시보다 높아야 한다', () => {
    const investmentPeriodMonths = 36;
    const dividendAsset: AssetInputDto = {
      ...mockBaseAsset,
      isDividendAsset: true,
      dividendPerShare: 500,
      expectedAnnualDividendGrowthRate: 5,
      dividendFrequencyPerYear: 12,
    };

    const reinvestOnDto = new RunMonteCarloSimulationRequestDto({
      investmentPeriodMonths,
      assets: [{ ...dividendAsset, isReinvestDividends: true }],
    });
    const reinvestOffDto = new RunMonteCarloSimulationRequestDto({
      investmentPeriodMonths,
      assets: [{ ...dividendAsset, isReinvestDividends: false }],
    });

    const onResult = runMonteCarloSimulation(reinvestOnDto);
    const offResult = runMonteCarloSimulation(reinvestOffDto);

    expect(onResult.portfolioAmount.p50).toBeGreaterThan(offResult.portfolioAmount.p50);
  });

  it('시나리오 4: 배당금을 재투자하지 않으면 월 평균 배당 소득이 발생해야 한다', () => {
    const investmentPeriodMonths = 12;
    const dividendAsset: AssetInputDto = {
      ...mockBaseAsset,
      isDividendAsset: true,
      dividendPerShare: 1000,
      dividendFrequencyPerYear: 12,
      isReinvestDividends: false, // 현금 수령
    };

    const dto = new RunMonteCarloSimulationRequestDto({
      investmentPeriodMonths,
      assets: [dividendAsset],
    });
    const result = runMonteCarloSimulation(dto);

    expect(result.monthlyDividendAmount.p50).toBeGreaterThan(0);
  });

  it('시나리오 5: 배당성장률이 극단적일 경우 클램프 로직에 의해 자산 폭등이 제한되어야 한다', () => {
    const extremeAsset: AssetInputDto = {
      ...mockBaseAsset,
      isDividendAsset: true,
      dividendPerShare: 1000,
      expectedAnnualDividendGrowthRate: 500, // 500%라는 비현실적 성장률
      dividendFrequencyPerYear: 1,
    };

    const dto = new RunMonteCarloSimulationRequestDto({
      investmentPeriodMonths: 24,
      assets: [extremeAsset],
    });
    const result = runMonteCarloSimulation(dto);

    const safetyLimit = 20000000;
    expect(result.portfolioAmount.p50).toBeLessThan(safetyLimit);
  });

  it('시나리오 6: 여러 자산이 입력될 경우 각 자산의 가치가 합산된 후 분위수가 계산되어야 한다', () => {
    const investmentPeriodMonths = 12;
    const assetA = { ...mockBaseAsset, initialInvestmentAmount: 1000000 };
    const assetB = { ...mockBaseAsset, initialInvestmentAmount: 2000000 };

    const singleDto = new RunMonteCarloSimulationRequestDto({
      investmentPeriodMonths,
      assets: [assetA],
    });
    const multiDto = new RunMonteCarloSimulationRequestDto({
      investmentPeriodMonths,
      assets: [assetA, assetB],
    });

    const singleResult = runMonteCarloSimulation(singleDto);
    const multiResult = runMonteCarloSimulation(multiDto);

    expect(multiResult.portfolioAmount.p50).toBeGreaterThan(singleResult.portfolioAmount.p50);
  });

  it('시나리오 7: 장기 투자(10년) 시 주가 상승 및 복리 효과로 인해 원금보다 가치가 높아야 한다', () => {
    const investmentPeriodMonths = 120; // 10년
    const dto = new RunMonteCarloSimulationRequestDto({
      investmentPeriodMonths,
      assets: [
        { ...mockBaseAsset, expectedAnnualPriceGrowthRate: 10, monthlyContributionAmount: 0 },
      ],
    });

    const result = runMonteCarloSimulation(dto);

    expect(result.portfolioAmount.p50).toBeGreaterThan(1000000 * 2);
  });

  it('시나리오 8: 변동성이 큰 자산(CRYPTO)은 변동성이 낮은 자산보다 p10과 p90의 간격이 넓어야 한다', () => {
    const period = 24;
    const cryptoDto = new RunMonteCarloSimulationRequestDto({
      investmentPeriodMonths: period,
      assets: [{ ...mockBaseAsset, assetType: AssetType.CRYPTO }],
    });
    const indexDto = new RunMonteCarloSimulationRequestDto({
      investmentPeriodMonths: period,
      assets: [{ ...mockBaseAsset, assetType: AssetType.INDEX }],
    });

    const cryptoRes = runMonteCarloSimulation(cryptoDto);
    const indexRes = runMonteCarloSimulation(indexDto);

    const cryptoSpread = cryptoRes.portfolioAmount.p90 - cryptoRes.portfolioAmount.p10;
    const indexSpread = indexRes.portfolioAmount.p90 - indexRes.portfolioAmount.p10;

    expect(cryptoSpread).toBeGreaterThan(indexSpread);
  });
});
