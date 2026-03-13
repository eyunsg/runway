/**
 * [폴더 구조 v1.1 - 5.4 constants] 준수
 * 서비스 전반에서 사용하는 정적 값 정의
 */

export const DISPLAY_NAME_MIN_LENGTH = 2;
export const DISPLAY_NAME_MAX_LENGTH = 20;

export const ERROR_MESSAGES = {
  DISPLAY_NAME_LENGTH: `닉네임은 ${DISPLAY_NAME_MIN_LENGTH}자 이상 ${DISPLAY_NAME_MAX_LENGTH}자 이하로 입력해주세요.`,
  INVALID_EMAIL: '유효하지 않은 이메일 형식입니다.',
};
