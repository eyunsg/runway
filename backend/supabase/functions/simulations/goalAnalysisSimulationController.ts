import { GoalAnalysisSimulationService } from './goalAnalysisSimulationService.ts';
import { GoalAnalysisSimulationRequestDto } from '../../../shared/dto/simulations/GoalAnalysisSimulationRequest.dto.ts';
import { GoalAnalysisSimulationResponseDto } from '../../../shared/dto/simulations/GoalAnalysisSimulationResponse.dto.ts';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
};

function formatGoalAnalysisResult(result: {
  reachedValueMonth: number | null;
  reachedDividendMonth: number | null;
}) {
  return {
    portfolioValueGoal: result.reachedValueMonth
      ? { expectedMonthsToTarget: result.reachedValueMonth }
      : null,
    monthlyDividendGoal: result.reachedDividendMonth
      ? { expectedMonthsToTarget: result.reachedDividendMonth }
      : null,
  };
}

export async function handleGoalAnalysis(req: Request) {
  const requestId = crypto.randomUUID();

  try {
    // CORS Preflight 처리
    if (req.method === 'OPTIONS') {
      return new Response(null, { status: 204, headers: corsHeaders });
    }

    const body = await req.json();
    const requestData = body.data || body;

    // 요청 DTO 생성 및 검증 (DTO 스타일 반영)
    // 생성자 내부에서 VALIDATION_ERROR를 던짐
    const requestDto = new GoalAnalysisSimulationRequestDto(requestData);

    // Core Execution 호출 (Service Layer)
    // analyzeGoalAchievement 호출
    const service = new GoalAnalysisSimulationService();
    const result = service.analyzeGoalAchievement(requestDto.assets, requestDto.goal);

    // JSON Format
    console.log(
      JSON.stringify({
        level: 'info',
        action: 'goal_analysis_simulation_success',
        requestId,
        message: 'Goal analysis simulation completed successfully',
      })
    );

    // 결과 가공 및 응답 DTO 매핑 (Helper 활용 )
    const formattedResult = formatGoalAnalysisResult(result);

    const responseBody = GoalAnalysisSimulationResponseDto.toSuccess(
      formattedResult.portfolioValueGoal,
      formattedResult.monthlyDividendGoal
    );

    // 성공 응답 반환
    return new Response(JSON.stringify(responseBody), {
      status: 200,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  } catch (err: unknown) {
    // 에러 처리
    const error = err instanceof Error ? err : new Error(String(err));
    const isValidation =
      error.message.includes('VALIDATION_ERROR') || error.message.includes('Invalid request');

    console.error(
      JSON.stringify({
        level: 'error',
        action: isValidation ? 'validation_failed' : 'internal_server_error',
        requestId,
        stack: error.stack,
        message: error.message,
      })
    );

    const errorResponse = GoalAnalysisSimulationResponseDto.toError(
      error.message.replace('Error: ', '')
    );

    return new Response(JSON.stringify(errorResponse), {
      status: isValidation ? 400 : 500,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  }
}
