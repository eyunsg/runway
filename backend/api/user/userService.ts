import { GetProfileResponseDto } from '../../shared/dto/user/getProfileResponse.dto.ts';
import { User } from '../../shared/domain/user/user.ts';
import { findUserById } from '../../supabase/functions/user/userRepository.ts';

export async function getProfile(userId: string): Promise<GetProfileResponseDto> {
  const user: User | null = await findUserById(userId);
  if (!user) throw new Error('User not found');
  return new GetProfileResponseDto(user.email, user.displayName);
}
