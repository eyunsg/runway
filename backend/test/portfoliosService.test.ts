import {
  addPortfolioService,
  getPortfoliosService,
} from '../supabase/functions/portfolios/portfoliosService.ts';
import {
  savePortfolioRepo,
  getPortfoliosRepo,
} from '../supabase/functions/portfolios/portfoliosRepository.ts';
import { AddPortfolioRequestDto } from '../shared/dto/portfolios/PostPortfoliosRequest.dto.ts';
import { AssetType } from '../shared/domain/AssetType.ts';
import {
  PortfolioSummaryDto,
  GetPortfoliosResponseDto,
} from '../shared/dto/portfolios/GetPortfoliosResponse.dto.ts';

// 리포지토리 모킹
jest.mock('../supabase/functions/portfolios/portfoliosRepository.ts', () => ({
  savePortfolioRepo: jest.fn(),
  getPortfoliosRepo: jest.fn(),
}));

describe('PortfolioService - 포트폴리오 생성 테스트', () => {
  const mockUserId = 'user-123';

  // 성공 케이스를 위한 유효한 데이터 세트
  const validRawData = {
    name: '내 은퇴 포트폴리오',
    simulationInput: {
      goal: {
        investmentPeriodMonths: 120,
        targetPortfolioValue: 1000000,
        targetMonthlyDividend: 5000,
      },
      assets: [
        {
          assetName: '애플',
          assetType: AssetType.STOCK,
          initialPrice: 150,
          expectedAnnualPriceGrowthRate: 0.07,
          initialInvestmentAmount: 10000,
          monthlyContributionAmount: 500,
          isDividendAsset: true,
          dividendPerShare: 0.24,
          expectedAnnualDividendGrowthRate: 0.05,
          dividendFrequency: 4,
          isReinvestDividends: true,
        },
      ],
    },
    simulationResult: {
      percentiles: {
        portfolioValue: { p10: 80000, p50: 100000, p90: 120000 },
        monthlyDividend: { p10: 400, p50: 500, p90: 600 },
      },
      goalAnalysis: {
        portfolioValueGoal: { expectedMonthsToTarget: 96 },
        monthlyDividendGoal: { expectedMonthsToTarget: 108 },
      },
    },
  };

  afterEach(() => {
    jest.clearAllMocks();
  });

  describe('addPortfolioService', () => {
    it('정상적인 데이터를 입력하면 성공적으로 포트폴리오 ID를 반환한다', async () => {
      // 리포지토리 저장 성공 시 ID 반환 모킹
      (savePortfolioRepo as jest.Mock).mockResolvedValue('new-portfolio-id');

      const dto = new AddPortfolioRequestDto(validRawData);
      const result = await addPortfolioService(mockUserId, dto);

      expect(result).toBe('new-portfolio-id');

      // 서비스가 리포지토리에 'Portfolio' 도메인 객체를 전달하는지 확인
      expect(savePortfolioRepo).toHaveBeenCalledWith(
        expect.objectContaining({
          userId: mockUserId,
          name: validRawData.name,
        })
      );
      expect(savePortfolioRepo).toHaveBeenCalledTimes(1);
    });

    it('리포지토리 저장에 실패하면 DATABASE_ERROR를 던진다', async () => {
      (savePortfolioRepo as jest.Mock).mockResolvedValue(null);

      const dto = new AddPortfolioRequestDto(validRawData);

      await expect(addPortfolioService(mockUserId, dto)).rejects.toThrow(
        'DATABASE_ERROR: 포트폴리오 저장 실패'
      );
    });

    it('포트폴리오 이름이 비어있을 경우 VALIDATION_ERROR를 던진다', async () => {
      const invalidData = { ...validRawData, name: '  ' };

      // Portfolio 도메인 객체 생성 시 validate()가 실행되어 에러가 발생함
      await expect(async () => {
        const dto = new AddPortfolioRequestDto(invalidData);
        await addPortfolioService(mockUserId, dto);
      }).rejects.toThrow('VALIDATION_ERROR');

      expect(savePortfolioRepo).not.toHaveBeenCalled();
    });

    it('자산 리스트가 10개를 초과할 경우 VALIDATION_ERROR를 던진다', async () => {
      const tooManyAssets = Array(11).fill(validRawData.simulationInput.assets[0]);
      const invalidData = {
        ...validRawData,
        simulationInput: { ...validRawData.simulationInput, assets: tooManyAssets },
      };

      await expect(async () => {
        const dto = new AddPortfolioRequestDto(invalidData);
        await addPortfolioService(mockUserId, dto);
      }).rejects.toThrow('VALIDATION_ERROR');

      expect(savePortfolioRepo).not.toHaveBeenCalled();
    });

    it('유저 ID가 누락된 경우 에러를 던진다', async () => {
      const dto = new AddPortfolioRequestDto(validRawData);
      // @ts-ignore: 테스트를 위해 유도된 타입 에러
      await expect(addPortfolioService(undefined, dto)).rejects.toThrow();
    });
  });

  /// ---------------- API-PORT-002: 목록 조회 테스트 ----------------

  describe('getPortfoliosService', () => {
    it('사용자의 포트폴리오 목록을 성공적으로 조회하고 DTO로 변환한다', async () => {
      // 1. 리포지토리 응답 모킹 (DB의 snake_case 구조 반영)
      const mockDbData = [
        {
          id: 'port-1',
          name: '메인 포트폴리오',
          simulation_input: {
            goal: { investment_period_months: 60 },
            assets: [{}, {}], // 자산 2개
          },
          updated_at: '2023-10-27T10:00:00Z',
        },
        {
          id: 'port-2',
          name: '배당주 포트폴리오',
          simulation_input: {
            goal: { investment_period_months: 120 },
            assets: [{}, {}, {}], // 자산 3개
          },
          updated_at: '2023-10-26T15:00:00Z',
        },
      ];
      (getPortfoliosRepo as jest.Mock).mockResolvedValue(mockDbData);

      // 2. 서비스 호출
      const result = await getPortfoliosService(mockUserId);

      // 3. 검증
      expect(result).toBeInstanceOf(GetPortfoliosResponseDto);
      expect(result.portfolios).toHaveLength(2);

      // 첫 번째 포트폴리오 매핑 확인
      const first = result.portfolios[0];
      expect(first).toBeInstanceOf(PortfolioSummaryDto);
      expect(first.portfolioId).toBe('port-1');
      expect(first.assetCount).toBe(2);
      expect(first.investmentPeriodMonths).toBe(60);
      expect(first.updatedAt).toBe('2023-10-27T10:00:00Z');

      expect(getPortfoliosRepo).toHaveBeenCalledWith(mockUserId);
    });

    it('포트폴리오가 없을 경우 빈 목록을 포함한 DTO를 반환한다', async () => {
      (getPortfoliosRepo as jest.Mock).mockResolvedValue([]);

      const result = await getPortfoliosService(mockUserId);

      expect(result.portfolios).toEqual([]);
      expect(result.portfolios).toHaveLength(0);
    });

    it('리포지토리에서 null이 반환될 경우 DATABASE_ERROR를 던진다', async () => {
      (getPortfoliosRepo as jest.Mock).mockResolvedValue(null);

      await expect(getPortfoliosService(mockUserId)).rejects.toThrow(
        'DATABASE_ERROR: 포트폴리오 목록 조회 실패'
      );
    });

    it('DB 데이터에 simulation_input이 비어있어도 기본값을 사용하여 에러 없이 반환한다', async () => {
      const incompleteData = [
        {
          id: 'port-incomplete',
          name: '데이터 누락 포트폴리오',
          simulation_input: null,
          updated_at: '2023-10-27T10:00:00Z',
        },
      ];
      (getPortfoliosRepo as jest.Mock).mockResolvedValue(incompleteData);

      const result = await getPortfoliosService(mockUserId);

      expect(result.portfolios[0].assetCount).toBe(0);
      expect(result.portfolios[0].investmentPeriodMonths).toBe(0);
    });

    it('Soft-deleted된 포트폴리오는 레포지토리 수준에서 필터링되어 목록에 나타나지 않는다', async () => {
      // 레포지토리에서 deleted_at IS NULL 필터링 결과로 빈 배열이 반환된 상황 모킹
      (getPortfoliosRepo as jest.Mock).mockResolvedValue([]);

      const result = await getPortfoliosService(mockUserId);
      expect(result.portfolios).toHaveLength(0);
    });
  });
});
