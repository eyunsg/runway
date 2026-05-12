export class CommentDto {
  commentId: string;
  content: string;
  authorDisplayName: string;
  createdAt: string;

  constructor(commentId: string, content: string, authorDisplayName: string, createdAt: string) {
    this.commentId = commentId;
    this.content = content;
    this.authorDisplayName = authorDisplayName;
    this.createdAt = createdAt;
  }
}

export class GetCommentsResponseDto {
  comments: CommentDto[];

  constructor(comments: CommentDto[]) {
    this.comments = comments;
  }
}
