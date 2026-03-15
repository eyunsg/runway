/**
 * Runway 프로젝트: 프로필 서비스
 * [비즈니스 로직 계층] 리포지토리와 매퍼를 조립하여 최종 데이터를 생성합니다.
 */

import * as Repository from './profile-repository.ts';
import { ProfileMapper } from './profile-mapper.ts';
import { AppError } from './profile-constants.ts';

/**
 * 프로필 상세 정보 조회 로직 (API-USER-001)
 */
export const fetchProfile = async (supabaseClient: any, user: any, requestId: string) => {
  try {
    // 1. DB에서 프로필 원본 데이터 가져오기 (Repository 사용)
    const entity = await Repository.findById(supabaseClient, user.id);

    // 2. 활동 통계(포트폴리오, 게시물 수) 가져오기
    const stats = await Repository.fetchStats(supabaseClient, user.id);

    // 3. DB 데이터를 서버 내부 표준 모델로 변환 (Mapper 사용)
    const model = ProfileMapper.toDomain(entity, stats, user.email);

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
  } catch (err: any) {
    // [에러 대응] 프로필이 없는 경우 (PGRST116: Single row not found)
    if (err.code === 'PGRST116') {
      throw new AppError(404, '존재하지 않는 사용자 프로필입니다.', 'PROFILE_NOT_FOUND');
    }
    throw err;
  }
};
