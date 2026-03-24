import { GetProfileResponseDto } from '../../../shared/dto/profile/GetProfileResponse.dto.ts';
import { UpdateProfileRequestDto } from '../../../shared/dto/profile/UpdateProfileRequest.dto.ts';
import { UpdateProfileResponseDto } from '../../../shared/dto/profile/UpdateProfileResponse.dto.ts';
import {
  findUserById,
  updateProfileRepo,
  deleteProfileRepo,
  deleteAuthRepo,
} from './profileRepository.ts';

export async function getProfile(userId: string): Promise<GetProfileResponseDto> {
  const user = await findUserById(userId);

  if (!user) {
    throw new Error('User not found');
  }

  return new GetProfileResponseDto(user.email, user.displayName);
}

export async function updateProfile(
  userId: string,
  dto: UpdateProfileRequestDto
): Promise<UpdateProfileResponseDto> {
  // 1. 비즈니스 검증: 닉네임은 2자 이상 20자 이하 (ERD상 display_name)
  if (dto.displayName && (dto.displayName.length < 2 || dto.displayName.length > 20)) {
    throw new Error('VALIDATION_ERROR: 닉네임은 2자 이상 20자 이하로 입력해주세요.');
  }

  // 2. Repository 호출 (DB 필드명 display_name에 맞게 매핑하여 업데이트)
  const updatedUser = await updateProfileRepo(userId, {
    display_name: dto.displayName,
  });

  if (!updatedUser) {
    throw new Error('UPDATE_FAILED');
  }

  // 3. 수정된 결과를 UpdateResponse DTO로 변환하여 반환
  return new UpdateProfileResponseDto(updatedUser.displayName);
}

export async function deleteProfile(userId: string) {
  const profileDeleted = await deleteProfileRepo(userId);
  if (!profileDeleted) return false;

  const authDeleted = await deleteAuthRepo(userId);
  if (!authDeleted) return false;

  return true;
}
