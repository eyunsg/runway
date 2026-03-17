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

    // 2. 활동 통계(포트폴리오, 게시물 수) 가져오기
    const stats = await Repository.fetchStats(supabaseClient, user.id);

    // 3. DB 데이터를 서버 내부 표준 모델로 변환 (Mapper 사용)
    // user.email이 undefined일 수 있으므로 기본값 처리를 포함합니다.
    const model = ProfileMapper.toDomain(entity, stats, user.email ?? '');

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
    return ProfileMapper.toResponseDto(model);
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
