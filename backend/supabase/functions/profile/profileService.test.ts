/**
 * Runway 프로젝트: 프로필 서비스 단위 테스트
 * [조회 전용] 통계 정보(stats) 제거에 따라 모킹 로직을 단순화하였습니다.
 */
// deno-lint-ignore no-import-prefix
import { assertEquals, assertRejects } from 'https://deno.land/std@0.168.0/testing/asserts.ts';
import { SupabaseClient, User } from 'supabase';
import { fetchProfile } from './profileService.ts';
import { AppError } from './profileConstants.ts';

/**
 * 1. 가짜 Supabase 클라이언트 모킹 함수
 * 이제 통계 조회를 하지 않으므로 profiles 테이블 조회 로직만 남깁니다.
 */
const createMockSupabaseClient = (
  mockProfile: unknown,
  error?: { code: string; message: string }
) => {
  const mockObject = {
    from: (_table: string) => ({
      select: (_query?: string) => ({
        eq: (_column: string, _value: string) => ({
          is: (_column: string, _value: unknown) => ({
            // Repository.findById에서 사용하는 .single() 메서드 모킹
            single: () =>
              Promise.resolve({
                data: mockProfile,
                error: error || null,
              }),
          }),
        }),
      }),
    }),
  };

  return mockObject as unknown as SupabaseClient;
};

/**
 * [시나리오 1] 정상적인 프로필 조회 테스트
 */
Deno.test('Profile Service - 성공적으로 프로필을 조회하고 응답 객체를 반환해야 함', async () => {
  // 준비 (Given)
  const mockUser = { id: 'user-123', email: 'test@example.com' } as User;
  const mockEntity = {
    id: 'user-123',
    display_name: '테스트유저',
    created_at: new Date().toISOString(),
  };

  // 통계 정보(mockStats)가 필요 없으므로 인자에서 제외합니다.
  const client = createMockSupabaseClient(mockEntity);

  // 실행 (When)
  const result = await fetchProfile(client, mockUser, 'test-request-id');

  // 검증 (Then)
  assertEquals(result.data?.displayName, '테스트유저');
  assertEquals(result.data?.email, 'test@example.com');
  assertEquals(result.error, null);

  // 통계 필드가 결과에 없는지도 확인하면 더 좋습니다 (팀장님 지시사항 검증)
  const resultKeys = Object.keys(result.data || {});
  assertEquals(
    resultKeys.includes('portfolioCount'),
    false,
    '결과에 포트폴리오 개수가 포함되면 안 됩니다.'
  );
  assertEquals(resultKeys.includes('postCount'), false, '결과에 게시글 개수가 포함되면 안 됩니다.');
});

/**
 * [시나리오 2] 프로필이 없는 경우(404) 에러 처리 테스트
 */
Deno.test('Profile Service - 프로필이 없을 때 404 AppError를 던져야 함', async () => {
  // 준비 (Given)
  const client = createMockSupabaseClient(null, { code: 'PGRST116', message: 'Not found' });
  const mockUser = { id: 'wrong-user' } as User;

  // 실행 및 검증 (When & Then)
  await assertRejects(
    async () => {
      await fetchProfile(client, mockUser, 'test-request-id');
    },
    AppError,
    '존재하지 않는 사용자 프로필입니다.'
  );
});
