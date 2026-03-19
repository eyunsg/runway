// backend/api/user/userService.ts

import { GetProfileResponseDto } from '../../shared/dto/user/getProfileResponse.dto';
import { User } from '../../shared/domain/user/user';
import { findUserById } from '../../supabase/functions/user/userRepository';

export async function getProfile(userId: string): Promise<GetProfileResponseDto> {
  const user: User | null = await findUserById(userId);
  if (!user) throw new Error('User not found');
  return new GetProfileResponseDto(user.email, user.displayName);
}
