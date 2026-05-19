import { UpdateProfileRequestDto } from '../../../shared/dto/profile/UpdateProfileRequest.dto.ts';
import {
  findUserById,
  updateProfileRepo,
  deleteProfileRepo,
  deleteAuthRepo,
} from './profileRepository.ts';
import { Profile } from '../../../shared/domain/profile/Profile.ts';

export async function getProfile(authHeader: string, userId: string): Promise<Profile> {
  const user = await findUserById(authHeader, userId);

  if (!user) {
    throw new Error('User not found');
  }

  // 순수 엔티티 객체를 반환
  return user;
}

export async function updateProfile(
  authHeader: string,
  userId: string,
  dto: UpdateProfileRequestDto
) {
  if (dto.displayName && (dto.displayName.length < 2 || dto.displayName.length > 20)) {
    throw new Error('VALIDATION_ERROR: 닉네임은 2자 이상 20자 이하로 입력해주세요.');
  }

  const profileUpdated = await updateProfileRepo(authHeader, userId, {
    display_name: dto.displayName,
  });
  if (!profileUpdated) return false;

  return true;
}

export async function deleteProfile(authHeader: string, userId: string) {
  const profileDeleted = await deleteProfileRepo(authHeader, userId);
  if (!profileDeleted) return false;

  const authDeleted = await deleteAuthRepo(userId);
  if (!authDeleted) return false;

  return true;
}
