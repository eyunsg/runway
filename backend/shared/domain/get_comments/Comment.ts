type SingleOrArray<T> = T | T[];

export interface CommentDbRow {
  comment_id: string;
  content: string;
  created_at: string;
  user_id: string;
  post_id?: string;
  deleted_at?: string | null;
  profiles: SingleOrArray<{ display_name: string | null }> | null;
}

export interface CommentResponseModel {
  commentId: string;
  content: string;
  authorDisplayName: string;
  createdAt: string;
}

export class Comment {
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

  static fromDbRow(row: CommentDbRow): Comment {
    const profile = Array.isArray(row.profiles) ? row.profiles[0] : row.profiles;

    return new Comment(
      row.comment_id,
      row.content,
      profile?.display_name || '알 수 없는 사용자',
      row.created_at
    );
  }

  static fromDbRows(rows: CommentDbRow[], postId?: string): Comment[] {
    return rows
      .filter((row) => row.deleted_at == null)
      .filter((row) => (postId ? row.post_id === postId : true))
      .sort((a, b) => a.created_at.localeCompare(b.created_at))
      .map((row) => Comment.fromDbRow(row));
  }

  toResponseModel(): CommentResponseModel {
    return {
      commentId: this.commentId,
      content: this.content,
      authorDisplayName: this.authorDisplayName,
      createdAt: this.createdAt,
    };
  }
}
