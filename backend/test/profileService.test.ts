import {
  getProfile,
  updateProfile,
  deleteProfile,
} from '../supabase/functions/profile/profileService.ts';
import { findUserById } from '../supabase/functions/profile/profileRepository.ts';
import { Profile } from '../shared/domain/profile/Profile.ts';
import {
  updateProfileRepo,
  deleteProfileRepo,
  deleteAuthRepo,
} from '../supabase/functions/profile/profileRepository.ts';
import { UpdateProfileRequestDto } from '../shared/dto/profile/UpdateProfileRequest.dto.ts';

jest.mock('../supabase/functions/profile/profileRepository', () => ({
  findUserById: jest.fn(),
  updateProfileRepo: jest.fn(),
  deleteProfileRepo: jest.fn(),
  deleteAuthRepo: jest.fn(),
}));

describe('ProfileService - 프로필 관리 테스트', () => {
  const mockAuthHeader = 'Bearer mock-user-jwt-token';
  const mockUserId = 'user-123';

  // 각 it 테스트가 끝날 때마다 호출 기록 초기화
  afterEach(() => {
    jest.clearAllMocks();
  });

  describe('getProfile', () => {
    it('정상적으로 유저를 조회하면 DTO를 반환한다', async () => {
      const mockUser = new Profile('test@example.com', 'testName');

      (findUserById as jest.Mock).mockResolvedValue(mockUser);

      const result = await getProfile(mockAuthHeader, mockUserId);

      expect(result.email).toBe('test@example.com');
      expect(result.displayName).toBe('testName');
      expect(findUserById).toHaveBeenCalledWith(mockAuthHeader, mockUserId);
    });

    it('유저가 없으면 에러를 던진다', async () => {
      (findUserById as jest.Mock).mockResolvedValue(null);

      await expect(getProfile(mockAuthHeader, mockUserId)).rejects.toThrow('User not found');

      expect(findUserById).toHaveBeenCalledWith(mockAuthHeader, mockUserId);
    });
  });

  describe('updateProfile', () => {
    it('정상적으로 닉네임을 수정하면 true를 반환한다', async () => {
      const newNickname = '새로운닉네임';
      const dto = new UpdateProfileRequestDto(newNickname);

      (updateProfileRepo as jest.Mock).mockResolvedValue(true);

      const result = await updateProfile(mockAuthHeader, mockUserId, dto);

      expect(result).toBe(true);
      expect(updateProfileRepo).toHaveBeenCalledWith(mockAuthHeader, mockUserId, {
        display_name: newNickname,
      });
    });

    it('repo에서 실패하면 false를 반환한다', async () => {
      const dto = new UpdateProfileRequestDto('정상닉네임');

      (updateProfileRepo as jest.Mock).mockResolvedValue(false);

      const result = await updateProfile(mockAuthHeader, mockUserId, dto);

      expect(result).toBe(false);
    });

    it('닉네임이 2자 미만일 경우 VALIDATION_ERROR를 던진다', async () => {
      const dto = new UpdateProfileRequestDto('A');

      await expect(updateProfile(mockAuthHeader, mockUserId, dto)).rejects.toThrow(
        'VALIDATION_ERROR: 닉네임은 2자 이상 20자 이하로 입력해주세요.'
      );

      expect(updateProfileRepo).not.toHaveBeenCalled();
    });

    it('닉네임이 20자를 초과할 경우 VALIDATION_ERROR를 던진다', async () => {
      const longNickname = '이것은이십자가넘는아주매우긴닉네임입니다확인용';
      const dto = new UpdateProfileRequestDto(longNickname);

      await expect(updateProfile(mockAuthHeader, mockUserId, dto)).rejects.toThrow(
        'VALIDATION_ERROR: 닉네임은 2자 이상 20자 이하로 입력해주세요.'
      );
    });
  });

  describe('deleteProfile', () => {
    afterEach(() => {
      jest.clearAllMocks();
    });

    it('profile, auth 모두 삭제 성공하면 true 반환', async () => {
      (deleteProfileRepo as jest.Mock).mockResolvedValue(true);
      (deleteAuthRepo as jest.Mock).mockResolvedValue(true);

      const result = await deleteProfile(mockAuthHeader, mockUserId);

      expect(result).toBe(true);
      expect(deleteProfileRepo).toHaveBeenCalledWith(mockAuthHeader, mockUserId);
      expect(deleteAuthRepo).toHaveBeenCalledWith(mockUserId);
    });

    it('profile 삭제 실패 시 false 반환 (auth 호출 안함)', async () => {
      (deleteProfileRepo as jest.Mock).mockResolvedValue(false);

      const result = await deleteProfile(mockAuthHeader, mockUserId);

      expect(result).toBe(false);
      expect(deleteProfileRepo).toHaveBeenCalledWith(mockAuthHeader, mockUserId);
      expect(deleteAuthRepo).not.toHaveBeenCalled();
    });

    it('profile 성공, auth 실패 시 false 반환', async () => {
      (deleteProfileRepo as jest.Mock).mockResolvedValue(true);
      (deleteAuthRepo as jest.Mock).mockResolvedValue(false);

      const result = await deleteProfile(mockAuthHeader, mockUserId);

      expect(result).toBe(false);
      expect(deleteProfileRepo).toHaveBeenCalledWith(mockAuthHeader, mockUserId);
      expect(deleteAuthRepo).toHaveBeenCalledWith(mockUserId);
    });
  });
});
