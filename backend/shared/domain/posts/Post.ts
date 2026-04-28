export class Post {
  constructor(
    public readonly userId: string,
    public readonly portfolioSnapshotId: string,
    public readonly content: string,
    public readonly id?: string
  ) {
    this.validate();
  }

  private validate() {
    // 내용 검증
    if (!this.content || this.content.trim().length === 0) {
      throw new Error('VALIDATION_ERROR: 게시물 내용은 필수이며 비어있을 수 없습니다.');
    }
    if (this.content.length > 5000) {
      throw new Error('VALIDATION_ERROR: 게시물 내용은 5000자 이내여야 합니다.');
    }

    // 스냅샷 참조 검증
    if (!this.portfolioSnapshotId || this.portfolioSnapshotId.trim().length === 0) {
      throw new Error('VALIDATION_ERROR: 유효한 포트폴리오 스냅샷 ID가 필요합니다.');
    }

    // 사용자 ID 검증
    if (!this.userId) {
      throw new Error('VALIDATION_ERROR: 사용자 ID 정보가 누락되었습니다.');
    }
  }
}
