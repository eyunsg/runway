import { Portfolio } from '../../../shared/domain/portfolios/Portfolios.ts';
import { AddPortfolioRequestDto } from '../../../shared/dto/portfolios/PostPortfoliosRequest.dto.ts';
import { savePortfolioRepo } from './portfoliosRepository.ts';

export async function addPortfolioService(
  userId: string,
  dto: AddPortfolioRequestDto
): Promise<string> {
  // 1. DTO 데이터를 도메인 모델로 변환
  // 이 과정에서 Portfolio 클래스 내부의 validate()가 호출되어 이름, 자산 개수 등 검증
  const portfolio = new Portfolio(userId, dto.name, dto.simulationInput, dto.simulationResult);

  // 2. 도메인 객체를 리포지토리에 전달하여 저장 위임
  const portfolioId = await savePortfolioRepo(portfolio);

  // 3. 저장 실패 시 예외 발생 (Entry Point에서 500 에러로 처리됨)
  if (!portfolioId) {
    throw new Error('DATABASE_ERROR: 포트폴리오 저장 실패');
  }

  return portfolioId;
}
