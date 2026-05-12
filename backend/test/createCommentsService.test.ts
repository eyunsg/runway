import { createCommentService } from '../supabase/functions/create-comment/createCommentService.ts';
import { createCommentRepo } from '../supabase/functions/create-comment/createCommentRepository.ts';
import { Comment } from '../shared/domain/create_comments/Comment.ts';

// Repository를 가짜(Mock)로 만듭니다.
jest.mock('../supabase/functions/create-comment/createCommentRepository.ts', () => ({
  createCommentRepo: jest.fn(),
}));

describe('CreateComment - Domain/Service 테스트', () => {
  const mockAuthHeader = 'Bearer mock-token';
  const mockPostId = 'post-123';
  const mockUserId = 'user-456';
  const mockContent = '안녕하세요, 테스트 댓글입니다.';

  afterEach(() => {
    jest.clearAllMocks();
  });

  describe('Domain: Comment 클래스', () => {
    it('유효한 데이터로 Comment 객체를 생성한다', () => {
      const comment = Comment.create(mockContent, mockPostId, mockUserId);

      expect(comment.content).toBe(mockContent);
      expect(comment.postId).toBe(mockPostId);
      expect(comment.userId).toBe(mockUserId);
    });

    it('내용이 비어있으면 VALIDATION_ERROR를 던진다', () => {
      expect(() => {
        Comment.create('', mockPostId, mockUserId);
      }).toThrow('VALIDATION_ERROR: 댓글 내용은 비어있을 수 없습니다.');
    });

    it('내용이 1000자를 초과하면 VALIDATION_ERROR를 던진다', () => {
      const longContent = 'a'.repeat(1001);
      expect(() => {
        Comment.create(longContent, mockPostId, mockUserId);
      }).toThrow('VALIDATION_ERROR: 댓글은 1000자 이내로 작성해야 합니다.');
    });

    it('toDbInsertRow가 DB 컬럼명에 맞는 객체를 반환한다', () => {
      const comment = Comment.create(mockContent, mockPostId, mockUserId);
      const row = comment.toDbInsertRow();

      expect(row).toHaveProperty('content', mockContent);
      expect(row).toHaveProperty('post_id', mockPostId);
      expect(row).toHaveProperty('user_id', mockUserId);
      expect(row).toHaveProperty('created_at');
    });
  });

  describe('Service: createCommentService', () => {
    it('정상적인 요청 시 레포지토리를 호출한다', async () => {
      // 레포지토리가 성공한다고 가정
      (createCommentRepo as jest.Mock).mockResolvedValue(undefined);

      await createCommentService(mockAuthHeader, mockPostId, mockUserId, mockContent);

      // 레포지토리가 호출되었는지 확인
      expect(createCommentRepo).toHaveBeenCalledTimes(1);

      // 전달된 인자가 도메인 규칙을 따르는지 확인
      const calledArgs = (createCommentRepo as jest.Mock).mock.calls[0];
      expect(calledArgs[0]).toBe(mockAuthHeader);
      expect(calledArgs[1].content).toBe(mockContent);
      expect(calledArgs[1].post_id).toBe(mockPostId);
    });

    it('유효성 검사 실패 시 레포지토리를 호출하지 않고 에러를 던진다', async () => {
      const emptyContent = '   ';

      await expect(
        createCommentService(mockAuthHeader, mockPostId, mockUserId, emptyContent)
      ).rejects.toThrow('VALIDATION_ERROR');

      expect(createCommentRepo).not.toHaveBeenCalled();
    });

    it('레포지토리에서 에러 발생 시 에러를 상위로 전파한다', async () => {
      (createCommentRepo as jest.Mock).mockRejectedValue(new Error('DATABASE_ERROR: 저장 실패'));

      await expect(
        createCommentService(mockAuthHeader, mockPostId, mockUserId, mockContent)
      ).rejects.toThrow('DATABASE_ERROR: 저장 실패');
    });
  });
});
