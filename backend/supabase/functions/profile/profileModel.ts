/**
 * Runway 프로젝트: 프로필 도메인 모델 (Model)
 * [매핑 규칙 v1.x] @shared의 UserProfile 모델을 기반으로 확장합니다.
 */

import { UserProfile } from '../../../../packages/shared/models/user-profile.ts';

/**
 * @shared의 UserProfile(id, email, displayName)을 상속받아,
 * 화면(SCR-S-02)에 필요한 활동 통계(Stats) 정보를 추가한 확장 모델입니다.
 */
export interface Profile extends UserProfile {
  portfolioCount: number; // 포트폴리오 개수 (활동 통계)
  postCount: number; // 게시물 개수 (활동 통계)
  createdAt: Date; // 문자열이 아닌 진짜 'Date' 객체로 관리
}
