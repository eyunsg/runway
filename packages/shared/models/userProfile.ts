/*
 비즈니스 규칙 및 도메인 로직 담당
 사용자 프로필 도메인 모델
 */
export interface UserProfile {
  id: string;
  email: string;
  displayName: string;
}
