/**
 * Runway 프로젝트: 프로필 서비스 단위 테스트
 * [에러 해결] resolver-error 및 lint 에러를 방지하기 위해 직접 URL 참조 및 무시 설정 적용
 */

// deno-lint-ignore no-import-prefix
import { assertEquals, assertRejects } from 'https://deno.land/std@0.168.0/testing/asserts.ts';
import { fetchProfile } from './profile-service.ts';
import { AppError } from './profile-constants.ts';

/**
 * 1. 가짜 Supabase 클라이언트 (Mock)
 * any 대신 unknown과 구체적인 인터페이스를 사용하여 린트 에러를 해결합니다.
 */
interface MockResult {
  single: () => Promise<{ data: unknown; error: unknown }>;
  count?: number;
  error?: unknown;
}

const mockSupabaseClient = (
  mockProfile: unknown,
  mockStats: Record<string, number>,
  error?: unknown
) => ({
  from: (table: string) => ({
    select: () => ({
      eq: () => ({
        is: () => {
          const result = Promise.resolve({
            count: mockStats[table],
            error: null,
          }) as unknown as MockResult;

          result.single = () =>
            Promise.resolve({
              data: mockProfile,
              error: error || null,
            });

          return result;
        },
      }),
    }),
  }),
});

/**
 * [시나리오 1] 정상적인 프로필 조회 테스트
 */
Deno.test('Profile Service - 성공적으로 프로필을 조회하고 DTO를 반환해야 함', async () => {
  // 준비 (Given)
  const mockUser = { id: 'user-123', email: 'test@example.com' };
  const mockEntity = {
    id: 'user-123',
    display_name: '테스트유저',
    created_at: new Date().toISOString(),
  };
  const mockStats = { portfolios: 3, posts: 5 };

  const client = mockSupabaseClient(mockEntity, mockStats);

  // 실행 (When)
  const result = await fetchProfile(client, mockUser, 'test-request-id');

  // 검증 (Then)
  assertEquals(result.data?.displayName, '테스트유저');
  assertEquals(result.data?.email, 'test@example.com');
  assertEquals(result.error, null);
});

/**
 * [시나리오 2] 프로필이 없는 경우(404) 에러 처리 테스트
 */
Deno.test('Profile Service - 프로필이 없을 때 404 AppError를 던져야 함', async () => {
  // 준비 (Given)
  const client = mockSupabaseClient(null, {}, { code: 'PGRST116', message: 'Not found' });
  const mockUser = { id: 'wrong-user' };

  // 실행 및 검증 (When & Then)
  await assertRejects(
    async () => {
      await fetchProfile(client, mockUser, 'test-request-id');
    },
    AppError,
    '존재하지 않는 사용자 프로필입니다.'
  );
});
