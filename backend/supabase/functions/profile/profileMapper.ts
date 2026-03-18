/**
 * Runway 프로젝트: 프로필 매퍼
 * [320 연동 완료] @shared/dto/profile/get-profile-response-dto.ts 활용
 */

import { ProfileEntity } from './profileEntity.ts';
import { createGetProfileResponse } from '@shared/dto/profile/getProfileResponseDto.ts';

export const ProfileMapper = {
  /**
   * Entity와 Auth Email을 결합하여 [email, displayName] 딱 2가지만 반환합니다.
   */
  toResponseDto(entity: ProfileEntity, email: string) {
    return createGetProfileResponse(email, entity.display_name || '이름 없음');
  },
};
