/**
 * [DTO] 프로필 수정 요청 객체
 *  역할: 클라이언트가 서버로 수정을 요청할 때 보내는 데이터 규격
 */
export class UpdateProfileRequestDto {
  constructor(public displayName?: string) {}
}
