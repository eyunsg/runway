import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';
import {
  addPostService,
  getPostsService,
  getMyPostsService,
  getPostDetailService,
  updatePostService,
  deletePostService,
} from './postsService.ts';
import { PostPostsRequestDto } from '../../../shared/dto/posts/PostPostsRequest.dto.ts';
import { UpdatePostsRequestDto } from '../../../shared/dto/posts/UpdatePostsRequest.dto.ts';

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
  const postId = await addPostService(user.id, dto);

  // 4. 성공 응답 반환 (테스트/클라이언트에서 즉시 식별 가능하도록 postId 반환)
  return new Response(JSON.stringify({ data: { postId } }), {
    status: 201,
    headers: {
      ...corsHeaders,
      'Content-Type': 'application/json',
    },
  });
}

export async function handleGetPosts(req: Request) {
  // 1. RLS 정책 적용을 위해 Authorization 헤더 추출
  const authHeader = req.headers.get('authorization') ?? '';

  // 2. 서비스 레이어 호출 (인증 헤더 전달)
  const responseDto = await getPostsService(authHeader);

  // 3. 성공 응답 반환 (명세에 따라 data 객체로 래핑)
  return new Response(JSON.stringify({ data: responseDto }), {
    status: 200,
    headers: {
      ...corsHeaders,
      'Content-Type': 'application/json',
    },
  });
}

export async function handleGetPostDetail(req: Request, postId: string) {
  // 1. RLS 정책 적용을 위해 Authorization 헤더 추출
  const authHeader = req.headers.get('authorization') ?? '';

  // 2. 서비스 레이어 호출 (postId 전달)
  const responseDto = await getPostDetailService(authHeader, postId);

  // 3. 성공 응답 반환 (명세에 따라 data 객체로 래핑)
  return new Response(JSON.stringify({ data: responseDto }), {
    status: 200,
    headers: {
      ...corsHeaders,
      'Content-Type': 'application/json',
    },
  });
}

export async function handlePatchPost(req: Request, postId: string) {
  const authHeader = req.headers.get('authorization') ?? '';

  // 1. 요청 데이터 파싱 및 DTO 매핑 (유효성 검증 포함)
  const body = await req.json();
  const dto = new UpdatePostsRequestDto(body);

  // 2. 서비스 레이어 호출 (비즈니스 로직 및 RLS 기반 수정 수행)
  await updatePostService(authHeader, postId, dto);

  // 3. 성공 응답 반환 (명세에 따라 204 No Content)
  return new Response(null, {
    status: 204,
    headers: corsHeaders,
  });
}

export async function handleDeletePost(req: Request, postId: string) {
  try {
    const authHeader = req.headers.get('authorization') ?? '';

    await deletePostService(authHeader, postId);

    return new Response(null, {
      status: 204,
      headers: corsHeaders,
    });
  } catch (error) {
    if (error instanceof Error) {
      if (error.message === 'FORBIDDEN') {
        return new Response(
          JSON.stringify({
            code: 'FORBIDDEN',
            message: '게시글 삭제 권한이 없습니다.',
          }),
          {
            status: 403,
            headers: {
              ...corsHeaders,
              'Content-Type': 'application/json',
            },
          }
        );
      }
    }

    return new Response(
      JSON.stringify({
        code: 'INTERNAL_SERVER_ERROR',
        message: '서버 오류',
      }),
      {
        status: 500,
        headers: {
          ...corsHeaders,
          'Content-Type': 'application/json',
        },
      }
    );
  }
}

export async function handleGetMyPosts(req: Request) {
  const authHeader = req.headers.get('authorization') ?? '';

  // 1. 사용자 인증 확인 (RLS 정책 적용을 위한 Auth Client 활용)
  const supabase = createClient(Deno.env.get('SUPABASE_URL')!, Deno.env.get('SUPABASE_ANON_KEY')!, {
    global: {
      headers: { Authorization: authHeader },
    },
  });

  const {
    data: { user },
    error: authError,
  } = await supabase.auth.getUser();

  if (authError || !user) {
    throw new UnauthorizedError('인증에 실패했습니다. 내 정보를 불러오려면 로그인이 필요합니다.');
  }

  // 2. 서비스 레이어 호출 (인증 헤더와 유저 ID 전달)
  const responseDto = await getMyPostsService(authHeader, user.id);

  // 3. 성공 응답 반환
  return new Response(JSON.stringify({ data: responseDto }), {
    status: 200,
    headers: {
      ...corsHeaders,
      'Content-Type': 'application/json',
    },
  });
}
