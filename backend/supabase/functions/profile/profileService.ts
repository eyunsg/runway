import { GetProfileResponseDto } from '../../../shared/dto/profile/GetProfileResponse.dto.ts';
import { findUserById, deleteProfileRepo, deleteAuthRepo } from './profileRepository.ts';

export async function getProfile(userId: string): Promise<GetProfileResponseDto> {
  const user = await findUserById(userId);

  if (!user) {
    throw new Error('User not found');
  }

  return new GetProfileResponseDto(user.email, user.displayName);
}

export async function deleteProfile(userId: string) {
  const profileDeleted = await deleteProfileRepo(userId);
  if (!profileDeleted) return false;

  const authDeleted = await deleteAuthRepo(userId);
  if (!authDeleted) return false;

  return true;
}
