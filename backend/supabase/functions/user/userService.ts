import { GetProfileResponseDto } from './dto/getProfileResponse.dto.ts';
import { findUserById } from './userRepository.ts';
import { User } from './domain/user.ts';

export async function getProfile(userId: string): Promise<GetProfileResponseDto> {
  const user: User | null = await findUserById(userId);
  if (!user) throw new Error('User not found');
  return new GetProfileResponseDto(user.email, user.displayName);
}
