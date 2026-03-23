import { getProfile, deleteProfile } from '../supabase/functions/profile/profileService.ts';
import { findUserById } from '../supabase/functions/profile/profileRepository.ts';
import { Profile } from '../shared/domain/profile/Profile.ts';
import {
  deleteProfileRepo,
  deleteAuthRepo,
} from '../supabase/functions/profile/profileRepository.ts';

jest.mock('../supabase/functions/profile/profileRepository', () => ({
  findUserById: jest.fn(),
}));

jest.mock('../supabase/functions/profile/profileRepository', () => ({
  findUserById: jest.fn(),
  deleteProfileRepo: jest.fn(),
  deleteAuthRepo: jest.fn(),
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

describe('deleteProfile', () => {
  afterEach(() => {
    jest.clearAllMocks();
  });

  it('profile, auth 모두 삭제 성공하면 true 반환', async () => {
    (deleteProfileRepo as jest.Mock).mockResolvedValue(true);
    (deleteAuthRepo as jest.Mock).mockResolvedValue(true);

    const result = await deleteProfile('1');

    expect(result).toBe(true);
    expect(deleteProfileRepo).toHaveBeenCalledWith('1');
    expect(deleteAuthRepo).toHaveBeenCalledWith('1');
  });

  it('profile 삭제 실패 시 false 반환 (auth 호출 안함)', async () => {
    (deleteProfileRepo as jest.Mock).mockResolvedValue(false);

    const result = await deleteProfile('1');

    expect(result).toBe(false);
    expect(deleteProfileRepo).toHaveBeenCalledWith('1');
    expect(deleteAuthRepo).not.toHaveBeenCalled();
  });

  it('profile 성공, auth 실패 시 false 반환', async () => {
    (deleteProfileRepo as jest.Mock).mockResolvedValue(true);
    (deleteAuthRepo as jest.Mock).mockResolvedValue(false);

    const result = await deleteProfile('1');

    expect(result).toBe(false);
    expect(deleteProfileRepo).toHaveBeenCalledWith('1');
    expect(deleteAuthRepo).toHaveBeenCalledWith('1');
  });
});
