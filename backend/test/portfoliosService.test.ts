import {
  getPortfolios,
  getPortfolioDetail,
  createPortfolio,
  updatePortfolio,
  deletePortfolio,
} from '../services/portfolio.service.ts';
import {
  createPortfolioRepo,
  findPortfolioByIdRepo,
  findPortfoliosByUserIdRepo,
  updatePortfolioRepo,
  deletePortfolioRepo,
} from '../repositories/portfolioRepository.ts';
import { Portfolio } from '../domain/portfolios/portfolios.ts';
import {
  CreatePortfolioRequestDto,
  UpdatePortfolioRequestDto,
} from '../domain/portfolios/portfolios.request.dto.ts';

// 리포지토리 모킹
jest.mock('../repositories/portfolioRepository', () => ({
  createPortfolioRepo: jest.fn(),
  findPortfolioByIdRepo: jest.fn(),
  findPortfoliosByUserIdRepo: jest.fn(),
  updatePortfolioRepo: jest.fn(),
  deletePortfolioRepo: jest.fn(),
}));

describe('PortfolioService - 포트폴리오 비즈니스 로직 테스트', () => {
  const userId = 'user-123';
  const portfolioId = 'portfolio-456';

  // 가상의 포트폴리오 엔티티 생성 헬퍼
  const createMockPortfolio = (id: string, owner: string, name: string) => {
    return new Portfolio(
      id,
      owner,
      name,
      {
        goal: {
          investmentPeriodMonths: 120,
          targetPortfolioValue: 1000000,
          targetMonthlyDividend: 5000,
        },
        assets: [{ assetName: 'Test Asset', initialInvestmentAmount: 1000 } as any],
      },
      { percentiles: {} } as any
    );
  };

  afterEach(() => {
    jest.clearAllMocks();
  });

  describe('getPortfolios', () => {
    it('사용자의 활성화된 포트폴리오 목록을 반환한다', async () => {
      const mockList = [
        createMockPortfolio('1', userId, 'P1'),
        createMockPortfolio('2', userId, 'P2'),
      ];
      (findPortfoliosByUserIdRepo as jest.Mock).mockResolvedValue(mockList);

      const result = await getPortfolios(userId);

      expect(result).toHaveLength(2);
      expect(findPortfoliosByUserIdRepo).toHaveBeenCalledWith(userId);
    });
  });

  describe('getPortfolioDetail', () => {
    it('정상적으로 본인의 포트폴리오를 조회한다', async () => {
      const mockPortfolio = createMockPortfolio(portfolioId, userId, 'My Portfolio');
      (findPortfolioByIdRepo as jest.Mock).mockResolvedValue(mockPortfolio);

      const result = await getPortfolioDetail(userId, portfolioId);

      expect(result.name).toBe('My Portfolio');
      expect(result.userId).toBe(userId);
    });

    it('포트폴리오가 존재하지 않거나 삭제된 경우 NOT_FOUND 에러를 던진다', async () => {
      (findPortfolioByIdRepo as jest.Mock).mockResolvedValue(null);

      await expect(getPortfolioDetail(userId, portfolioId)).rejects.toThrow('NOT_FOUND');
    });

    it('타인의 포트폴리오에 접근하려 할 경우 FORBIDDEN 에러를 던진다', async () => {
      const otherUserPortfolio = createMockPortfolio(portfolioId, 'other-user', 'Secret');
      (findPortfolioByIdRepo as jest.Mock).mockResolvedValue(otherUserPortfolio);

      await expect(getPortfolioDetail(userId, portfolioId)).rejects.toThrow('FORBIDDEN');
    });
  });

  describe('createPortfolio', () => {
    const validDto = new CreatePortfolioRequestDto(
      'New Plan',
      { goal: { investmentPeriodMonths: 60 } } as any,
      { percentiles: {} } as any
    );

    it('정상적인 데이터로 생성 요청 시 ID를 반환한다', async () => {
      (createPortfolioRepo as jest.Mock).mockResolvedValue('new-id-789');

      const result = await createPortfolio(userId, validDto);

      expect(result).toBe('new-id-789');
      expect(createPortfolioRepo).toHaveBeenCalled();
    });

    it('이름이 공백일 경우 VALIDATION_ERROR를 던진다', async () => {
      const invalidDto = { ...validDto, name: '' };
      await expect(createPortfolio(userId, invalidDto as any)).rejects.toThrow(
        'VALIDATION_ERROR: 포트폴리오 이름'
      );
    });

    it('투자 기간이 0 이하일 경우 VALIDATION_ERROR를 던진다', async () => {
      const invalidDto = {
        ...validDto,
        simulationInput: { goal: { investmentPeriodMonths: 0 } },
      };
      await expect(createPortfolio(userId, invalidDto as any)).rejects.toThrow(
        '투자 기간은 1개월 이상'
      );
    });
  });

  describe('updatePortfolio', () => {
    it('정상적으로 이름을 수정한다', async () => {
      const mockPortfolio = createMockPortfolio(portfolioId, userId, 'Old Name');
      const dto = new UpdatePortfolioRequestDto('New Name');

      (findPortfolioByIdRepo as jest.Mock).mockResolvedValue(mockPortfolio);
      (updatePortfolioRepo as jest.Mock).mockResolvedValue(true);

      const result = await updatePortfolio(userId, portfolioId, dto);

      expect(result).toBe(true);
      expect(updatePortfolioRepo).toHaveBeenCalledWith(
        portfolioId,
        expect.objectContaining({ name: 'New Name' })
      );
    });

    it('권한이 없는 포트폴리오 수정 시 NOT_FOUND(또는 권한없음) 에러를 던진다', async () => {
      const otherUserPortfolio = createMockPortfolio(portfolioId, 'other-user', 'Not Mine');
      (findPortfolioByIdRepo as jest.Mock).mockResolvedValue(otherUserPortfolio);

      await expect(updatePortfolio(userId, portfolioId, {} as any)).rejects.toThrow('NOT_FOUND');
    });
  });

  describe('deletePortfolio', () => {
    it('본인의 포트폴리오를 삭제(Soft Delete)한다', async () => {
      const mockPortfolio = createMockPortfolio(portfolioId, userId, 'To Delete');
      (findPortfolioByIdRepo as jest.Mock).mockResolvedValue(mockPortfolio);
      (deletePortfolioRepo as jest.Mock).mockResolvedValue(true);

      const result = await deletePortfolio(userId, portfolioId);

      expect(result).toBe(true);
      expect(deletePortfolioRepo).toHaveBeenCalledWith(portfolioId);
    });

    it('타인의 포트폴리오 삭제 시 FORBIDDEN 에러를 던진다', async () => {
      const otherUserPortfolio = createMockPortfolio(portfolioId, 'other-user', 'Not Mine');
      (findPortfolioByIdRepo as jest.Mock).mockResolvedValue(otherUserPortfolio);

      await expect(deletePortfolio(userId, portfolioId)).rejects.toThrow('FORBIDDEN');
    });
  });
});
