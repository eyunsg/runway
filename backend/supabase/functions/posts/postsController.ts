import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';
import { addPostService } from './postsService.ts';
import { PostPostsRequestDto } from '../../../shared/dto/posts/PostPostsRequest.dto.ts';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'GET, POST, PATCH, DELETE, OPTIONS',
};

export class UnauthorizedError extends Error {}
export class ValidationError extends Error {}

export async function handleAddPost(req: Request) {
  // Supabase 클라이언트 초기화 (사용자 인증 토큰 포함)
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

  // 2. 요청 데이터 파싱 및 DTO 매핑 (No-Wrapping 규칙 적용)
  const body = await req.json();
  const dto = new PostPostsRequestDto(body);

  // 3. 서비스 레이어 호출 (비즈니스 로직 및 DB 저장 수행)
  await addPostService(user.id, dto);

  // 4. 성공 응답 반환
  return new Response(null, {
    status: 201,
    headers: corsHeaders,
  });
}
