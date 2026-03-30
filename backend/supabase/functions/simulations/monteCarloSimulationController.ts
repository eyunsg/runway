import { runMonteCarloSimulation } from './monteCarloSimulationService.ts';
import { RunMonteCarloSimulationRequestDto } from '../../../shared/dto/simulations/MonteCarloSimulationRequest.dto.ts';
import {
  MonteCarloSimulationResponseDto,
  PercentileResultDto,
} from '../../../shared/dto/simulations/MonteCarloSimulationResponse.dto.ts';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
};

function validateStatisticalConsistency(
  metricLabel: string,
  percentileResult: PercentileResultDto
): void {
  if (percentileResult.p10 > percentileResult.p50 || percentileResult.p50 > percentileResult.p90) {
    throw new Error(
      `Statistical Validity Error [${metricLabel}]: p10 <= p50 <= p90 조건을 위반했습니다.`
    );
  }
}

export async function handleSimulation(req: Request) {
  try {
    if (req.method === 'OPTIONS') {
      return new Response(null, { status: 204, headers: corsHeaders });
    }

    const requestBody = await req.json();
    const requestDto = new RunMonteCarloSimulationRequestDto(requestBody.data);

    const simulationResult = runMonteCarloSimulation(
      requestDto.investmentPeriodMonths,
      requestDto.assets
    );

    validateStatisticalConsistency('Portfolio Value', simulationResult.portfolioValue);
    validateStatisticalConsistency('Monthly Dividend', simulationResult.monthlyDividend);

    const simulationResponseDto = new MonteCarloSimulationResponseDto(
      simulationResult.portfolioValue,
      simulationResult.monthlyDividend
    );

    return new Response(
      JSON.stringify({
        data: {
          ...simulationResponseDto,
        },
        error: null,
      }),
      {
        status: 200,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      }
    );
  } catch (err) {
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
