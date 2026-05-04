import { addPostService, getPostsService } from '../supabase/functions/posts/postsService.ts';
import {
  createPortfolioSnapshotRepo,
  savePostRepo,
  findAllPostsRepo,
} from '../supabase/functions/posts/postsRepository.ts';
import { PostPostsRequestDto } from '../shared/dto/posts/PostPostsRequest.dto.ts';
import { GetPostsResponseDto } from '../shared/dto/posts/GetPostsResponse.dto.ts';

// 리포지토리 모킹
jest.mock('../supabase/functions/posts/postsRepository.ts', () => ({
  createPortfolioSnapshotRepo: jest.fn(),
  savePostRepo: jest.fn(),
  findAllPostsRepo: jest.fn(),
}));

describe('PostsService 테스트', () => {
  const mockUserId = 'user-uuid-123';
  const mockAuthHeader = 'Bearer mock-token';

  const mockPortfolioId = 'portfolio-uuid-456';
  const mockSnapshotId = 'snapshot-uuid-789';
  const mockPostId = 'post-uuid-999';

  const validRequestData = {
    portfolioId: mockPortfolioId,
    content: '이것은 테스트 게시물 내용입니다. 제 포트폴리오를 확인해보세요!',
  };

  afterEach(() => {
    jest.clearAllMocks();
  });

  //  게시물 생성 테스트
  describe('게시물 생성 (API-COMM-001)', () => {
    it('정상적인 데이터를 입력하면 스냅샷 생성 후 게시물 ID를 반환한다', async () => {
      (createPortfolioSnapshotRepo as jest.Mock).mockResolvedValue(mockSnapshotId);
      (savePostRepo as jest.Mock).mockResolvedValue(mockPostId);

      const dto = new PostPostsRequestDto(validRequestData);
      const result = await addPostService(mockUserId, dto);

      expect(result).toBe(mockPostId);

      expect(createPortfolioSnapshotRepo).toHaveBeenCalledWith(mockUserId, mockPortfolioId);
      expect(savePostRepo).toHaveBeenCalledWith(
        expect.objectContaining({
          userId: mockUserId,
          portfolioSnapshotId: mockSnapshotId,
          content: validRequestData.content,
        })
      );
    });

    it('스냅샷 생성 실패 시 NOT_FOUND 에러를 던진다', async () => {
      (createPortfolioSnapshotRepo as jest.Mock).mockResolvedValue(null);

      const dto = new PostPostsRequestDto(validRequestData);

      await expect(addPostService(mockUserId, dto)).rejects.toThrow(
        'NOT_FOUND: 게시할 포트폴리오를 찾을 수 없거나 접근 권한이 없습니다.'
      );

      expect(savePostRepo).not.toHaveBeenCalled();
    });

    it('게시물 저장 실패 시 DATABASE_ERROR를 던진다', async () => {
      (createPortfolioSnapshotRepo as jest.Mock).mockResolvedValue(mockSnapshotId);
      (savePostRepo as jest.Mock).mockResolvedValue(null);

      const dto = new PostPostsRequestDto(validRequestData);

      await expect(addPostService(mockUserId, dto)).rejects.toThrow(
        'DATABASE_ERROR: 게시물 저장 중 오류가 발생했습니다.'
      );
    });

    it('content가 비어있으면 VALIDATION_ERROR', async () => {
      (createPortfolioSnapshotRepo as jest.Mock).mockResolvedValue(mockSnapshotId);

      const invalidData = { ...validRequestData, content: '   ' };

      await expect(async () => {
        const dto = new PostPostsRequestDto(invalidData);
        await addPostService(mockUserId, dto);
      }).rejects.toThrow('VALIDATION_ERROR: 게시물 내용은 필수이며 비어있을 수 없습니다.');

      expect(savePostRepo).not.toHaveBeenCalled();
    });

    it('content가 5000자 초과 시 VALIDATION_ERROR', async () => {
      (createPortfolioSnapshotRepo as jest.Mock).mockResolvedValue(mockSnapshotId);

      const invalidData = { ...validRequestData, content: 'A'.repeat(5001) };

      await expect(async () => {
        const dto = new PostPostsRequestDto(invalidData);
        await addPostService(mockUserId, dto);
      }).rejects.toThrow('VALIDATION_ERROR: 게시물 내용은 5000자 이내여야 합니다.');

      expect(savePostRepo).not.toHaveBeenCalled();
    });

    it('portfolioId 형식이 잘못되면 VALIDATION_ERROR', async () => {
      const invalidData = { ...validRequestData, portfolioId: 12345 };

      await expect(async () => {
        // @ts-ignore
        const dto = new PostPostsRequestDto(invalidData);
        await addPostService(mockUserId, dto);
      }).rejects.toThrow('VALIDATION_ERROR');
    });

    it('userId가 없으면 VALIDATION_ERROR', async () => {
      (createPortfolioSnapshotRepo as jest.Mock).mockResolvedValue(mockSnapshotId);
      const dto = new PostPostsRequestDto(validRequestData);

      // @ts-ignore
      await expect(addPostService(undefined, dto)).rejects.toThrow('VALIDATION_ERROR');
    });
  });

  //  게시물 조회 테스트
  describe('getPostsService', () => {
    const mockRawData = [
      {
        id: 'post-1',
        user_id: mockUserId,
        portfolio_snapshot_id: 'snapshot-1',
        content: '첫 번째 게시글입니다.',
        comments_count: 5,
        created_at: '2024-03-20T10:00:00Z',
        profiles: { display_name: '테스터1' },
        portfolio_snapshots: [
          {
            id: 'snapshot-1',
            portfolios: {
              name: '공격적 포트폴리오',
              simulation_input: {
                goal: { investment_period_months: 24 },
                assets: [{}, {}, {}],
              },
            },
          },
        ],
      },
    ];

    it('정상 매핑', async () => {
      (findAllPostsRepo as jest.Mock).mockResolvedValue(mockRawData);

      const result = await getPostsService(mockAuthHeader);

      expect(result).toBeInstanceOf(GetPostsResponseDto);

      const post = result.posts[0];
      expect(post.postId).toBe('post-1');
      expect(post.authorDisplayName).toBe('테스터1');
      expect(post.portfolioName).toBe('공격적 포트폴리오');
      expect(post.assetCount).toBe(3);
      expect(post.investmentPeriodMonths).toBe(24);
      expect(post.commentCount).toBe(5);

      expect(findAllPostsRepo).toHaveBeenCalledWith(mockAuthHeader);
    });

    it('조회 실패 시 DATABASE_ERROR', async () => {
      (findAllPostsRepo as jest.Mock).mockResolvedValue(null);

      await expect(getPostsService(mockAuthHeader)).rejects.toThrow(
        'DATABASE_ERROR: 게시글 목록을 불러오지 못했습니다.'
      );
    });

    it('조인 데이터 없을 때 기본값 처리', async () => {
      const minimalRawData = [
        {
          id: 'post-2',
          user_id: 'user-2',
          portfolio_snapshot_id: null,
          content: '스냅샷 없는 게시글',
          comments_count: 0,
          created_at: '2024-03-21T10:00:00Z',
          profiles: [],
          portfolio_snapshots: null,
        },
      ];

      (findAllPostsRepo as jest.Mock).mockResolvedValue(minimalRawData);

      const result = await getPostsService(mockAuthHeader);
      const post = result.posts[0];

      expect(post.authorDisplayName).toBe('알 수 없는 사용자');
      expect(post.portfolioName).toBeNull();
      expect(post.assetCount).toBe(0);
    });

    it('도메인 위반 시 VALIDATION_ERROR', async () => {
      const invalidRawData = [
        {
          ...mockRawData[0],
          content: 'A'.repeat(5001),
        },
      ];

      (findAllPostsRepo as jest.Mock).mockResolvedValue(invalidRawData);

      await expect(getPostsService(mockAuthHeader)).rejects.toThrow('VALIDATION_ERROR');
    });
  });
});
