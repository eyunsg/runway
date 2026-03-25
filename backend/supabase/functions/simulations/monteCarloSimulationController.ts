import { runMonteCarloSimulation } from './monteCarloSimulationService.ts';
import { RunMonteCarloSimulationRequestDto } from '../../../shared/dto/montecarlo/MonteCarloSimulationRequest.dto.ts';
import {
  MonteCarloSimulationResponseDto,
  PercentileResultDto,
} from '../../../shared/dto/montecarlo/MonteCarloSimulationResponse.dto.ts';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
};

interface FormattedSimulationData {
  percentiles: {
    portfolioValue: PercentileResultDto;
    monthlyDividend: PercentileResultDto;
  };
  goalAnalysis: null;
}

function checkValidityP10_P50_P90(p10: number, p50: number, p90: number): void {
  if (p10 > p50 || p50 > p90) {
    throw new Error('Statistical Validity Error: P10 <= P50 <= P90 violated.');
  }
}

function formatAPIResult(
  raw_p10: number,
  raw_p50: number,
  raw_p90: number
): FormattedSimulationData {
  return {
    percentiles: {
      portfolioValue: {
        p10: Math.floor(raw_p10),
        p50: Math.floor(raw_p50),
        p90: Math.floor(raw_p90),
      },
      monthlyDividend: { p10: 0, p50: 0, p90: 0 },
    },
    goalAnalysis: null,
  };
}

export async function handleSimulation(req: Request) {
  try {
    if (req.method === 'OPTIONS') {
      return new Response(null, { status: 204, headers: corsHeaders });
    }

    const body = await req.json();

    // 1. 요청 DTO 생성 및 검증 (DTO 내부 생성자에서 유효성 체크)
    const requestDto = new RunMonteCarloSimulationRequestDto(body.data);

    // 2. Core Execution 호출 (순수 float64 계산 데이터 수신)
    const result = await runMonteCarloSimulation(
      requestDto.investmentPeriodMonths,
      requestDto.assets
    );

    // 3. Analysis & Validation (P10 <= P50 <= P90 확인)
    checkValidityP10_P50_P90(
      result.portfolioValue.p10,
      result.portfolioValue.p50,
      result.portfolioValue.p90
    );

    // 4. 결과 가공 및 DTO 매핑
    const formattedData = formatAPIResult(
      result.portfolioValue.p10,
      result.portfolioValue.p50,
      result.portfolioValue.p90
    );

    const responseDto = new MonteCarloSimulationResponseDto(
      formattedData.percentiles.portfolioValue,
      formattedData.percentiles.monthlyDividend
    );

    // 5. 성공 응답 반환
    return new Response(JSON.stringify({ data: responseDto, error: null }), {
      status: 200,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  } catch (err) {
    // 6. 에러 응답 반환 (Global Error Policy 준수)
    return new Response(
      JSON.stringify({
        data: null,
        error: { message: String(err).replace('Error: ', '') },
      }),
      {
        status: 400,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      }
    );
  }
}
