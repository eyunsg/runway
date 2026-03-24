import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';
import { getProfile, updateProfile, deleteProfile } from './profileService.ts';
import { UpdateProfileRequestDto } from '../../../shared/dto/profile/UpdateProfileRequest.dto.ts';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'GET, PATCH, OPTIONS',
};

export async function handleGetProfile(req: Request) {
  try {
    if (req.method === 'OPTIONS') {
      return new Response(null, {
        status: 204,
        headers: corsHeaders,
      });
    }

    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_ANON_KEY')!,
      {
        global: {
          headers: {
            Authorization: req.headers.get('authorization') ?? '',
          },
        },
      }
    );

    const {
      data: { user },
      error,
    } = await supabase.auth.getUser();

    if (error || !user) {
      return new Response('Unauthorized', {
        status: 401,
        headers: corsHeaders,
      });
    }

    const responseDto = await getProfile(user.id);

    return new Response(JSON.stringify(responseDto), {
      status: 200,
      headers: {
        ...corsHeaders,
        'Content-Type': 'application/json',
      },
    });
  } catch (err) {
    return new Response(String(err), {
      status: 500,
      headers: corsHeaders,
    });
  }
}

export async function handleUpdateProfile(req: Request) {
  try {
    if (req.method === 'OPTIONS') {
      return new Response(null, { status: 204, headers: corsHeaders });
    }

    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_ANON_KEY')!,
      { global: { headers: { Authorization: req.headers.get('authorization') ?? '' } } }
    );

    const {
      data: { user },
      error,
    } = await supabase.auth.getUser();

    if (error || !user) {
      return new Response('Unauthorized', { status: 401, headers: corsHeaders });
    }

    // 1. 요청 바디 데이터 읽기
    const body = await req.json();
    const requestData = body.data || body; // 클라이언트 응답 규격 대응

    // 2. DTO 생성 (ERD에 따라 displayName만 처리)
    const dto = new UpdateProfileRequestDto(requestData.displayName);

    // 3. 서비스 레이어 호출
    const responseDto = await updateProfile(user.id, dto);

    return new Response(JSON.stringify(responseDto), {
      status: 200,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  } catch (err) {
    const errorMsg = String(err);
    // 닉네임 검증 실패(VALIDATION_ERROR) 시 400 반환, 그 외 500
    const status = errorMsg.includes('VALIDATION_ERROR') ? 400 : 500;
    return new Response(errorMsg, { status: status, headers: corsHeaders });
  }
}

export async function handleDeleteProfile(req: Request) {
  try {
    if (req.method === 'OPTIONS') {
      return new Response(null, {
        status: 204,
        headers: corsHeaders,
      });
    }

    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_ANON_KEY')!,
      {
        global: {
          headers: {
            Authorization: req.headers.get('authorization') ?? '',
          },
        },
      }
    );

    const {
      data: { user },
      error,
    } = await supabase.auth.getUser();

    if (error || !user) {
      return new Response('Unauthorized', {
        status: 401,
        headers: corsHeaders,
      });
    }

    const result = await deleteProfile(user.id);

    if (!result) {
      return new Response('Delete failed', {
        status: 400,
        headers: corsHeaders,
      });
    }

    return new Response(null, {
      status: 204,
      headers: corsHeaders,
    });
  } catch (err) {
    return new Response(String(err), {
      status: 500,
      headers: corsHeaders,
    });
  }
}
