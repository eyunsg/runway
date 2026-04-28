export class PostPostsRequestDto {
  public portfolioId: string;
  public content: string;

  constructor(body: any) {
    // 1. 기본 구조 및 타입 검증
    this.validateSchema(body);

    // 2. 필드 매핑
    this.portfolioId = body.portfolioId;
    this.content = body.content;
  }

  private validateSchema(body: any): void {
    if (!body) {
      throw new Error('VALIDATION_ERROR: 요청 본문이 비어있습니다.');
    }

    // portfolioId 검증: 필수 및 문자열 타입 확인
    if (!body.portfolioId || typeof body.portfolioId !== 'string') {
      throw new Error(
        'VALIDATION_ERROR: 포트폴리오 ID(portfolioId)는 필수이며 문자열이어야 합니다.'
      );
    }

    // content 검증: 필수 및 문자열 타입 확인
    if (!body.content || typeof body.content !== 'string') {
      throw new Error('VALIDATION_ERROR: 게시물 내용(content)은 필수이며 문자열이어야 합니다.');
    }
  }
}
