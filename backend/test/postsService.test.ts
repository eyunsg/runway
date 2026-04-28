import { addPostService } from '../supabase/functions/posts/postsService.ts';
import {
  createPortfolioSnapshotRepo,
  savePostRepo,
} from '../supabase/functions/posts/postsRepository.ts';
import { PostPostsRequestDto } from '../shared/dto/posts/PostPostsRequest.dto.ts';

// 리포지토리 모킹
jest.mock('../supabase/functions/posts/postsRepository.ts', () => ({
  createPortfolioSnapshotRepo: jest.fn(),
  savePostRepo: jest.fn(),
}));

describe('PostsService - 게시물 생성 테스트 (API-COMM-001)', () => {
  const mockUserId = 'user-uuid-123';
  const mockPortfolioId = 'portfolio-uuid-456';
  const mockSnapshotId = 'snapshot-uuid-789';
  const mockPostId = 'post-uuid-999';

  // 성공 케이스를 위한 유효한 데이터
  const validRequestData = {
    portfolioId: mockPortfolioId,
    content: '이것은 테스트 게시물 내용입니다. 제 포트폴리오를 확인해보세요!',
  };

  afterEach(() => {
    jest.clearAllMocks();
  });

  describe('addPostService', () => {
    it('정상적인 데이터를 입력하면 스냅샷 생성 후 성공적으로 게시물 ID를 반환한다', async () => {
      // 1. 리포지토리 모킹 설정
      (createPortfolioSnapshotRepo as jest.Mock).mockResolvedValue(mockSnapshotId);
      (savePostRepo as jest.Mock).mockResolvedValue(mockPostId);

      // 2. 서비스 호출
      const dto = new PostPostsRequestDto(validRequestData);
      const result = await addPostService(mockUserId, dto);

      // 3. 결과 검증
      expect(result).toBe(mockPostId);

      // 4. 리포지토리 호출 순서 및 인자 확인
      expect(createPortfolioSnapshotRepo).toHaveBeenCalledWith(mockUserId, mockPortfolioId);
      expect(savePostRepo).toHaveBeenCalledWith(
        expect.objectContaining({
          userId: mockUserId,
          portfolioSnapshotId: mockSnapshotId,
          content: validRequestData.content,
        })
      );
      expect(createPortfolioSnapshotRepo).toHaveBeenCalledTimes(1);
      expect(savePostRepo).toHaveBeenCalledTimes(1);
    });

    it('포트폴리오가 존재하지 않거나 권한이 없어 스냅샷 생성에 실패하면 NOT_FOUND 에러를 던진다', async () => {
      // 스냅샷 생성 결과가 null인 상황 모킹
      (createPortfolioSnapshotRepo as jest.Mock).mockResolvedValue(null);

      const dto = new PostPostsRequestDto(validRequestData);

      await expect(addPostService(mockUserId, dto)).rejects.toThrow(
        'NOT_FOUND: 게시할 포트폴리오를 찾을 수 없거나 접근 권한이 없습니다.'
      );

      // 스냅샷 생성 실패 시 게시물 저장은 호출되지 않아야 함
      expect(savePostRepo).not.toHaveBeenCalled();
    });

    it('리포지토리에서 게시물 저장에 실패하면 DATABASE_ERROR를 던진다', async () => {
      (createPortfolioSnapshotRepo as jest.Mock).mockResolvedValue(mockSnapshotId);
      // 게시물 저장 결과가 null인 상황 모킹
      (savePostRepo as jest.Mock).mockResolvedValue(null);

      const dto = new PostPostsRequestDto(validRequestData);

      await expect(addPostService(mockUserId, dto)).rejects.toThrow(
        'DATABASE_ERROR: 게시물 저장 중 오류가 발생했습니다.'
      );
    });

    it('게시물 내용(content)이 비어있을 경우 도메인 검증 단계에서 VALIDATION_ERROR를 던진다', async () => {
      (createPortfolioSnapshotRepo as jest.Mock).mockResolvedValue(mockSnapshotId);

      const invalidData = { ...validRequestData, content: '   ' };

      // Post 도메인 객체 생성 시 validate()가 실행되어 에러가 발생함
      await expect(async () => {
        const dto = new PostPostsRequestDto(invalidData);
        await addPostService(mockUserId, dto);
      }).rejects.toThrow('VALIDATION_ERROR: 게시물 내용은 필수이며 비어있을 수 없습니다.');

      expect(savePostRepo).not.toHaveBeenCalled();
    });

    it('게시물 내용이 5000자를 초과할 경우 VALIDATION_ERROR를 던진다', async () => {
      (createPortfolioSnapshotRepo as jest.Mock).mockResolvedValue(mockSnapshotId);

      const longContent = 'A'.repeat(5001);
      const invalidData = { ...validRequestData, content: longContent };

      await expect(async () => {
        const dto = new PostPostsRequestDto(invalidData);
        await addPostService(mockUserId, dto);
      }).rejects.toThrow('VALIDATION_ERROR: 게시물 내용은 5000자 이내여야 합니다.');

      expect(savePostRepo).not.toHaveBeenCalled();
    });

    it('유효하지 않은 portfolioId 형식인 경우 DTO 검증 단계에서 VALIDATION_ERROR를 던진다', async () => {
      const invalidData = { ...validRequestData, portfolioId: 12345 }; // 문자열이 아닌 경우

      await expect(async () => {
        // @ts-ignore: 테스트를 위해 잘못된 타입 전달
        const dto = new PostPostsRequestDto(invalidData);
        await addPostService(mockUserId, dto);
      }).rejects.toThrow('VALIDATION_ERROR');
    });

    it('유저 ID가 누락된 경우 도메인 검증 단계에서 에러를 던진다', async () => {
      (createPortfolioSnapshotRepo as jest.Mock).mockResolvedValue(mockSnapshotId);
      const dto = new PostPostsRequestDto(validRequestData);

      // @ts-ignore: 테스트를 위해 undefined 전달
      await expect(addPostService(undefined, dto)).rejects.toThrow('VALIDATION_ERROR');
    });
  });
});
