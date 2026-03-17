/**
 * Runway 프로젝트: 프로필 컨트롤러
 * [제어 계층] HTTP 요청을 해석하여 서비스 레이어로 전달합니다.
 */

import { SupabaseClient, User } from 'supabase';
import * as Service from './profileService.ts';

/**
 * GET 요청 처리: 프로필 조회
 */
export const getProfile = async (supabaseClient: SupabaseClient, user: User, requestId: string) => {
  return await Service.fetchProfile(supabaseClient, user, requestId);
};
