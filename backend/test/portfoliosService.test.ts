import {
  addPortfolioService,
  getPortfoliosService,
  getPortfolioDetailService,
  getPortfolioSnapshotDetailService,
  updatePortfolioService,
  deletePortfolioService,
  getRecentPortfoliosService,
} from '../supabase/functions/portfolios/portfoliosService.ts';
import {
  savePortfolioRepo,
  getPortfoliosRepo,
  getPortfolioDetailRepo,
  getPortfolioSnapshotDetailRepo,
  updatePortfolioRepo,
  deletePortfolioRepo,
  getRecentPortfoliosRepo,
} from '../supabase/functions/portfolios/portfoliosRepository.ts';
import { AddPortfolioRequestDto } from '../shared/dto/portfolios/PostPortfoliosRequest.dto.ts';
import { AssetType } from '../shared/domain/AssetType.ts';
import {
  PortfolioSummaryDto,
  GetPortfoliosResponseDto,
} from '../shared/dto/portfolios/GetPortfoliosResponse.dto.ts';
import { GetPortfolioDetailResponseDto } from '../shared/dto/portfolios/GetPortfoliosDetailResponse.dto.ts';
import {
  GetRecentPortfoliosResponseDto,
  RecentPortfolioDto,
} from '../shared/dto/portfolios/GetRecentPortfoliosResponse.dto.ts';

// 리포지토리 모킹
jest.mock('../supabase/functions/portfolios/portfoliosRepository.ts', () => ({
  savePortfolioRepo: jest.fn(),
  getPortfoliosRepo: jest.fn(),
  getPortfolioDetailRepo: jest.fn(),
  getPortfolioSnapshotDetailRepo: jest.fn(),
  updatePortfolioRepo: jest.fn(),
  deletePortfolioRepo: jest.fn(),
  getRecentPortfoliosRepo: jest.fn(),
}));

