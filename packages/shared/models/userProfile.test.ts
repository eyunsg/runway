/**
 * [Supabase 테스트 가이드 - 4. Folder-based Testing] 준수
 * 경로: packages/shared/models/user_profile.test.ts
 * 테스트 파일 위치: 구현체(models/user_profile.ts)와 동일 레벨
 */
import { assertEquals } from '@std/assert';
import { UserProfile } from './userProfile.ts';

Deno.test('Model Structure: UserProfile 인터페이스 구조 확인', () => {
  // 실제 로직이 없으므로, 데이터 구조가 설계대로 생성되는지 간단히 확인합니다.
  const mockProfile: UserProfile = {
    id: 'test-uuid',
    email: 'user@runway.dev',
    displayName: '홍길동',
  };

  assertEquals(mockProfile.id, 'test-uuid');
  assertEquals(mockProfile.email, 'user@runway.dev');
  assertEquals(mockProfile.displayName, '홍길동');
});
