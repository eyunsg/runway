/**
 * Runway 프로젝트: 프로필 조회 응답 DTO 테스트
 * [조회 전용] 서버 응답 규격(DTO)이 클라이언트와 약속한 구조대로 생성되는지 검증합니다.
 */

import { assertEquals } from '@std/assert';
import { createGetProfileResponse } from './getProfileResponseDto.ts';

Deno.test('Data Contract: 프로필 조회 응답 규격 및 매핑 검증', () => {
  // 1. 테스트용 가공 데이터 준비
  const testEmail = 'user@runway.dev';
  const testName = '테스터';

  // 2. 응답 객체 생성 (매퍼 함수 실행)
  const response = createGetProfileResponse(testEmail, testName);

  /**
   * [검증 포인트 1] 공통 응답 포맷(ApiResponse) 준수 여부
   * 모든 API는 { data: ..., error: ... } 구조를 가져야 합니다.
   */
  assertEquals(response.error, null, '성공 응답 시 에러 객체는 null이어야 합니다.');

  /**
   * [검증 포인트 2] 데이터 정확성 (Data Mapping)
   * 입력한 값이 DTO의 정해진 필드에 정확히 들어갔는지 확인합니다.
   */
  assertEquals(response.data?.email, testEmail, '이메일이 정확하게 매핑되어야 합니다.');
  assertEquals(response.data?.displayName, testName, '닉네임이 정확하게 매핑되어야 합니다.');

  /**
   * [검증 포인트 3] 조회 전용 확인 (불필요한 데이터 부재)
   */
  const keys = Object.keys(response.data || {});
  assertEquals(keys.length, 2, '데이터 필드는 email과 displayName 딱 2개여야 합니다.');
});
