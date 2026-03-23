import { GetProfileResponseDto } from '../../../shared/dto/profile/GetProfileResponse.dto.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';
import { findUserById, deleteProfileRepo, deleteAuthRepo } from './profileRepository.ts';

export async function getProfile(userId: string): Promise<GetProfileResponseDto> {
  const user = await findUserById(userId);

  if (!user) {
    throw new Error('User not found');
  }

  return new GetProfileResponseDto(user.email, user.displayName);
}

export async function deleteProfile(userId: string) {
  const adminClient = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
  );

  const profileDeleted = await deleteProfileRepo(adminClient, userId);
  if (!profileDeleted) return false;

  const authDeleted = await deleteAuthRepo(adminClient, userId);
  if (!authDeleted) return false;

  return true;
}
