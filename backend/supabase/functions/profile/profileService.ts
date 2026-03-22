import { GetProfileResponseDto } from '../../../shared/dto/profile/getProfileResponse.dto.ts';
import { findUserById } from './profileRepository.ts';

export async function getProfile(userId: string): Promise<GetProfileResponseDto> {
  const user = await findUserById(userId);

  if (!user) {
    throw new Error('User not found');
  }

  return new GetProfileResponseDto(user.email, user.displayName);
}
