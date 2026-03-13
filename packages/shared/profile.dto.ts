/**
 * [DTO/모델 매핑 규칙 v1.0] 및 [API 명세 v4.2] 준수
 * 위치: packages/shared/profile.dto.ts
 */

/**
 * API-USER-001: 프로필 조회 응답 DTO
 * 규칙: {Resource}ResponseDto 형식 사용
 */
export interface ProfileResponseDto {
  /**
   * 사용자 이메일
   * 출처: Supabase Auth (auth.users)
   */
  email: string;

  /**
   * 앱 내 표시 이름
   * 출처: public.profiles.display_name
   * 규칙: camelCase 사용
   */
  displayName: string;
}

/**
 * [Response Structure Policy v1.0] 공통 응답 포맷
 */
export interface ApiResponse<T> {
  data: T | null;
  error: {
    message: string;
  } | null;
}

/**
 * 도메인 모델 검증 로직 (비즈니스 규칙 검증)
 * 규칙: 닉네임 2~20자 제한 (사용자 계층 특징 반영)
 */
export const validateProfileDisplayName = (name: string): string | null => {
  if (!name || name.trim().length < 2 || name.trim().length > 20) {
    return '닉네임은 2자 이상 20자 이하로 입력해주세요.';
  }
  return null;
};

/**
 * 이메일 형식 검증 (RFC 5322 기준)
 */
export const validateEmailFormat = (email: string): string | null => {
  const emailRegex = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
  if (!email || !emailRegex.test(email)) {
    return '유효하지 않은 이메일 형식입니다.';
  }
  return null;
};

/**
 * [전문가 제언] Mapper: DB 데이터를 DTO로 변환하는 함수
 * API 구현(RUNWAY-319) 시 코드 중복을 줄이고 일관성을 유지합니다.
 */
export const createProfileResponse = (
  email: string,
  displayName: string
): ApiResponse<ProfileResponseDto> => {
  return {
    data: {
      email,
      displayName,
    },
    error: null,
  };
};
