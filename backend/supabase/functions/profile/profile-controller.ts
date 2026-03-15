/**
 * Runway 프로젝트: 프로필 컨트롤러
 * [제어 계층] HTTP 요청을 해석하여 서비스 레이어로 전달합니다.
 */

import * as Service from './profile-service.ts';
import { AppError } from './profile-constants.ts';

/**
 * GET 요청 처리: 프로필 조회
 */
export const getProfile = async (supabaseClient: any, user: any, requestId: string) => {
  return await Service.fetchProfile(supabaseClient, user, requestId);
};

/**
 * PATCH 요청 처리: 프로필 수정 (추후 구현 예정)
 * 320에서 만든 검증 로직이 여기서 사용될 예정입니다.
 */
export const updateProfile = async () => {
  throw new AppError(501, '프로필 수정 기능은 준비 중입니다.', 'NOT_IMPLEMENTED');
};
