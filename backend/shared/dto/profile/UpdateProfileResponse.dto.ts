/**
 * [DTO] 프로필 수정 응답 규격
 * 역할: 프로필 수정이 성공했을 때 클라이언트에 반환할 데이터 구조 정의
 */
export class UpdateProfileResponseDto {
  constructor(
    public email: string,
    public displayName: string
  ) {}
}
