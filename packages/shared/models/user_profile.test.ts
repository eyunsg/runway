/**
 * [Supabase 테스트 가이드 - 4. Folder-based Testing] 준수
 * 경로: packages/shared/models/user_profile.test.ts
 * 테스트 파일 위치: 구현체(models/user_profile.ts)와 동일 레벨
 */

import { assertEquals } from '@std/assert';
import { validateProfileDisplayName, validateEmailFormat } from './user_profile.ts';

Deno.test('Business Rule: 닉네임 유효성 검증 테스트', () => {
  assertEquals(validateProfileDisplayName('홍길'), null); // 성공
  assertEquals(validateProfileDisplayName('홍'), '닉네임은 2자 이상 20자 이하로 입력해주세요.'); // 실패(짧음)
  assertEquals(
    validateProfileDisplayName('일이삼사오육칠팔구십일이삼사오육칠팔구십일'),
    '닉네임은 2자 이상 20자 이하로 입력해주세요.'
  ); // 실패(긺)
});

Deno.test('Business Rule: 이메일 형식 검증 테스트', () => {
  assertEquals(validateEmailFormat('user@runway.dev'), null); // 성공
  assertEquals(validateEmailFormat('invalid-email'), '유효하지 않은 이메일 형식입니다.'); // 실패
});
