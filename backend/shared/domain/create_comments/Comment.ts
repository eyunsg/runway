export class Comment {
  content: string;
  postId: string;
  userId: string;

  constructor(content: string, postId: string, userId: string) {
    this.content = content;
    this.postId = postId;
    this.userId = userId;
  }

  static create(content: string, postId: string, userId: string): Comment {
    if (!content || content.trim().length === 0) {
      throw new Error('VALIDATION_ERROR: 댓글 내용은 비어있을 수 없습니다.');
    }

    if (content.length > 1000) {
      throw new Error('VALIDATION_ERROR: 댓글은 1000자 이내로 작성해야 합니다.');
    }

    return new Comment(content, postId, userId);
  }

  toDbInsertRow() {
    return {
      content: this.content,
      post_id: this.postId,
      user_id: this.userId,
      created_at: new Date().toISOString(),
    };
  }
}
