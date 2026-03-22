import { getProfile } from '../supabase/functions/profile/profileService.ts';
import { findUserById } from '../supabase/functions/profile/profileRepository.ts';
import { Profile } from '../shared/domain/profile/Profile.ts';

jest.mock('../supabase/functions/profile/profileRepository', () => ({
  findUserById: jest.fn(),
}));

describe('getProfile', () => {
  afterEach(() => {
    jest.clearAllMocks();
  });

  it('정상적으로 유저를 조회하면 DTO를 반환한다', async () => {
    const mockUser = new Profile('test@example.com', 'testName');

    (findUserById as jest.Mock).mockResolvedValue(mockUser);

    const result = await getProfile('1');

    expect(result.email).toBe('test@example.com');
    expect(result.displayName).toBe('testName');
    expect(findUserById).toHaveBeenCalledWith('1');
  });

  it('유저가 없으면 에러를 던진다', async () => {
    (findUserById as jest.Mock).mockResolvedValue(null);

    await expect(getProfile('1')).rejects.toThrow('User not found');

    expect(findUserById).toHaveBeenCalledWith('1');
  });
});
