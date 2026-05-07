import { Post } from '../../../shared/domain/posts/Post.ts';
import { PostPostsRequestDto } from '../../../shared/dto/posts/PostPostsRequest.dto.ts';
import {
  GetPostsResponseDto,
  PostSummaryDto,
  GetMyPostsResponseDto,
  MyPostSummaryDto,
} from '../../../shared/dto/posts/GetPostsResponse.dto.ts';
import {
  findAllPostsRepo,
  findAllMyPostsRepo,
  savePostRepo,
  createPortfolioSnapshotRepo,
} from './postsRepository.ts';

type SingleOrArray<T> = T | T[];

interface RawPostRecord {
  id: string;
  user_id: string;
  portfolio_snapshot_id: string | null;
  content: string;
  comments_count: number;
  created_at: string;
  profiles: SingleOrArray<{ display_name: string | null }> | null;
  portfolio_snapshots: SingleOrArray<{
    id: string;
    portfolios: SingleOrArray<{
      name: string;
      simulation_input: {
        goal?: { investment_period_months?: number };
        assets?: unknown[];
      };
    }> | null;
  }> | null;
}

export async function addPostService(userId: string, dto: PostPostsRequestDto): Promise<string> {
  let snapshotId: string | null = null;

  if (typeof dto.portfolioId === 'string' && dto.portfolioId.trim().length > 0) {
    snapshotId = await createPortfolioSnapshotRepo(userId, dto.portfolioId);

    if (!snapshotId) {
      throw new Error('NOT_FOUND: 게시할 포트폴리오를 찾을 수 없거나 접근 권한이 없습니다.');
    }
  }

  const post = new Post(userId, snapshotId, dto.content);

  const postId = await savePostRepo(post);

  if (!postId) {
    throw new Error('DATABASE_ERROR: 게시물 저장 중 오류가 발생했습니다.');
  }

  return postId;
}

export async function getPostsService(authHeader: string): Promise<GetPostsResponseDto> {
  const rawData = await findAllPostsRepo(authHeader);

  if (!rawData) {
    throw new Error('DATABASE_ERROR: 게시글 목록을 불러오지 못했습니다.');
  }

  const summaries = (rawData as unknown as RawPostRecord[]).map((item) => {
    const profile = Array.isArray(item.profiles) ? item.profiles[0] : item.profiles;
    const snapshot = Array.isArray(item.portfolio_snapshots)
      ? item.portfolio_snapshots[0]
      : item.portfolio_snapshots;
    const portfolio =
      snapshot &&
      (Array.isArray(snapshot.portfolios) ? snapshot.portfolios[0] : snapshot.portfolios);

    const postDomain = new Post(
      item.user_id,
      item.portfolio_snapshot_id || 'N/A',
      item.content,
      item.id,
      item.created_at,
      item.comments_count
    );

    const simInput = portfolio?.simulation_input;
    const assetCount = Array.isArray(simInput?.assets) ? simInput.assets.length : 0;
    const investmentPeriodMonths = simInput?.goal?.investment_period_months || 0;

    return new PostSummaryDto(
      postDomain.id!,
      postDomain.content,
      profile?.display_name || '알 수 없는 사용자',
      snapshot?.id || null,
      portfolio?.name || null,
      assetCount,
      investmentPeriodMonths,
      item.created_at,
      postDomain.commentsCount
    );
  });

  return new GetPostsResponseDto(summaries);
}

export async function getMyPostsService(
  authHeader: string,
  userId: string
): Promise<GetMyPostsResponseDto> {
  const rawData = await findAllMyPostsRepo(authHeader, userId);

  if (!rawData) {
    throw new Error('DATABASE_ERROR: 내 게시글 목록을 불러오지 못했습니다.');
  }

  const summaries = (rawData as unknown as RawPostRecord[]).map((item) => {
    // 1. 조인 데이터 추출 (배열 형태 대응)
    const profile = Array.isArray(item.profiles) ? item.profiles[0] : item.profiles;
    const snapshot = Array.isArray(item.portfolio_snapshots)
      ? item.portfolio_snapshots[0]
      : item.portfolio_snapshots;
    const portfolio =
      snapshot &&
      (Array.isArray(snapshot.portfolios) ? snapshot.portfolios[0] : snapshot.portfolios);

    // 2. JSONB 데이터 추출
    const simInput = portfolio?.simulation_input;
    const assetCount = Array.isArray(simInput?.assets) ? simInput.assets.length : 0;
    const investmentPeriodMonths = simInput?.goal?.investment_period_months || 0;

    // 3. 내 게시글 전용 DTO로 변환 (content, snapshotId 제외)
    return new MyPostSummaryDto(
      item.id,
      item.content,
      profile?.display_name || '알 수 없는 사용자',
      portfolio?.name || null,
      assetCount,
      investmentPeriodMonths,
      item.created_at,
      item.comments_count || 0
    );
  });

  return new GetMyPostsResponseDto(summaries);
}
