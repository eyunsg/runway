/**
 * Runway 프로젝트: 프로필 API 메인 엔트리
 * [엔트리 포인트] 서버 시작, 인증 체크, 전역 에러 처리를 담당합니다.
 */

import { serve } from 'std/http/server';
import { createClient } from 'supabase';
import { CORS_HEADERS, AppError } from './profile-constants.ts';
import * as Controller from './profile-controller.ts';

/**
 * 전역 에러 응답 처리기
 * 모든 에러는 이곳에서 규격화된 JSON 응답으로 변환됩니다.
 */
const handleError = (err: any, requestId: string): Response => {
  const status = err instanceof AppError ? err.status : 500;
  const message = err instanceof AppError ? err.message : '서버 내부 오류가 발생했습니다.';

  // 상세 에러 로그 기록 (추적용)
  console.error(
    JSON.stringify({
      level: 'ERROR',
      requestId,
      code: err.internalCode || 'UNKNOWN',
      message: err.message,
      stack: err.stack,
    })
  );

  return new Response(JSON.stringify({ data: null, error: { message } }), {
    status,
    headers: { ...CORS_HEADERS, 'Content-Type': 'application/json' },
  });
};

// Deno 서버 시작
serve(async (req: Request) => {
  // 1. 요청 식별 아이디 생성 (모든 로그를 하나로 묶는 열쇠)
  const requestId = crypto.randomUUID();

  // 2. CORS 사전 요청(Preflight) 처리
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: CORS_HEADERS });
  }

  try {
    // 3. Supabase 클라이언트 초기화
    const authHeader = req.headers.get('Authorization');
    if (!authHeader) throw new AppError(401, '인증 토큰이 누락되었습니다.', 'AUTH_MISSING');

    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      { global: { headers: { Authorization: authHeader } } }
    );

    // 4. JWT를 통한 사용자 신원 확인 (로그인 여부 체크)
    const {
      data: { user },
      error: authError,
    } = await supabaseClient.auth.getUser();
    if (authError || !user) throw new AppError(401, '유효하지 않은 세션입니다.', 'AUTH_INVALID');

    // 5. HTTP 메서드에 따른 컨트롤러 분기
    let result;
    if (req.method === 'GET') {
      result = await Controller.getProfile(supabaseClient, user, requestId);
    } else if (req.method === 'PATCH') {
      result = await Controller.updateProfile();
    } else {
      throw new AppError(405, '허용되지 않는 요청 방식입니다.', 'METHOD_NOT_ALLOWED');
    }

    // 6. 성공 응답 반환
    // result는 이미 @shared 매퍼를 거쳐 { data, error } 구조를 가지고 있습니다.
    return new Response(JSON.stringify(result), {
      status: 200,
      headers: { ...CORS_HEADERS, 'Content-Type': 'application/json' },
    });
  } catch (err) {
    // 발생한 모든 에러를 포괄적으로 처리
    return handleError(err, requestId);
  }
});
