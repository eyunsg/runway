import { createCommentService } from './createCommentService.ts';
import { CreateCommentRequestDto } from '../../../shared/dto/create_comments/CreateCommentRequestDto.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
};

export class ValidationError extends Error {}

export async function handleCreateComment(req: Request, postId: string) {
  if (!postId || postId.trim().length === 0) {
    throw new ValidationError('VALIDATION_ERROR: postId가 필요합니다.');
  }

  const authHeader = req.headers.get('authorization') ?? '';

  // 유저 ID 추출용
  const supabase = createClient(Deno.env.get('SUPABASE_URL')!, Deno.env.get('SUPABASE_ANON_KEY')!);
  const {
    data: { user },
    error: userError,
  } = await supabase.auth.getUser(authHeader.replace('Bearer ', ''));

  if (userError || !user) {
    throw new Error('NOT_FOUND: 인증된 유저 정보를 찾을 수 없습니다.');
  }

  const body: CreateCommentRequestDto = await req.json();

  // 서비스 호출
  await createCommentService(authHeader, postId, user.id, body.content);

  return new Response(null, {
    status: 201,
    headers: {
      ...corsHeaders,
      'Content-Type': 'application/json',
    },
  });
}
