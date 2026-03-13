/**
 * RUNWAY-320: Profile DTO 및 검증 로직 단위 테스트
 */

// deno.json에 정의된 JSR 표준 라이브러리 사용
import { assertEquals } from '@std/assert';
import {
  validateProfileDisplayName,
  validateEmailFormat,
  createProfileResponse,
} from './profile.dto.ts';

// 1. 닉네임(displayName) 검증 테스트
Deno.test('validateProfileDisplayName - 닉네임 유효성 검사', () => {
  // 성공 케이스: 2자 ~ 20자
  assertEquals(validateProfileDisplayName('홍길'), null);
  assertEquals(validateProfileDisplayName('안녕하세요반갑습니다히히'), null); // 12자
  assertEquals(validateProfileDisplayName('일이삼사오육칠팔구십일이삼사오육칠팔구십'), null); // 20자

  // 실패 케이스: 2자 미만
  assertEquals(validateProfileDisplayName('홍'), '닉네임은 2자 이상 20자 이하로 입력해주세요.');
  assertEquals(validateProfileDisplayName(' '), '닉네임은 2자 이상 20자 이하로 입력해주세요.');

  // 실패 케이스: 20자 초과
  assertEquals(
    validateProfileDisplayName('일이삼사오육칠팔구십일이삼사오육칠팔구십일'),
    '닉네임은 2자 이상 20자 이하로 입력해주세요.'
  );

  // 실패 케이스: null 또는 빈 값
  assertEquals(validateProfileDisplayName(''), '닉네임은 2자 이상 20자 이하로 입력해주세요.');
});

// 2. 이메일 형식 검증 테스트
Deno.test('validateEmailFormat - 이메일 형식 검사', () => {
  // 성공 케이스
  assertEquals(validateEmailFormat('test@example.com'), null);
  assertEquals(validateEmailFormat('user.name@domain.co.kr'), null);

  // 실패 케이스
  assertEquals(validateEmailFormat('invalid-email'), '유효하지 않은 이메일 형식입니다.');
  assertEquals(validateEmailFormat('@domain.com'), '유효하지 않은 이메일 형식입니다.');
  assertEquals(validateEmailFormat('test@'), '유효하지 않은 이메일 형식입니다.');
  assertEquals(validateEmailFormat(''), '유효하지 않은 이메일 형식입니다.');
});

// 3. Mapper(createProfileResponse) 테스트
Deno.test('createProfileResponse - 응답 객체 생성 및 규격 확인', () => {
  const email = 'test@runway.com';
  const name = '테스터';
  const response = createProfileResponse(email, name);

  assertEquals(response.data?.email, email);
  assertEquals(response.data?.displayName, name);
  assertEquals(response.error, null);
});
