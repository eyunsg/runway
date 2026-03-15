/**
 * Runway 프로젝트: 프로필 리포지토리
 */

import { ProfileEntity } from './profile-entity.ts';

/**
 * ID로 사용자 프로필 정보 조회
 * [Soft Delete] deleted_at이 null인 활성 데이터만 조회 (명세 준수)
 */
export const findById = async (supabaseClient: any, userId: string): Promise<ProfileEntity> => {
  const { data, error } = await supabaseClient
    .from('profiles')
    .select('*')
    .eq('id', userId)
    .is('deleted_at', null)
    .single();

  if (error) throw error;
  return data;
};

/**
 * [SCR-S-02] 활동 통계 조회
 */
export const fetchStats = async (supabaseClient: any, userId: string) => {
  const [portfolios, posts] = await Promise.all([
    supabaseClient
      .from('portfolios')
      .select('*', { count: 'exact', head: true })
      .eq('user_id', userId)
      .is('deleted_at', null),
    supabaseClient
      .from('posts')
      .select('*', { count: 'exact', head: true })
      .eq('user_id', userId)
      .is('deleted_at', null),
  ]);

  return {
    portfolioCount: portfolios.count || 0,
    postCount: posts.count || 0,
  };
};
