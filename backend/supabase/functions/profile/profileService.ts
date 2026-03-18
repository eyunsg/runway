/**
 * Runway 프로젝트: 프로필 서비스
 * [비즈니스 로직 계층] 리포지토리와 매퍼를 조립하여 최종 데이터를 생성합니다.
 */

import { SupabaseClient, User } from 'supabase';
import * as Repository from './profileRepository.ts';
import { ProfileMapper } from './profileMapper.ts';
import { AppError } from './profileConstants.ts';

/**
 * 프로필 상세 정보 조회 로직 (API-USER-001)
 */
export const fetchProfile = async (
  supabaseClient: SupabaseClient,
  user: User,
  requestId: string
) => {
  try {
    // 1. DB에서 프로필 원본 데이터 가져오기 (Repository 사용)
    const entity = await Repository.findById(supabaseClient, user.id);

    // 2. [변경사항] 도메인 모델 변환 단계(toDomain)를 생략하고 즉시 DTO로 변환합니다.
    // 매퍼가 엔티티와 이메일을 조합하여 { data, error } 규격의 응답을 생성합니다.
    const response = ProfileMapper.toResponseDto(entity, user.email ?? '');

    // 4. 구조화된 로그 기록 (성능 모니터링 및 추적용)
    console.log(
      JSON.stringify({
        level: 'INFO',
        action: 'fetch_profile_success',
        requestId,
        userId: user.id,
      })
    );

    // 5. 앱(Flutter)이 이해할 수 있는 DTO로 최종 변환하여 반환
    return response;
  } catch (err: unknown) {
    // [에러 대응] unknown 타입이므로 안전하게 속성 접근을 위한 타입 단언을 사용합니다.
    const error = err as { code?: string; message?: string };

    // PostgREST 에러 코드 확인 (PGRST116: Single row not found)
    if (error.code === 'PGRST116') {
      throw new AppError(404, '존재하지 않는 사용자 프로필입니다.', 'PROFILE_NOT_FOUND');
    }

    throw err;
  }
};
