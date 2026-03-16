/**
 * Runway 프로젝트: 프로필 서비스 단위 테스트
 * [에러 해결] resolver-error 및 lint 에러를 방지하기 위해 직접 URL 참조 및 무시 설정 적용
 */
// deno-lint-ignore no-import-prefix
import { assertEquals, assertRejects } from 'https://deno.land/std@0.168.0/testing/asserts.ts';
import { SupabaseClient, User } from 'supabase';
import { fetchProfile } from './profile-service.ts';
import { AppError } from './profile-constants.ts';

/**
 * 1. 가짜 Supabase 클라이언트 모킹 함수
 * 서비스 레이어에서 사용하는 실제 체이닝 메서드들을 흉내냅니다.
 */
const createMockSupabaseClient = (
  mockProfile: unknown,
  mockStats: Record<string, { count: number }>,
  error?: { code: string; message: string }
) => {
  const mockObject = {
    from: (table: string) => ({
      select: (_query?: string, _options?: object) => ({
        eq: (_column: string, _value: string) => ({
          is: (_column: string, _value: unknown) => {
            // 통계 조회(count)를 위한 반환값
            const statsResult = Promise.resolve({
              count: mockStats[table]?.count || 0,
              error: null,
            });

            /**
             * 단일 행 조회를 위한 .single() 메서드 확장을 위한 인터페이스 정의
             * any 대신 unknown과 구체적인 에러 객체 타입을 명시하여 타입 안전성을 확보합니다.
             */
            interface MockChainedResponse extends Promise<{ count: number; error: null }> {
              single: () => Promise<{
                data: unknown;
                error: { code: string; message: string } | null;
              }>;
            }

            // statsResult를 확장된 인터페이스 타입으로 캐스팅하여 single 메서드 추가 허용
            const chainedResult = statsResult as MockChainedResponse;

            chainedResult.single = () =>
              Promise.resolve({
                data: mockProfile,
                error: error || null,
              });

            return chainedResult;
          },
        }),
      }),
    }),
  };

  // 실제 SupabaseClient 타입으로 간주하도록 캐스팅하여 반환
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
  const mockStats = {
    portfolios: { count: 3 },
    posts: { count: 5 },
  };

  const client = createMockSupabaseClient(mockEntity, mockStats);

  // 실행 (When)
  const result = await fetchProfile(client, mockUser, 'test-request-id');

  // 검증 (Then)
  // 매퍼를 거쳐 CommonResponse 구조 { data, error }로 반환되는지 확인
  assertEquals(result.data?.displayName, '테스트유저');
  assertEquals(result.data?.email, 'test@example.com');
  assertEquals(result.error, null);
});

/**
 * [시나리오 2] 프로필이 없는 경우(404) 에러 처리 테스트
 */
Deno.test('Profile Service - 프로필이 없을 때 404 AppError를 던져야 함', async () => {
  // 준비 (Given)
  const client = createMockSupabaseClient(null, {}, { code: 'PGRST116', message: 'Not found' });
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
