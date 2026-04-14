import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';
import {
  addPortfolioService,
  getPortfoliosService,
  getPortfolioDetailService,
  updatePortfolioService,
  deletePortfolioService,
} from './portfoliosService.ts';
import { AddPortfolioRequestDto } from '../../../shared/dto/portfolios/PostPortfoliosRequest.dto.ts';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'GET, POST, PATCH, DELETE, OPTIONS',
};

export class UnauthorizedError extends Error {}
export class ValidationError extends Error {}

export async function handleAddPortfolio(req: Request) {
  // Supabase 클라이언트 초기화
  const supabase = createClient(Deno.env.get('SUPABASE_URL')!, Deno.env.get('SUPABASE_ANON_KEY')!, {
    global: {
      headers: { Authorization: req.headers.get('authorization') ?? '' },
    },
  });

  // 1. 사용자 인증 확인
  const {
    data: { user },
    error: authError,
  } = await supabase.auth.getUser();

  if (authError || !user) {
    throw new UnauthorizedError('인증에 실패했습니다. 다시 로그인해주세요.');
  }

  // 2. 요청 데이터 파싱
  const body = await req.json();
  const dto = new AddPortfolioRequestDto(body);

  // 3. 서비스 레이어 호출 (비즈니스 로직 및 DB 저장 수행)
  await addPortfolioService(user.id, dto);

  // 4. 성공 응답 반환
  return new Response(null, {
    status: 201,
    headers: corsHeaders,
  });
}

export async function handleGetPortfolios(req: Request) {
  // Supabase 클라이언트 초기화
  const supabase = createClient(Deno.env.get('SUPABASE_URL')!, Deno.env.get('SUPABASE_ANON_KEY')!, {
    global: {
      headers: { Authorization: req.headers.get('authorization') ?? '' },
    },
  });

  // 1. 사용자 인증 확인
  const {
    data: { user },
    error: authError,
  } = await supabase.auth.getUser();

  if (authError || !user) {
    throw new UnauthorizedError('인증에 실패했습니다. 다시 로그인해주세요.');
  }

  // 2. 서비스 레이어 호출 (목록 조회 비즈니스 로직 수행)
  const result = await getPortfoliosService(user.id);

  // 3. 성공 응답 반환 (200 OK)
  return new Response(JSON.stringify(result), {
    status: 200,
    headers: {
      ...corsHeaders,
      'Content-Type': 'application/json',
    },
  });
}

export async function handleGetPortfolioDetail(req: Request, portfolioId: string) {
  const supabase = createClient(Deno.env.get('SUPABASE_URL')!, Deno.env.get('SUPABASE_ANON_KEY')!, {
    global: {
      headers: { Authorization: req.headers.get('authorization') ?? '' },
    },
  });

  const {
    data: { user },
    error: authError,
  } = await supabase.auth.getUser();

  if (authError || !user) {
    throw new UnauthorizedError('인증에 실패했습니다. 다시 로그인해주세요.');
  }

  // 서비스 레이어 호출
  const result = await getPortfolioDetailService(user.id, portfolioId);

  // 결과 객체를 직접 반환
  return new Response(JSON.stringify(result), {
    status: 200,
    headers: {
      ...corsHeaders,
      'Content-Type': 'application/json',
    },
  });
}

export async function handleUpdatePortfolio(req: Request, portfolioId: string) {
  const supabase = createClient(Deno.env.get('SUPABASE_URL')!, Deno.env.get('SUPABASE_ANON_KEY')!, {
    global: {
      headers: { Authorization: req.headers.get('authorization') ?? '' },
    },
  });

  // 1. 사용자 인증 확인
  const {
    data: { user },
    error: authError,
  } = await supabase.auth.getUser();

  if (authError || !user) {
    throw new UnauthorizedError('인증에 실패했습니다. 다시 로그인해주세요.');
  }

  // 2. 요청 데이터 파싱
  const body = await req.json();
  // 생성과 데이터 스펙이 동일하므로 기존 DTO 재사용
  const dto = new AddPortfolioRequestDto(body);

  // 3. 서비스 레이어 호출 (비즈니스 로직 수행)
  await updatePortfolioService(user.id, portfolioId, dto);

  // 4. 성공 응답 반환 (204 No Content)
  return new Response(null, {
    status: 204,
    headers: corsHeaders,
  });
}

export async function handleDeletePortfolio(req: Request, portfolioId: string) {
  const supabase = createClient(Deno.env.get('SUPABASE_URL')!, Deno.env.get('SUPABASE_ANON_KEY')!, {
    global: {
      headers: { Authorization: req.headers.get('authorization') ?? '' },
    },
  });

  // 1. 사용자 인증 확인
  const {
    data: { user },
    error: authError,
  } = await supabase.auth.getUser();

  if (authError || !user) {
    throw new UnauthorizedError('인증에 실패했습니다. 다시 로그인해주세요.');
  }

  // 2. 서비스 레이어 호출 (삭제 비즈니스 로직 수행)
  await deletePortfolioService(user.id, portfolioId);

  // 3. 성공 응답 반환 (API 명세서 준수: 204 No Content)
  return new Response(null, {
    status: 204,
    headers: corsHeaders,
  });
}
