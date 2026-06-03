import { deleteCommentService } from '../supabase/functions/delete-comments/deleteCommentsService.ts';
import { softDeleteCommentRepo } from '../supabase/functions/delete-comments/deleteCommentRepository.ts';

// Repository 함수 모킹
jest.mock('../supabase/functions/delete-comments/deleteCommentRepository.ts', () => ({
  softDeleteCommentRepo: jest.fn(),
}));

describe('DeleteComment - Service 테스트', () => {
  const mockAuthHeader = 'Bearer mock-token';
  const mockCommentId = 'comment-uuid-123';

  afterEach(() => {
    jest.clearAllMocks();
  });

  describe('Service: deleteCommentService', () => {
    it('정상적으로 댓글이 삭제(Soft Delete)되어야 한다', async () => {
      // 레포지토리가 성공(true)을 반환하도록 설정
      (softDeleteCommentRepo as jest.Mock).mockResolvedValue(true);

      // 서비스 호출
      await deleteCommentService(mockAuthHeader, mockCommentId);

      // 레포지토리가 올바른 인자와 함께 호출되었는지 확인
      expect(softDeleteCommentRepo).toHaveBeenCalledWith(mockAuthHeader, mockCommentId);
    });

    it('레포지토리 실행 중 예외가 발생하면 에러가 상위로 전파되어야 한다', async () => {
      // 레포지토리에서 실제 DB 에러가 발생한 상황 시뮬레이션
      const dbError = new Error('DATABASE_ERROR: Connection Timeout');
      (softDeleteCommentRepo as jest.Mock).mockRejectedValue(dbError);

      await expect(deleteCommentService(mockAuthHeader, mockCommentId)).rejects.toThrow(
        'DATABASE_ERROR: Connection Timeout'
      );
    });
  });
});
