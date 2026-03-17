/**
 * Runway 프로젝트: 프로필 매퍼
 * [320 연동 완료] @shared/dto/profile/get-profile-response-dto.ts 활용
 */

import { ProfileEntity } from './profileEntity.ts';
import { Profile } from './profileModel.ts';
import { createGetProfileResponse } from '../../../../packages/shared/dto/profile/getProfileResponseDto.ts';

export const ProfileMapper = {
  /**
   * DB Entity -> 도메인 모델 변환 (snake_case -> camelCase)
   */
  toDomain(entity: ProfileEntity, email: string): Profile {
    return {
      id: entity.id,
      email: email,
      displayName: entity.display_name,
      createdAt: new Date(entity.created_at),
    };
  },

  /**
   * 도메인 모델 -> 공용 DTO 변환
   * 320에서 만든 createGetProfileResponse를 호출하여 Response Structure Policy 준수
   */
  toResponseDto(model: Profile) {
    return createGetProfileResponse(model.email, model.displayName);
  },
};
