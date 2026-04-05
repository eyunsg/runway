import { GoalAnalysisSimulationService } from './goalAnalysisSimulationService.ts';
import { GoalAnalysisSimulationRequestDto } from '../../../shared/dto/simulations/GoalAnalysisSimulationRequest.dto.ts';
import { GoalAnalysisSimulationResponseDto } from '../../../shared/dto/simulations/GoalAnalysisSimulationResponse.dto.ts';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
};

export async function handleGoalAnalysis(req: Request) {
  // 1. 요청 바디 파싱 (에러 처리는 index.ts 중앙 핸들러에서 수행)
  const body = await req.json();
  const requestData = body.data || body;

  // 2. 요청 DTO 생성 및 검증
  // 생성자 내부에서 VALIDATION_ERROR를 던지도록 설계되었습니다.
  const requestDto = new GoalAnalysisSimulationRequestDto(requestData);

  // 3. 서비스 레이어 호출
  // 선택하신 Canvas의 analyzeGoalAchievement 메서드를 호출합니다.
  const service = new GoalAnalysisSimulationService();
  const result = service.analyzeGoalAchievement(requestDto.assets, requestDto.goal);

  // 4. 응답 DTO 생성
  // 서비스 결과(number | null)를 응답 DTO에 직접 전달합니다.
  const responseDto = new GoalAnalysisSimulationResponseDto(
    result.reachedPortfolioAmountMonth,
    result.reachedMonthlyDividendAmountMonth
  );

  // 5. 성공 응답 반환 (표준 포맷 { data, error } 준수)
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
