import { assertEquals, assertThrows } from 'jsr:@std/assert@0.208.0';
import { Profile } from '../../../shared/domain/profile/Profile.ts';

/**
 * [RUNWAY-14] Profile API - Service 및 Domain Unit Test
 * - 실행 방법: deno test --allow-all backend/supabase/functions/profile/profileService.test.ts
 */

// 1. 도메인 모델(Profile)의 유효성 검사 테스트
Deno.test('Profile 도메인 - 닉네임 유효성 검증 (정상 케이스)', () => {
  const email = 'test@example.com';
  const validNickname = '정상닉네임';

  const profile = new Profile(email, validNickname);

  assertEquals(profile.email, email);
  assertEquals(profile.displayName, validNickname);
});

Deno.test('Profile 도메인 - 닉네임 유효성 검증 (실패: 2자 미만)', () => {
  const shortNickname = 'A'; // 1자

  assertThrows(
    () => {
      // Profile 생성자 내부에서 validate()가 실행되어 에러를 던져야 함
      new Profile('test@example.com', shortNickname);
    },
    Error,
    'VALIDATION_ERROR'
  );
});

Deno.test('Profile 도메인 - 닉네임 유효성 검증 (실패: 20자 초과)', () => {
  const longNickname = '이것은이십자가넘는아주매우긴닉네임입니다확인용'; // 23자

  assertThrows(
    () => {
      new Profile('test@example.com', longNickname);
    },
    Error,
    'VALIDATION_ERROR'
  );
});

// 2. 비즈니스 로직(닉네임 변경 가능 여부) 테스트
Deno.test('Profile 도메인 - 닉네임 변경 가능 여부 판단', () => {
  const profile = new Profile('test@example.com', '기존닉네임');

  // 동일한 이름으로 변경 시도 시 false
  assertEquals(profile.canUpdateNickname('기존닉네임'), false);

  // 유효한 새 이름으로 변경 시도 시 true
  assertEquals(profile.canUpdateNickname('새닉네임'), true);

  // 유효하지 않은 길이의 이름으로 변경 시도 시 false
  assertEquals(profile.canUpdateNickname('약'), false);
});
