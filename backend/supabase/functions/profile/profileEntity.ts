/**
 * Runway 프로젝트: 프로필 엔티티 (Entity)
 * 데이터베이스 테이블 구조와 1:1 매핑
 */

export interface ProfileEntity {
  id: string; // uuid (PK)
  display_name: string; // varchar(50)
  created_at: string; // 타임스탬프
  updated_at: string; // 타임스탬프
  deleted_at: string | null; // Soft Delete (지워졌는지 여부)
}

/**
 * [SCR-S-02] 통계 정보를 계산하기 위해 참조할 다른 테이블들
 */
export interface PortfolioEntity {
  id: string;
  user_id: string;
  deleted_at: string | null;
}

export interface PostEntity {
  id: string;
  user_id: string;
  deleted_at: string | null;
}
