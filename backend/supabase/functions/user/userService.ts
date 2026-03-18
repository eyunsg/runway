import { findUserById } from './userRepository.ts';

export interface UserProfile {
  id: string;
  email: string;
  displayName: string;
}

export async function getProfile(userId: string): Promise<UserProfile> {
  const user = await findUserById(userId);

  if (!user) {
    throw new Error('사용자를 찾을 수 없습니다.');
  }

  return {
    id: user.id,
    email: user.email,
    displayName: user.display_name,
  };
}