describe('PortfolioService - 포트폴리오 생성 테스트', () => {
  const mockUserId = 'user-123';
  const mockAuthHeader = 'Bearer mock-token';

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
      const result = await addPortfolioService(mockAuthHeader, mockUserId, dto);

      expect(result).toBe('new-portfolio-id');

      // 서비스가 리포지토리에 'Portfolio' 도메인 객체를 전달하는지 확인
      expect(savePortfolioRepo).toHaveBeenCalledWith(
        mockAuthHeader,
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

      await expect(addPortfolioService(mockAuthHeader, mockUserId, dto)).rejects.toThrow(
        'DATABASE_ERROR: 포트폴리오 저장 실패'
      );
    });

    it('포트폴리오 이름이 비어있을 경우 VALIDATION_ERROR를 던진다', async () => {
      const invalidData = { ...validRawData, name: '  ' };

      // Portfolio 도메인 객체 생성 시 validate()가 실행되어 에러가 발생함
      await expect(async () => {
        const dto = new AddPortfolioRequestDto(invalidData);
        await addPortfolioService(mockAuthHeader, mockUserId, dto);
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
        await addPortfolioService(mockAuthHeader, mockUserId, dto);
      }).rejects.toThrow('VALIDATION_ERROR');

      expect(savePortfolioRepo).not.toHaveBeenCalled();
    });

    it('배당 자산의 dividendFrequency가 숫자가 아니면 VALIDATION_ERROR를 던진다', async () => {
      const invalidData = {
        ...validRawData,
        simulationInput: {
          ...validRawData.simulationInput,
          assets: [
            {
              ...validRawData.simulationInput.assets[0],
              dividendFrequency: 'QUARTERLY',
            },
          ],
        },
      };

      await expect(async () => {
        const dto = new AddPortfolioRequestDto(invalidData);
        await addPortfolioService(mockAuthHeader, mockUserId, dto);
      }).rejects.toThrow('VALIDATION_ERROR');

      expect(savePortfolioRepo).not.toHaveBeenCalled();
    });

    it('유저 ID가 누락된 경우 에러를 던진다', async () => {
      const dto = new AddPortfolioRequestDto(validRawData);
      // @ts-ignore: 테스트를 위해 유도된 타입 에러
      await expect(addPortfolioService(mockAuthHeader, undefined, dto)).rejects.toThrow();
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
      const result = await getPortfoliosService(mockAuthHeader, mockUserId);

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

      expect(getPortfoliosRepo).toHaveBeenCalledWith(mockAuthHeader, mockUserId);
    });

    it('포트폴리오가 없을 경우 빈 목록을 포함한 DTO를 반환한다', async () => {
      (getPortfoliosRepo as jest.Mock).mockResolvedValue([]);

      const result = await getPortfoliosService(mockAuthHeader, mockUserId);

      expect(result.portfolios).toEqual([]);
      expect(result.portfolios).toHaveLength(0);
    });

    it('리포지토리에서 null이 반환될 경우 DATABASE_ERROR를 던진다', async () => {
      (getPortfoliosRepo as jest.Mock).mockResolvedValue(null);

      await expect(getPortfoliosService(mockAuthHeader, mockUserId)).rejects.toThrow(
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

      const result = await getPortfoliosService(mockAuthHeader, mockUserId);

      expect(result.portfolios[0].assetCount).toBe(0);
      expect(result.portfolios[0].investmentPeriodMonths).toBe(0);
    });

    it('Soft-deleted된 포트폴리오는 레포지토리 수준에서 필터링되어 목록에 나타나지 않는다', async () => {
      // 레포지토리에서 deleted_at IS NULL 필터링 결과로 빈 배열이 반환된 상황 모킹
      (getPortfoliosRepo as jest.Mock).mockResolvedValue([]);

      const result = await getPortfoliosService(mockAuthHeader, mockUserId);
      expect(result.portfolios).toHaveLength(0);
    });

    /// ---------------- API-PORT-003: 상세 조회 테스트 ----------------
    describe('getPortfolioDetailService', () => {
      const mockPortfolioId = 'port-555';

      // DB에서 넘어오는 snake_case 형태의 모의 데이터
      const mockDetailDbData = {
        id: mockPortfolioId,
        user_id: mockUserId,
        name: '상세 테스트 포트폴리오',
        simulation_input: {
          goal: {
            investment_period_months: 120,
            target_portfolio_value: 2000000,
            target_monthly_dividend: 10000,
          },
          assets: [
            {
              asset_name: '테슬라',
              asset_type: 'STOCK',
              initial_price: 250,
              expected_annual_price_growth_rate: 0.1,
              initial_investment_amount: 5000,
              monthly_contribution_amount: 1000,
              is_dividend_asset: true,
              dividend_per_share: 0.5,
              expected_annual_dividend_growth_rate: 0.05,
              dividend_frequency: 4,
              is_reinvest_dividends: true,
            },
          ],
        },
        simulation_result: {
          percentiles: {
            portfolio_value: { p10: 1500000, p50: 2100000, p90: 2800000 },
            monthly_dividend: { p10: 800, p50: 1000, p90: 1200 },
          },
          goal_analysis: {
            portfolio_value_goal: {
              achievement_probability: 0.75,
              expected_months_to_target: 84,
            },
            monthly_dividend_goal: {
              achievement_probability: 0.6,
              expected_months_to_target: 96,
            },
          },
        },
        updated_at: '2023-11-01T12:00:00Z',
      };

      it('존재하는 ID로 조회 시 모든 필드가 camelCase로 매핑된 DTO를 반환한다', async () => {
        (getPortfolioDetailRepo as jest.Mock).mockResolvedValue(mockDetailDbData);

        const result = await getPortfolioDetailService(mockAuthHeader, mockUserId, mockPortfolioId);

        // 1. DTO 인스턴스 확인
        expect(result).toBeInstanceOf(GetPortfolioDetailResponseDto);

        // 2. Simulation Input 상세 매핑 확인
        const asset = result.simulationInput.assets[0];
        expect(asset.assetName).toBe('테슬라');
        expect(asset.dividendFrequency).toBe(4);
        expect(asset.isReinvestDividends).toBe(true);

        // 3. Simulation Result 상세 매핑 확인
        expect(result.simulationResult.percentiles.portfolioValue.p50).toBe(2100000);
        expect(
          result.simulationResult.goalAnalysis.monthlyDividendGoal.expectedMonthsToTarget
        ).toBe(96);

        expect(getPortfolioDetailRepo).toHaveBeenCalledWith(
          mockAuthHeader,
          mockUserId,
          mockPortfolioId
        );
      });

      it('존재하지 않거나 권한이 없는 ID 조회 시 NOT_FOUND 에러를 던진다', async () => {
        (getPortfolioDetailRepo as jest.Mock).mockResolvedValue(null);
        await expect(
          getPortfolioDetailService(mockAuthHeader, mockUserId, 'invalid-id')
        ).rejects.toThrow('NOT_FOUND');
      });

      it('DB 데이터의 분석 결과에 확률값이 없을 경우 기본값 0을 적용한다', async () => {
        const dataWithoutProb = {
          ...mockDetailDbData,
          simulation_result: {
            ...mockDetailDbData.simulation_result,
            goal_analysis: {
              portfolio_value_goal: { expected_months_to_target: 100 },
              monthly_dividend_goal: { expected_months_to_target: null },
            },
          },
        };
        (getPortfolioDetailRepo as jest.Mock).mockResolvedValue(dataWithoutProb);

        const result = await getPortfolioDetailService(mockAuthHeader, mockUserId, mockPortfolioId);
        expect(result.simulationResult.goalAnalysis.portfolioValueGoal.achievementProbability).toBe(
          0
        );
      });

      it('자산 리스트가 비어있는 포트폴리오도 정상적으로 처리한다', async () => {
        const noAssetData = {
          ...mockDetailDbData,
          simulation_input: { ...mockDetailDbData.simulation_input, assets: [] },
        };
        (getPortfolioDetailRepo as jest.Mock).mockResolvedValue(noAssetData);

        const result = await getPortfolioDetailService(mockAuthHeader, mockUserId, mockPortfolioId);
        expect(result.simulationInput.assets).toHaveLength(0);
      });

      it('목표 달성 예상 개월수가 null(분석 한계 초과)인 경우를 유지하여 반환한다', async () => {
        const nullMonthsData = {
          ...mockDetailDbData,
          simulation_result: {
            ...mockDetailDbData.simulation_result,
            goal_analysis: {
              portfolio_value_goal: { expected_months_to_target: null },
              monthly_dividend_goal: { expected_months_to_target: null },
            },
          },
        };
        (getPortfolioDetailRepo as jest.Mock).mockResolvedValue(nullMonthsData);

        const result = await getPortfolioDetailService(mockAuthHeader, mockUserId, mockPortfolioId);
        expect(
          result.simulationResult.goalAnalysis.portfolioValueGoal.expectedMonthsToTarget
        ).toBeNull();
      });
    });

    describe('getPortfolioSnapshotDetailService', () => {
      const mockSnapshotId = 'snap-999';

      const mockSnapshotDbData = {
        snapshot_data: {
          name: '스냅샷 포트폴리오',
          simulation_input: {
            goal: {
              investment_period_months: 24,
              target_portfolio_value: 3000000,
              target_monthly_dividend: 15000,
            },
            assets: [
              {
                asset_name: '엔비디아',
                asset_type: 'STOCK',
                initial_price: 900,
                expected_annual_price_growth_rate: 0.12,
                initial_investment_amount: 20000,
                monthly_contribution_amount: 1500,
                is_dividend_asset: false,
                dividend_per_share: 0,
                expected_annual_dividend_growth_rate: 0,
                dividend_frequency: 0,
                is_reinvest_dividends: true,
              },
            ],
          },
          simulation_result: {
            percentiles: {
              portfolio_value: { p10: 1000000, p50: 2500000, p90: 4500000 },
              monthly_dividend: { p10: 100, p50: 300, p90: 600 },
            },
            goal_analysis: {
              portfolio_value_goal: {
                achievement_probability: 0.55,
                expected_months_to_target: 36,
              },
              monthly_dividend_goal: {
                achievement_probability: 0.2,
                expected_months_to_target: 48,
              },
            },
          },
        },
      };

      it('portfolioSnapshotId 기반 조회 시 GetPortfolioDetailResponseDto를 반환한다', async () => {
        (getPortfolioSnapshotDetailRepo as jest.Mock).mockResolvedValue(mockSnapshotDbData);

        const result = await getPortfolioSnapshotDetailService(mockAuthHeader, mockSnapshotId);

        expect(result).toBeInstanceOf(GetPortfolioDetailResponseDto);
        expect(result.name).toBe('스냅샷 포트폴리오');
        expect(result.simulationInput.goal.investmentPeriodMonths).toBe(24);
        expect(result.simulationResult.percentiles.portfolioValue.p50).toBe(2500000);

        expect(getPortfolioSnapshotDetailRepo).toHaveBeenCalledWith(mockAuthHeader, mockSnapshotId);
      });

      it('존재하지 않는 snapshot 조회 시 NOT_FOUND 에러를 던진다', async () => {
        (getPortfolioSnapshotDetailRepo as jest.Mock).mockResolvedValue(null);

        await expect(
          getPortfolioSnapshotDetailService(mockAuthHeader, 'invalid-snap')
        ).rejects.toThrow('NOT_FOUND');
      });

      it('Response 구조가 GetPortfolioDetailResponseDto와 동일하다', async () => {
        (getPortfolioSnapshotDetailRepo as jest.Mock).mockResolvedValue(mockSnapshotDbData);

        const result = await getPortfolioSnapshotDetailService(mockAuthHeader, mockSnapshotId);

        const expectedDto = new GetPortfolioDetailResponseDto(
          '',
          {
            goal: {
              investmentPeriodMonths: 0,
              targetPortfolioValue: 0,
              targetMonthlyDividend: 0,
            },
            assets: [],
          },
          {
            percentiles: {
              portfolioValue: { p10: 0, p50: 0, p90: 0 },
              monthlyDividend: { p10: 0, p50: 0, p90: 0 },
            },
            goalAnalysis: {
              portfolioValueGoal: {
                target: 0,
                achievementProbability: 0,
                expectedMonthsToTarget: 0,
              },
              monthlyDividendGoal: {
                target: 0,
                achievementProbability: 0,
                expectedMonthsToTarget: 0,
              },
            },
          }
        );

        expect(Object.keys(result).sort()).toEqual(Object.keys(expectedDto).sort());
      });
    });
  });

  /// ---------------- API-PORT-007: 최근 포트폴리오 조회 테스트 ----------------
  describe('getRecentPortfoliosService', () => {
    it('최근에 생성/수정된 포트폴리오를 성공적으로 조회하여 GetRecentPortfoliosResponseDto로 변환한다', async () => {
      // 1. 리포지토리 응답 모킹 (최신 레코드 1개 목록 리턴)
      const mockDbData = [
        {
          id: 'port-recent-1',
          name: '최근 수정한 연금 포트폴리오',
          simulation_input: {
            goal: { investment_period_months: 180 },
            assets: [{}, {}, {}], // 자산 3개
          },
          updated_at: '2026-05-17T21:45:00Z',
        },
      ];
      (getRecentPortfoliosRepo as jest.Mock).mockResolvedValue(mockDbData);

      // 2. 서비스 함수 호출
      const result = await getRecentPortfoliosService(mockAuthHeader, mockUserId);

      // 3. 응답 구조 및 값 엄격하게 검증
      expect(result).toBeInstanceOf(GetRecentPortfoliosResponseDto);
      expect(result.portfolios).toHaveLength(1);

      const recent = result.portfolios[0];
      expect(recent).toBeInstanceOf(RecentPortfolioDto);
      expect(recent.portfolioId).toBe('port-recent-1');
      expect(recent.name).toBe('최근 수정한 연금 포트폴리오');
      expect(recent.assetCount).toBe(3);
      expect(recent.investmentPeriodMonths).toBe(180);
      expect(recent.updatedAt).toBe('2026-05-17T21:45:00Z');

      // 리포지토리 최신 1개 조회 제약 준수 확인
      expect(getRecentPortfoliosRepo).toHaveBeenCalledWith(mockAuthHeader, mockUserId, 1);
    });

    it('최근 포트폴리오 데이터가 전혀 존재하지 않으면 빈 portfolios 리스트가 포함된 DTO를 정상 반환한다', async () => {
      (getRecentPortfoliosRepo as jest.Mock).mockResolvedValue([]);

      const result = await getRecentPortfoliosService(mockAuthHeader, mockUserId);

      expect(result).toBeInstanceOf(GetRecentPortfoliosResponseDto);
      expect(result.portfolios).toEqual([]);
      expect(result.portfolios).toHaveLength(0);
    });

    it('리포지토리 조회 중 데이터베이스 에러 발생 시(null 리턴) DATABASE_ERROR를 발생시킨다', async () => {
      (getRecentPortfoliosRepo as jest.Mock).mockResolvedValue(null);

      await expect(getRecentPortfoliosService(mockAuthHeader, mockUserId)).rejects.toThrow(
        'DATABASE_ERROR: 최근 포트폴리오 조회 실패'
      );
    });

    it('DB 데이터에 simulation_input 데이터가 소실되었어도 에러 없이 기본값을 채워 반환한다', async () => {
      const incompleteDbData = [
        {
          id: 'port-broken',
          name: '구조 깨진 최근 포트폴리오',
          simulation_input: null,
          updated_at: '2026-05-17T21:45:00Z',
        },
      ];
      (getRecentPortfoliosRepo as jest.Mock).mockResolvedValue(incompleteDbData);

      const result = await getRecentPortfoliosService(mockAuthHeader, mockUserId);

      expect(result.portfolios[0].assetCount).toBe(0);
      expect(result.portfolios[0].investmentPeriodMonths).toBe(0);
    });
  });
});
