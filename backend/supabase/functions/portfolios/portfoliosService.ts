import { Portfolio } from '../../../shared/domain/portfolios/Portfolios.ts';
import { AddPortfolioRequestDto } from '../../../shared/dto/portfolios/PostPortfoliosRequest.dto.ts';
import { savePortfolioRepo, getPortfoliosRepo } from './portfoliosRepository.ts';
import {
  GetPortfoliosResponseDto,
  PortfolioSummaryDto,
} from '../../../shared/dto/portfolios/GetPortfoliosResponse.dto.ts';

interface RawPortfolioRecord {
  id: string;
  name: string;
  simulation_input: {
    goal?: {
      investment_period_months?: number;
    };
    assets?: unknown[]; // 자산의 개수만 필요하므로 unknown 배열로 정의
  };
  updated_at: string;
}

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

export async function getPortfoliosService(userId: string): Promise<GetPortfoliosResponseDto> {
  // 1. 리포지토리에서 해당 사용자의 데이터 조회 (배열 형태)
  const rawData = await getPortfoliosRepo(userId);

  if (!rawData) {
    throw new Error('DATABASE_ERROR: 포트폴리오 목록 조회 실패');
  }

  // 2. DB 로우 데이터를 PortfolioSummaryDto 형식으로 매핑
  const summaries = (rawData as RawPortfolioRecord[]).map((item: RawPortfolioRecord) => {
    // DB의 snake_case 구조에서 필요한 값을 추출
    const assets = item.simulation_input?.assets || [];
    const goal = item.simulation_input?.goal || {};

    const assetCount = assets.length;
    const investmentPeriodMonths = goal.investment_period_months || 0;

    return new PortfolioSummaryDto(
      item.id,
      item.name,
      assetCount,
      investmentPeriodMonths,
      item.updated_at
    );
  });

  // 3. 최종 DTO를 생성하여 반환
  return new GetPortfoliosResponseDto(summaries);
}
