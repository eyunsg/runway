/**
 * 프로필 조회 응답 DTO
 * DTO 내부에는 비즈니스 규칙(검증 로직 등)을 포함하지 않음
 */
export interface GetProfileResponseDto {
  email: string;
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
 * Mapper: DB 또는 서비스 데이터를 DTO 규격으로 변환
 * 로직 분리를 위해 단순 객체 생성 역할만 수행
 */
export const createGetProfileResponse = (
  email: string,
  displayName: string
): ApiResponse<GetProfileResponseDto> => {
  return {
    data: {
      email,
      displayName,
    },
    error: null,
  };
};
