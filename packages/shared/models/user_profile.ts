/**
 * 사용자 프로필 관련 비즈니스 규칙 검증
 * 닉네임 2~20자 제한
 */
export const validateProfileDisplayName = (name: string): string | null => {
  const trimmedName = name?.trim() || '';
  if (trimmedName.length < 2 || trimmedName.length > 20) {
    return '닉네임은 2자 이상 20자 이하로 입력해주세요.';
  }
  return null;
};

/**
 * 이메일 형식 검증 (도메인 모델 레벨)
 */
export const validateEmailFormat = (email: string): string | null => {
  const emailRegex = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
  if (!email || !emailRegex.test(email)) {
    return '유효하지 않은 이메일 형식입니다.';
  }
  return null;
};

/**
 * 사용자 프로필 도메인 모델
 */
export interface UserProfile {
  id: string;
  email: string;
  displayName: string;
  updatedAt?: string;
}
