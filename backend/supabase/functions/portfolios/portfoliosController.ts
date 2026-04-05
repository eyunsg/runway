import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';
import * as portfolioService from '../services/portfolio.service.ts';
import {
  CreatePortfolioRequestDto,
  UpdatePortfolioRequestDto,
} from '../domain/portfolios/portfolios.request.dto.ts';
import {
  GetPortfolioResponseDto,
  PortfolioSummaryDto,
  PortfolioActionResponseDto,
} from '../domain/portfolios/portfolios.response.dto.ts';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'GET, POST, PATCH, DELETE, OPTIONS',
};

function createResponse(data: any, status = 200) {
  return new Response(JSON.stringify({ data, error: null }), {
    status,
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  });
}

function createErrorResponse(err: unknown) {
  const errorMsg = err instanceof Error ? err.message : String(err);
  let status = 500;

  if (errorMsg.includes('VALIDATION_ERROR')) status = 400;
  else if (errorMsg.includes('Unauthorized')) status = 401;
  else if (errorMsg.includes('FORBIDDEN')) status = 403;
  else if (errorMsg.includes('NOT_FOUND')) status = 404;

  return new Response(JSON.stringify({ data: null, error: { message: errorMsg } }), {
    status,
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  });
}

async function getAuthenticatedUser(req: Request) {
  const supabase = createClient(Deno.env.get('SUPABASE_URL')!, Deno.env.get('SUPABASE_ANON_KEY')!, {
    global: { headers: { Authorization: req.headers.get('authorization') ?? '' } },
  });

  const {
    data: { user },
    error,
  } = await supabase.auth.getUser();
  if (error || !user) throw new Error('Unauthorized');
  return user;
}

export async function handleCreatePortfolio(req: Request) {
  try {
    if (req.method === 'OPTIONS') return new Response(null, { status: 204, headers: corsHeaders });

    const user = await getAuthenticatedUser(req);
    const body = await req.json();
    const requestData = body.data || body;

    const dto = new CreatePortfolioRequestDto(
      requestData.name,
      requestData.simulationInput,
      requestData.simulationResult
    );

    const portfolioId = await portfolioService.createPortfolio(user.id, dto);

    return createResponse({ portfolioId }, 201);
  } catch (err) {
    return createErrorResponse(err);
  }
}

export async function handleGetPortfolios(req: Request) {
  try {
    if (req.method === 'OPTIONS') return new Response(null, { status: 204, headers: corsHeaders });

    const user = await getAuthenticatedUser(req);
    const portfolios = await portfolioService.getPortfolios(user.id);

    const responseData = {
      portfolios: portfolios.map(
        (p) => new PortfolioSummaryDto(p.id!, p.name, p.updatedAt.getTime())
      ),
    };

    return createResponse(responseData);
  } catch (err) {
    return createErrorResponse(err);
  }
}

export async function handleGetPortfolioDetail(req: Request) {
  try {
    if (req.method === 'OPTIONS') return new Response(null, { status: 204, headers: corsHeaders });

    const user = await getAuthenticatedUser(req);
    const url = new URL(req.url);
    const portfolioId = url.pathname.split('/').pop() || '';

    const portfolio = await portfolioService.getPortfolioDetail(user.id, portfolioId);

    const responseDto = new GetPortfolioResponseDto(
      portfolio.name,
      portfolio.simulationInput,
      portfolio.simulationResult
    );

    return createResponse(responseDto);
  } catch (err) {
    return createErrorResponse(err);
  }
}

export async function handleUpdatePortfolio(req: Request) {
  try {
    if (req.method === 'OPTIONS') return new Response(null, { status: 204, headers: corsHeaders });

    const user = await getAuthenticatedUser(req);
    const url = new URL(req.url);
    const portfolioId = url.pathname.split('/').pop() || '';

    const body = await req.json();
    const requestData = body.data || body;

    const dto = new UpdatePortfolioRequestDto(
      requestData.name,
      requestData.simulationInput,
      requestData.simulationResult
    );

    const success = await portfolioService.updatePortfolio(user.id, portfolioId, dto);

    if (!success) throw new Error('Update failed');

    return createResponse(new PortfolioActionResponseDto(portfolioId, Date.now()));
  } catch (err) {
    return createErrorResponse(err);
  }
}

export async function handleDeletePortfolio(req: Request) {
  try {
    if (req.method === 'OPTIONS') return new Response(null, { status: 204, headers: corsHeaders });

    const user = await getAuthenticatedUser(req);
    const url = new URL(req.url);
    const portfolioId = url.pathname.split('/').pop() || '';

    const success = await portfolioService.deletePortfolio(user.id, portfolioId);

    if (!success) throw new Error('Delete failed');

    return createResponse(new PortfolioActionResponseDto(portfolioId, Date.now()));
  } catch (err) {
    return createErrorResponse(err);
  }
}
