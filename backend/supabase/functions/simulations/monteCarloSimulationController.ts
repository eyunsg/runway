import { runMonteCarloSimulation } from './monteCarloSimulationService.ts';
import { RunMonteCarloSimulationRequestDto } from '../../../shared/dto/simulations/MonteCarloSimulationRequest.dto.ts';
import { MonteCarloSimulationResponseDto } from '../../../shared/dto/simulations/MonteCarloSimulationResponse.dto.ts';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
};

// 컨트롤러는 요청 수신 및 응답 반환 역할에만 집중합니다.
export async function handleSimulation(req: Request) {
  const requestBody = await req.json();
  const requestData = requestBody.data || requestBody;

  // 1. DTO 인스턴스 생성 (이 시점에 DTO 내부 검증 로직이 작동하여 유효하지 않으면 에러를 던짐)
  const requestDto = new RunMonteCarloSimulationRequestDto(requestData);

  // 2. 서비스 레이어 호출
  const simulationResult = runMonteCarloSimulation(requestDto);

  // 3. 결과 데이터를 응답 DTO에 매핑
  const responseDto = new MonteCarloSimulationResponseDto(
    simulationResult.portfolioAmount,
    simulationResult.monthlyDividendAmount
  );

  return new Response(
    JSON.stringify({
      data: responseDto,
      error: null,
    }),
    {
      status: 200,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    }
  );
}
