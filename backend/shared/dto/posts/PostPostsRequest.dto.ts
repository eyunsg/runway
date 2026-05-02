export class PostPostsRequestDto {
  public portfolioId?: string;
  public content: string;

  constructor(body: any) {
    this.validateSchema(body);

    this.portfolioId = body.portfolioId;
    this.content = body.content;
  }

  private validateSchema(body: any): void {
    if (!body) {
      throw new Error('VALIDATION_ERROR: 요청 본문이 비어있습니다.');
    }

    // content 검증
    if (!body.content || typeof body.content !== 'string') {
      throw new Error('VALIDATION_ERROR: 게시물 내용(content)은 필수이며 문자열이어야 합니다.');
    }

    // portfolioId는 optional이지만 존재하면 타입 검증
    if (body.portfolioId !== undefined && typeof body.portfolioId !== 'string') {
      throw new Error('VALIDATION_ERROR: portfolioId는 문자열이어야 합니다.');
    }
  }
}
