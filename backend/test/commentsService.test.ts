import { getCommentsService } from '../supabase/functions/get-comments/getCommentsService.ts';
import { findCommentsByPostIdRepo } from '../supabase/functions/get-comments/getCommentRepository.ts';
import { GetCommentsResponseDto } from '../shared/dto/get_comments/CommentDto.ts';
import { Comment, type CommentDbRow } from '../shared/domain/get_comments/Comment.ts';

jest.mock('../supabase/functions/get-comments/getCommentRepository.ts', () => ({
  findCommentsByPostIdRepo: jest.fn(),
}));

describe('GetComments - Domain/Service 테스트', () => {
  const mockAuthHeader = 'Bearer mock-token';
  const mockPostId = 'post-uuid-123';

  afterEach(() => {
    jest.clearAllMocks();
  });

  describe('Domain: Comment.fromDbRows', () => {
    it('deleted_at IS NULL만 포함하고 created_at ASC로 정렬한다', () => {
      const rows: CommentDbRow[] = [
        {
          comment_id: 'c2',
          content: '두번째',
          created_at: '2024-03-21T10:00:00Z',
          user_id: 'u2',
          post_id: mockPostId,
          deleted_at: null,
          profiles: { display_name: '작성자2' },
        },
        {
          comment_id: 'c1',
          content: '첫번째',
          created_at: '2024-03-20T10:00:00Z',
          user_id: 'u1',
          post_id: mockPostId,
          deleted_at: null,
          profiles: { display_name: '작성자1' },
        },
        {
          comment_id: 'c3',
          content: '삭제됨',
          created_at: '2024-03-22T10:00:00Z',
          user_id: 'u3',
          post_id: mockPostId,
          deleted_at: '2024-03-23T00:00:00Z',
          profiles: { display_name: '작성자3' },
        },
      ];

      const comments = Comment.fromDbRows(rows, mockPostId);
      expect(comments).toHaveLength(2);
      expect(comments[0].commentId).toBe('c1');
      expect(comments[1].commentId).toBe('c2');
    });

    it('postId 기반 필터링이 정상 동작한다', () => {
      const rows: CommentDbRow[] = [
        {
          comment_id: 'c1',
          content: 'A',
          created_at: '2024-03-20T10:00:00Z',
          user_id: 'u1',
          post_id: mockPostId,
          deleted_at: null,
          profiles: { display_name: '작성자1' },
        },
        {
          comment_id: 'c2',
          content: 'B',
          created_at: '2024-03-20T11:00:00Z',
          user_id: 'u2',
          post_id: 'other-post',
          deleted_at: null,
          profiles: { display_name: '작성자2' },
        },
      ];

      const comments = Comment.fromDbRows(rows, mockPostId);
      expect(comments).toHaveLength(1);
      expect(comments[0].commentId).toBe('c1');
    });

    it('profiles 매핑으로 authorDisplayName을 만든다 (없으면 기본값)', () => {
      const rows: CommentDbRow[] = [
        {
          comment_id: 'c1',
          content: 'A',
          created_at: '2024-03-20T10:00:00Z',
          user_id: 'u1',
          post_id: mockPostId,
          deleted_at: null,
          profiles: { display_name: '작성자1' },
        },
        {
          comment_id: 'c2',
          content: 'B',
          created_at: '2024-03-20T11:00:00Z',
          user_id: 'u2',
          post_id: mockPostId,
          deleted_at: null,
          profiles: null,
        },
      ];

      const comments = Comment.fromDbRows(rows, mockPostId);
      expect(comments[0].authorDisplayName).toBe('작성자1');
      expect(comments[1].authorDisplayName).toBe('알 수 없는 사용자');
    });
  });

  describe('Service: getCommentsService', () => {
    it('정상적으로 comments 리스트를 반환한다 (user_id 미포함)', async () => {
      const rows: CommentDbRow[] = [
        {
          comment_id: 'c1',
          content: '첫번째',
          created_at: '2024-03-20T10:00:00Z',
          user_id: 'u1',
          post_id: mockPostId,
          deleted_at: null,
          profiles: { display_name: '작성자1' },
        },
      ];

      const domainComments = Comment.fromDbRows(rows, mockPostId);
      (findCommentsByPostIdRepo as jest.Mock).mockResolvedValue(domainComments);

      const result = await getCommentsService(mockAuthHeader, mockPostId);

      expect(findCommentsByPostIdRepo).toHaveBeenCalledWith(mockAuthHeader, mockPostId);
      expect(result).toBeInstanceOf(GetCommentsResponseDto);
      expect(result.comments).toHaveLength(1);
      expect(result.comments[0]).toEqual(
        expect.objectContaining({
          commentId: 'c1',
          content: '첫번째',
          authorDisplayName: '작성자1',
          createdAt: '2024-03-20T10:00:00Z',
        })
      );
      expect((result.comments[0] as unknown as { user_id?: unknown }).user_id).toBeUndefined();
    });

    it('조회 실패(null) 시 DATABASE_ERROR를 던진다', async () => {
      (findCommentsByPostIdRepo as jest.Mock).mockResolvedValue(null);

      await expect(getCommentsService(mockAuthHeader, mockPostId)).rejects.toThrow(
        'DATABASE_ERROR: 댓글 목록을 불러오지 못했습니다.'
      );
    });
  });
});
