/**
 * [Confluence - Supabase 테스트 가이드] 준수
 * 경로: packages/shared/dto/get_profile_response_dto.test.ts
 * 분리된 모델 로직과 DTO 구조를 통합 검증
 */

import { assertEquals } from '@std/assert';
import { createGetProfileResponse } from './get_profile_response_dto.ts';
import { validateProfileDisplayName, validateEmailFormat } from '../models/user_profile.ts';

// 1. 모델 비즈니스 규칙 테스트 (models/user_profile.ts)
Deno.test('Domain Model: validateProfileDisplayName 검증', () => {
  assertEquals(validateProfileDisplayName('홍길'), null);
  assertEquals(validateProfileDisplayName('홍'), '닉네임은 2자 이상 20자 이하로 입력해주세요.');
  assertEquals(
    validateProfileDisplayName('일이삼사오육칠팔구십일이삼사오육칠팔구십일'),
    '닉네임은 2자 이상 20자 이하로 입력해주세요.'
  );
});

Deno.test('Domain Model: validateEmailFormat 검증', () => {
  assertEquals(validateEmailFormat('test@runway.com'), null);
  assertEquals(validateEmailFormat('invalid-email'), '유효하지 않은 이메일 형식입니다.');
});

// 2. DTO Mapper 테스트 (dto/get_profile_response_dto.ts)
Deno.test('DTO Mapper: createGetProfileResponse 생성 확인', () => {
  const email = 'user@example.com';
  const name = '테스터';
  const response = createGetProfileResponse(email, name);

  assertEquals(response.data?.email, email);
  assertEquals(response.data?.displayName, name);
  assertEquals(response.error, null);
});
