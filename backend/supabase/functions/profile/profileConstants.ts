/**
 * Runway 프로젝트: 프로필 도메인 상수
 */

import { ERROR_MESSAGES } from '@shared/constants/userConstant.ts';

// 외부 레이어에서 편하게 쓰도록 다시 내보내기 (Re-export)
export { ERROR_MESSAGES };

// CORS 설정 (모바일 앱이 서버에 접속할 수 있게 허용하는 '통행증')
export const CORS_HEADERS = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'GET, OPTIONS',
};

/**
 * [에러 응답 명세서 4.1] 전역 예외 처리를 위한 커스텀 에러 상자
 * 비유: "문제가 생기면 이 상자에 에러 코드와 메시지를 담아 던진다"
 */
export class AppError extends Error {
  constructor(
    public status: number, // HTTP 상태 코드 (401, 404 등)
    message: string, // 사용자에게 보여줄 메시지
    public internalCode?: string // 시스템 내부 확인용 코드 (예: 'AUTH_INVALID')
  ) {
    super(message);
    this.name = 'AppError';
  }
}
