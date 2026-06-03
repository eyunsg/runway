// 작성 가능한 코드
// 1. 상태
// 2. 검증
// 3. 비즈니스 로직

export class Profile {
  constructor(
    public email: string,
    public displayName: string
  ) {
    // 생성 시점에 기본적인 검증 로직을 넣을 수 있습니다.
    this.validate();
  }

  /**
   * 도메인 수준의 데이터 검증
   * - PATCH 요청 시 잘못된 데이터가 서비스 레이어로 진입하는 것을 방지합니다.
   */
  private validate() {
    if (this.displayName.length < 2 || this.displayName.length > 20) {
      // 비즈니스 규칙 위반 시 명시적인 에러를 발생시켜 프로세스를 중단합니다.
      throw new Error('VALIDATION_ERROR: Display name must be between 2 and 20 characters.');
    }
  }

  /**
   * 비즈니스 로직 예시: 닉네임 변경 가능 여부 확인
   * - 현재 값과 동일한지, 규칙에 부합하는지 등을 체크하여 불필요한 DB 접근을 줄입니다.
   */
  public canUpdateNickname(newNickname: string): boolean {
    return newNickname !== this.displayName && newNickname.length >= 2 && newNickname.length <= 20;
  }
}
