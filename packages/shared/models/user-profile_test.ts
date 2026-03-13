/**
 * [Supabase 테스트 가이드 - 4. Folder-based Testing] 준수
 * 경로: packages/shared/models/user_profile.test.ts
 * 테스트 파일 위치: 구현체(models/user_profile.ts)와 동일 레벨
 */

import { assertEquals } from '@std/assert';
import { validateProfileDisplayName, validateEmailFormat } from './user-profile.ts';
/* [가이드 v1.1] 상수 파일에서 에러 메시지 정의를 가져옵니다. */
import { ERROR_MESSAGES } from '../constants/user-constant.ts';

Deno.test('Business Rule: 닉네임 유효성 검증 테스트 (상수 기반)', () => {
  /* 성공 케이스 */
  assertEquals(validateProfileDisplayName('홍길'), null);

  /* 실패 케이스 (상수에 정의된 메시지와 일치하는지 검증) */
  assertEquals(validateProfileDisplayName('홍'), ERROR_MESSAGES.DISPLAY_NAME_LENGTH);

  assertEquals(
    validateProfileDisplayName('일이삼사오육칠팔구십일이삼사오육칠팔구십일'),
    ERROR_MESSAGES.DISPLAY_NAME_LENGTH
  );
});

Deno.test('Business Rule: 이메일 형식 검증 테스트', () => {
  /* 성공 케이스 */
  assertEquals(validateEmailFormat('user@runway.dev'), null);

  /* 실패 케이스 (상수에 정의된 메시지와 일치하는지 검증) */
  assertEquals(validateEmailFormat('invalid-email'), ERROR_MESSAGES.INVALID_EMAIL);
});
