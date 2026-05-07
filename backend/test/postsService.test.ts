import {
  addPostService,
  getPostsService,
  getMyPostsService,
  getPostDetailService,
} from '../supabase/functions/posts/postsService.ts';
import {
  createPortfolioSnapshotRepo,
  savePostRepo,
  findAllPostsRepo,
  findAllMyPostsRepo,
  findPostByIdRepo,
} from '../supabase/functions/posts/postsRepository.ts';
import { PostPostsRequestDto } from '../shared/dto/posts/PostPostsRequest.dto.ts';
import {
  GetPostsResponseDto,
  GetMyPostsResponseDto,
} from '../shared/dto/posts/GetPostsResponse.dto.ts';
import { PostDetailDto } from '../shared/dto/posts/GetPostDetailResponse.dto.ts';

// 리포지토리 모킹
jest.mock('../supabase/functions/posts/postsRepository.ts', () => ({
  createPortfolioSnapshotRepo: jest.fn(),
  savePostRepo: jest.fn(),
  findAllPostsRepo: jest.fn(),
  findAllMyPostsRepo: jest.fn(),
  findPostByIdRepo: jest.fn(),
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

      // 서비스 내부에서 new Post() 생성 시 도메인 validate()에 의해 에러 발생
      await expect(getPostsService(mockAuthHeader)).rejects.toThrow('VALIDATION_ERROR');
    });
  });

  describe('getPostDetailService - 게시글 상세 조회 (API-COMM-003)', () => {
    const mockDetailRawData = {
      id: mockPostId,
      user_id: mockUserId,
      portfolio_snapshot_id: mockSnapshotId,
      content: '상세 보기용 테스트 내용입니다.',
      comments_count: 15,
      created_at: '2024-03-25T12:00:00Z',
      profiles: { display_name: '상세작성자' },
      portfolio_snapshots: [
        {
          id: mockSnapshotId,
          portfolios: {
            name: '상세조회 포트폴리오',
            simulation_input: {
              goal: { investment_period_months: 36 },
              assets: [{}, {}, {}, {}, {}],
            },
          },
        },
      ],
    };

    it('존재하는 postId로 조회 시 상세 데이터를 PostDetailDto로 올바르게 매핑한다', async () => {
      (findPostByIdRepo as jest.Mock).mockResolvedValue(mockDetailRawData);

      const result = await getPostDetailService(mockAuthHeader, mockPostId);

      expect(result).toBeInstanceOf(PostDetailDto);
      expect(result.postId).toBe(mockPostId);
      expect(result.content).toBe('상세 보기용 테스트 내용입니다.');
      expect(result.authorDisplayName).toBe('상세작성자');
      expect(result.portfolioName).toBe('상세조회 포트폴리오');
      expect(result.assetCount).toBe(5);
      expect(result.investmentPeriodMonths).toBe(36);
      expect(result.commentCount).toBe(15);

      expect(findPostByIdRepo).toHaveBeenCalledWith(mockAuthHeader, mockPostId);
    });

    it('요청한 게시글이 존재하지 않으면 NOT_FOUND 에러를 던진다', async () => {
      (findPostByIdRepo as jest.Mock).mockResolvedValue(null);

      await expect(getPostDetailService(mockAuthHeader, 'non-existent-id')).rejects.toThrow(
        'NOT_FOUND: 요청하신 게시글을 찾을 수 없습니다.'
      );
    });

    it('리포지토리에서 예외 발생 시 에러를 그대로 전파한다', async () => {
      (findPostByIdRepo as jest.Mock).mockRejectedValue(new Error('DATABASE_ERROR: 연결 실패'));

      await expect(getPostDetailService(mockAuthHeader, mockPostId)).rejects.toThrow(
        'DATABASE_ERROR: 연결 실패'
      );
    });

    it('프로필이나 포트폴리오 정보가 없는 경우에도 기본값을 사용하여 정상 응답한다', async () => {
      const minimalData = {
        id: 'no-info-post',
        user_id: 'user-99',
        portfolio_snapshot_id: null,
        content: '정보 없는 게시글',
        comments_count: 0,
        created_at: '2024-03-26T10:00:00Z',
        profiles: null,
        portfolio_snapshots: null,
      };

      (findPostByIdRepo as jest.Mock).mockResolvedValue(minimalData);

      const result = await getPostDetailService(mockAuthHeader, 'no-info-post');

      expect(result.authorDisplayName).toBe('알 수 없는 사용자');
      expect(result.portfolioName).toBeNull();
      expect(result.assetCount).toBe(0);
      expect(result.investmentPeriodMonths).toBe(0);
    });
  });

  describe('getMyPostsService - 내 게시글 목록 조회 (API-COMM-009)', () => {
    const mockMyRawData = [
      {
        id: 'my-post-1',
        content: '게시물 내용입니다.',
        user_id: mockUserId,
        comments_count: 3,
        created_at: '2024-03-25T15:00:00Z',
        profiles: { display_name: '본인유저' },
        portfolio_snapshots: [
          {
            portfolios: {
              name: '내 은퇴 자금',
              simulation_input: {
                goal: { investment_period_months: 120 },
                assets: [{}, {}],
              },
            },
          },
        ],
      },
    ];

    it('성공적으로 내 게시글 목록을 가져와 명세에 맞는 DTO(MyPostSummaryDto)로 매핑한다', async () => {
      (findAllMyPostsRepo as jest.Mock).mockResolvedValue(mockMyRawData);

      const result = await getMyPostsService(mockAuthHeader, mockUserId);

      expect(result).toBeInstanceOf(GetMyPostsResponseDto);
      expect(result.posts).toHaveLength(1);

      const post = result.posts[0];
      expect(post.postId).toBe('my-post-1');
      expect(post.content).toBe('게시물 내용입니다.');
      expect(post.authorDisplayName).toBe('본인유저');
      expect(post.portfolioName).toBe('내 은퇴 자금');
      expect(post.assetCount).toBe(2);
      expect(post.investmentPeriodMonths).toBe(120);
      expect(post.commentCount).toBe(3);

      expect(post).not.toHaveProperty('portfolioSnapshotId');

      expect(findAllMyPostsRepo).toHaveBeenCalledWith(mockAuthHeader, mockUserId);
    });

    it('작성한 게시글이 없을 경우 에러 없이 빈 배열을 포함한 DTO를 반환한다', async () => {
      (findAllMyPostsRepo as jest.Mock).mockResolvedValue([]);

      const result = await getMyPostsService(mockAuthHeader, mockUserId);

      expect(result).toBeInstanceOf(GetMyPostsResponseDto);
      expect(result.posts).toHaveLength(0);
    });

    it('내 게시글 조회 결과가 null이면 DATABASE_ERROR를 던진다', async () => {
      (findAllMyPostsRepo as jest.Mock).mockResolvedValue(null);

      await expect(getMyPostsService(mockAuthHeader, mockUserId)).rejects.toThrow(
        'DATABASE_ERROR: 내 게시글 목록을 불러오지 못했습니다.'
      );
    });

    it('JSONB 데이터 구조가 불완전하더라도(assets 없음 등) 에러 없이 기본값을 반환한다', async () => {
      const incompleteJsonData = [
        {
          ...mockMyRawData[0],
          portfolio_snapshots: [
            {
              portfolios: {
                name: '불완전한 포트폴리오',
                simulation_input: {}, // 빈 객체
              },
            },
          ],
        },
      ];

      (findAllMyPostsRepo as jest.Mock).mockResolvedValue(incompleteJsonData);

      const result = await getMyPostsService(mockAuthHeader, mockUserId);
      const post = result.posts[0];

      expect(post.assetCount).toBe(0);
      expect(post.investmentPeriodMonths).toBe(0);
    });

    it('프로필이나 포트폴리오 데이터가 누락된 경우에도 기본값을 사용하여 정상 반환한다', async () => {
      const incompleteData = [
        {
          id: 'my-post-2',
          user_id: mockUserId,
          comments_count: 0,
          created_at: '2024-03-26T10:00:00Z',
          profiles: null,
          portfolio_snapshots: null,
        },
      ];

      (findAllMyPostsRepo as jest.Mock).mockResolvedValue(incompleteData);

      const result = await getMyPostsService(mockAuthHeader, mockUserId);
      const post = result.posts[0];

      expect(post.authorDisplayName).toBe('알 수 없는 사용자');
      expect(post.portfolioName).toBeNull();
      expect(post.assetCount).toBe(0);
      expect(post.investmentPeriodMonths).toBe(0);
    });
  });
});
