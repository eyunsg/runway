import {
  addPostService,
  getPostsService,
  getMyPostsService,
} from '../supabase/functions/posts/postsService.ts';
import {
  createPortfolioSnapshotRepo,
  savePostRepo,
  findAllPostsRepo,
  findAllMyPostsRepo,
} from '../supabase/functions/posts/postsRepository.ts';
import { PostPostsRequestDto } from '../shared/dto/posts/PostPostsRequest.dto.ts';
import {
  GetPostsResponseDto,
  GetMyPostsResponseDto,
} from '../shared/dto/posts/GetPostsResponse.dto.ts';

// 리포지토리 모킹
jest.mock('../supabase/functions/posts/postsRepository.ts', () => ({
  createPortfolioSnapshotRepo: jest.fn(),
  savePostRepo: jest.fn(),
  findAllPostsRepo: jest.fn(),
  findAllMyPostsRepo: jest.fn(),
}));

describe('PostsService 테스트', () => {
  const mockUserId = 'user-uuid-123';
  const mockAuthHeader = 'Bearer mock-token';

  afterEach(() => {
    jest.clearAllMocks();
  });

  describe('PostsService - 게시물 생성 테스트 (API-COMM-001)', () => {
    const mockPortfolioId = 'portfolio-uuid-456';
    const mockSnapshotId = 'snapshot-uuid-789';
    const mockPostId = 'post-uuid-999';

    // 성공 케이스를 위한 유효한 데이터
    const validRequestData = {
      portfolioId: mockPortfolioId,
      content: '이것은 테스트 게시물 내용입니다. 제 포트폴리오를 확인해보세요!',
    };

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

  describe('getPostsService - 전체 게시글 목록 조회 (API-COMM-002)', () => {
    // DB에서 넘어오는 복잡한 조인 데이터를 시뮬레이션
    const mockRawData = [
      {
        id: 'post-1',
        user_id: mockUserId,
        portfolio_snapshot_id: 'snapshot-1',
        content: '첫 번째 게시글입니다.',
        comments_count: 5,
        created_at: '2024-03-20T10:00:00Z',
        profiles: { display_name: '테스터1' }, // 객체 형태 조인
        portfolio_snapshots: [
          // 배열 형태 조인
          {
            id: 'snapshot-1',
            portfolios: {
              name: '공격적 포트폴리오',
              simulation_input: {
                goal: { investment_period_months: 24 },
                assets: [{}, {}, {}], // 자산 3개
              },
            },
          },
        ],
      },
    ];

    it('레포지토리로부터 데이터를 성공적으로 가져와 DTO로 매핑한다', async () => {
      // 1. 리포지토리 응답 모킹
      (findAllPostsRepo as jest.Mock).mockResolvedValue(mockRawData);

      // 2. 서비스 호출
      const result = await getPostsService(mockAuthHeader);

      // 3. 검증
      expect(result).toBeInstanceOf(GetPostsResponseDto);
      expect(result.posts).toHaveLength(1);

      const post = result.posts[0];
      expect(post.postId).toBe('post-1');
      expect(post.authorDisplayName).toBe('테스터1');
      expect(post.portfolioName).toBe('공격적 포트폴리오');
      expect(post.assetCount).toBe(3); // assets 배열 길이 확인
      expect(post.investmentPeriodMonths).toBe(24);
      expect(post.commentCount).toBe(5);

      // RLS를 위해 authHeader가 전달되었는지 확인
      expect(findAllPostsRepo).toHaveBeenCalledWith(mockAuthHeader);
    });

    it('레포지토리 조회 결과가 null이면 DATABASE_ERROR를 던진다', async () => {
      (findAllPostsRepo as jest.Mock).mockResolvedValue(null);

      await expect(getPostsService(mockAuthHeader)).rejects.toThrow(
        'DATABASE_ERROR: 게시글 목록을 불러오지 못했습니다.'
      );
    });

    it('조인된 데이터가 비어있어도 기본값을 포함하여 정상적으로 반환한다', async () => {
      const minimalRawData = [
        {
          id: 'post-2',
          user_id: 'user-2',
          portfolio_snapshot_id: null,
          content: '스냅샷 없는 게시글',
          comments_count: 0,
          created_at: '2024-03-21T10:00:00Z',
          profiles: [], // 프로필 없음
          portfolio_snapshots: null, // 스냅샷 없음
        },
      ];

      (findAllPostsRepo as jest.Mock).mockResolvedValue(minimalRawData);

      const result = await getPostsService(mockAuthHeader);
      const post = result.posts[0];

      expect(post.authorDisplayName).toBe('알 수 없는 사용자');
      expect(post.portfolioName).toBeNull();
      expect(post.assetCount).toBe(0);
    });

    it('DB 데이터가 도메인 규칙(5000자 초과 등)을 위반하면 에러를 던진다', async () => {
      const invalidRawData = [
        {
          ...mockRawData[0],
          content: 'A'.repeat(5001), // 5000자 초과
        },
      ];

      (findAllPostsRepo as jest.Mock).mockResolvedValue(invalidRawData);

      // 서비스 내부에서 new Post() 생성 시 도메인 validate()에 의해 에러 발생
      await expect(getPostsService(mockAuthHeader)).rejects.toThrow('VALIDATION_ERROR');
    });
  });

  describe('getMyPostsService - 내 게시글 목록 조회 (API-COMM-009)', () => {
    const mockMyRawData = [
      {
        id: 'my-post-1',
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
      expect(post.authorDisplayName).toBe('본인유저');
      expect(post.portfolioName).toBe('내 은퇴 자금');
      expect(post.assetCount).toBe(2);
      expect(post.investmentPeriodMonths).toBe(120);
      expect(post.commentCount).toBe(3);

      // 명세서 상 내 게시글에는 content와 snapshotId가 없어야 함
      expect(post).not.toHaveProperty('content');
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
