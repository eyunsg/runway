/*
 비즈니스 규칙 및 도메인 로직 담당
 */
import {
  DISPLAY_NAME_MIN_LENGTH,
  DISPLAY_NAME_MAX_LENGTH,
  ERROR_MESSAGES,
} from '../constants/user_constant.ts';

/*
 사용자 프로필 도메인 모델
 */
export interface UserProfile {
  id: string;
  email: string;
  displayName: string;
  updatedAt?: string;
}

/*
 비즈니스 규칙: 닉네임 유효성 검증
 constants/user.constant.ts의 정의된 값을 참조하여 검증 수행
 */
export const validateProfileDisplayName = (name: string): string | null => {
  const trimmedName = name?.trim() || '';

  if (
    trimmedName.length < DISPLAY_NAME_MIN_LENGTH ||
    trimmedName.length > DISPLAY_NAME_MAX_LENGTH
  ) {
    return ERROR_MESSAGES.DISPLAY_NAME_LENGTH;
  }

  return null;
};

/*
 이메일 형식 검증 (도메인 모델 레벨)
 */
export const validateEmailFormat = (email: string): string | null => {
  const emailRegex = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;

  if (!email || !emailRegex.test(email)) {
    return ERROR_MESSAGES.INVALID_EMAIL;
  }

  return null;
};
