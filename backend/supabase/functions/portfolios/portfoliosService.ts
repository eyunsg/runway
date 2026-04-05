import {
  CreatePortfolioRequestDto,
  UpdatePortfolioRequestDto,
} from '../domain/portfolios/portfolios.request.dto.ts';
import {
  createPortfolioRepo,
  findPortfolioByIdRepo,
  findPortfoliosByUserIdRepo,
  updatePortfolioRepo,
  deletePortfolioRepo,
} from '../repositories/portfolioRepository.ts';
import { Portfolio } from '../domain/portfolios/portfolios.ts';

export async function getPortfolios(userId: string): Promise<Portfolio[]> {
  const portfolios = await findPortfoliosByUserIdRepo(userId);
  // Soft Delete된 항목을 제외하고 반환 (리포지토리에서 처리되지 않았을 경우를 대비)
  return portfolios.filter((p) => p.isActive());
}

export async function getPortfolioDetail(userId: string, portfolioId: string): Promise<Portfolio> {
  const portfolio = await findPortfolioByIdRepo(portfolioId);

  if (!portfolio || !portfolio.isActive()) {
    throw new Error('NOT_FOUND: Portfolio not found');
  }

  // 소유권 확인
  if (portfolio.userId !== userId) {
    throw new Error('FORBIDDEN: You do not have permission to access this portfolio');
  }

  return portfolio;
}

export async function createPortfolio(
  userId: string,
  dto: CreatePortfolioRequestDto
): Promise<string> {
  // 1. 유효성 검사 (비즈니스 규칙)
  if (!dto.name || dto.name.length < 1 || dto.name.length > 100) {
    throw new Error('VALIDATION_ERROR: 포트폴리오 이름은 1자 이상 100자 이하로 입력해주세요.');
  }

  if (dto.simulationInput.goal.investmentPeriodMonths <= 0) {
    throw new Error('VALIDATION_ERROR: 투자 기간은 1개월 이상이어야 합니다.');
  }

  if (!dto.simulationInput.assets || dto.simulationInput.assets.length === 0) {
    throw new Error('VALIDATION_ERROR: 최소 하나 이상의 자산이 필요합니다.');
  }

  // 2. 리포지토리를 통한 저장
  const portfolioId = await createPortfolioRepo(userId, {
    name: dto.name,
    simulation_input: dto.simulationInput,
    simulation_result: dto.simulationResult,
  });

  return portfolioId;
}

export async function updatePortfolio(
  userId: string,
  portfolioId: string,
  dto: UpdatePortfolioRequestDto
) {
  // 1. 존재 여부 및 권한 확인
  const portfolio = await findPortfolioByIdRepo(portfolioId);
  if (!portfolio || !portfolio.isActive() || portfolio.userId !== userId) {
    throw new Error('NOT_FOUND: 수정할 포트폴리오를 찾을 수 없거나 권한이 없습니다.');
  }

  // 2. 유효성 검사
  if (dto.name && (dto.name.length < 1 || dto.name.length > 100)) {
    throw new Error('VALIDATION_ERROR: 포트폴리오 이름은 1자 이상 100자 이하로 입력해주세요.');
  }

  // 3. 리포지토리 업데이트 호출
  const isUpdated = await updatePortfolioRepo(portfolioId, {
    name: dto.name,
    simulation_input: dto.simulationInput,
    simulation_result: dto.simulationResult,
  });

  return isUpdated;
}

export async function deletePortfolio(userId: string, portfolioId: string) {
  // 1. 권한 확인
  const portfolio = await findPortfolioByIdRepo(portfolioId);
  if (!portfolio || portfolio.userId !== userId) {
    throw new Error('FORBIDDEN: 삭제 권한이 없습니다.');
  }

  // 2. 리포지토리를 통해 deleted_at 마킹
  const isDeleted = await deletePortfolioRepo(portfolioId);
  return isDeleted;
}
