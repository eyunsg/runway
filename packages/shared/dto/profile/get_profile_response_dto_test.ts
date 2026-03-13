import { assertEquals } from '@std/assert';
import { createGetProfileResponse } from './get_profile_response_dto.ts';

/*
  DTO 및 매퍼(Mapper) 통합 검증
 */
Deno.test('Data Contract & Mapper: GetProfileResponseDto 매핑 및 구조 검증', () => {
  // 1. 테스트 데이터 준비 (DB나 서비스에서 온 데이터라고 가정)
  const inputEmail = 'user@runway.dev';
  const inputName = '테스터';

  // 2. 매퍼 함수 실행 (Mapping 수행)
  const response = createGetProfileResponse(inputEmail, inputName);

  // 3. 검증 (Assertion)
  // 매퍼가 ApiResponse 규격에 맞게 데이터를 포장했는지 확인
  assertEquals(response.error, null, '에러 객체는 null이어야 합니다.');

  // 입력값이 DTO의 올바른 필드에 매핑되었는지 확인
  assertEquals(response.data?.email, inputEmail, '이메일 매핑이 정확해야 합니다.');
  assertEquals(response.data?.displayName, inputName, '닉네임 매핑이 정확해야 합니다.');

  // 데이터 타입 검증
  assertEquals(typeof response.data?.email, 'string');
  assertEquals(typeof response.data?.displayName, 'string');
});
