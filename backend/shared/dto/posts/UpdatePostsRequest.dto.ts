export class UpdatePostsRequestDto {
  public content: string;

  constructor(body: any) {
    this.validateSchema(body);
    this.content = body.content;
  }

  private validateSchema(body: any): void {
    if (!body) {
      throw new Error('VALIDATION_ERROR: 요청 본문이 비어있습니다.');
    }

    if (!body.content || typeof body.content !== 'string') {
      throw new Error('VALIDATION_ERROR: 수정할 내용(content)은 필수이며 문자열이어야 합니다.');
    }

    if (body.content.trim().length === 0) {
      throw new Error('VALIDATION_ERROR: 내용은 비어있을 수 없습니다.');
    }

    if (body.content.length > 5000) {
      throw new Error('VALIDATION_ERROR: 내용은 5000자 이내여야 합니다.');
    }
  }
}
