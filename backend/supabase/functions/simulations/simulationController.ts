import { SimulationService } from './simulationService.ts';
import { SimulationRequestDto } from '../../../shared/dto/simulations/SimulationRequest.dto.ts';
import { SimulationResponseDto } from '../../../shared/dto/simulations/SimulationResponse.dto.ts';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
};

export async function handleSimulation(req: Request) {
  // 1. 요청 바디 파싱
  let body: unknown;
  try {
    body = await req.json();
  } catch {
    throw new Error('VALIDATION_ERROR: 요청 본문이 유효한 JSON 형식이 아닙니다.');
  }

  // 2. 통합 요청 DTO 생성 및 검증
  const requestDto = new SimulationRequestDto(body);

  // 3. 통합 서비스 레이어 호출
  const service = new SimulationService();
  const simulationResults = service.runSimulation(requestDto);

  // 4. 응답 DTO 매핑
  const responseDto = SimulationResponseDto.fromResults(simulationResults.percentiles, {
    portfolioValueReachedMonths:
      simulationResults.goalAnalysis.portfolioValueGoal.expectedMonthsToTarget,
    monthlyDividendReachedMonths:
      simulationResults.goalAnalysis.monthlyDividendGoal.expectedMonthsToTarget,
  });
  // 5. 결과 반환
  return new Response(JSON.stringify(responseDto), {
    status: 200,
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  });
}
