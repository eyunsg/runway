import { Post } from '../../../shared/domain/posts/Post.ts';
import { PostPostsRequestDto } from '../../../shared/dto/posts/PostPostsRequest.dto.ts';
import { UpdatePostsRequestDto } from '../../../shared/dto/posts/UpdatePostsRequest.dto.ts';
import {
  GetPostsResponseDto,
  PostSummaryDto,
  GetMyPostsResponseDto,
  MyPostSummaryDto,
} from '../../../shared/dto/posts/GetPostsResponse.dto.ts';
import { PostDetailDto } from '../../../shared/dto/posts/GetPostDetailResponse.dto.ts';
import {
  GetRecentPostsResponseDto,
  RecentPostDto,
} from '../../../shared/dto/posts/GetRecentPostsResponse.dto.ts';
import {
  findAllPostsRepo,
  findAllMyPostsRepo,
  findPostByIdRepo,
  updatePostRepo,
  deletePostRepo,
  savePostRepo,
  createPortfolioSnapshotRepo,
  findRecentPostsRepo,
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

export async function addPostService(
  authHeader: string,
  userId: string,
  dto: PostPostsRequestDto
): Promise<string> {
  let snapshotId: string | null = null;

  if (typeof dto.portfolioId === 'string' && dto.portfolioId.trim().length > 0) {
    snapshotId = await createPortfolioSnapshotRepo(authHeader, userId, dto.portfolioId);

    if (!snapshotId) {
      throw new Error('NOT_FOUND: 게시할 포트폴리오를 찾을 수 없거나 접근 권한이 없습니다.');
    }
  }

  const post = new Post(userId, snapshotId, dto.content);

  const postId = await savePostRepo(authHeader, post);

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

export async function getPostDetailService(
  authHeader: string,
  postId: string
): Promise<PostDetailDto> {
  const rawItem = await findPostByIdRepo(authHeader, postId);

  if (!rawItem) {
    throw new Error('NOT_FOUND: 요청하신 게시글을 찾을 수 없습니다.');
  }

  const item = rawItem as unknown as RawPostRecord;

  // 조인 데이터 추출 (배열 형태 대응)
  const profile = Array.isArray(item.profiles) ? item.profiles[0] : item.profiles;
  const snapshot = Array.isArray(item.portfolio_snapshots)
    ? item.portfolio_snapshots[0]
    : item.portfolio_snapshots;
  const portfolio =
    snapshot && (Array.isArray(snapshot.portfolios) ? snapshot.portfolios[0] : snapshot.portfolios);

  // JSONB 데이터 추출
  const simInput = portfolio?.simulation_input;
  const assetCount = Array.isArray(simInput?.assets) ? simInput.assets.length : 0;
  const investmentPeriodMonths = simInput?.goal?.investment_period_months || 0;

  // 상세 조회 전용 DTO로 변환
  return new PostDetailDto(
    item.id,
    item.content,
    profile?.display_name || '알 수 없는 사용자',
    snapshot?.id || null,
    portfolio?.name || null,
    assetCount,
    investmentPeriodMonths,
    item.created_at,
    item.comments_count || 0
  );
}

export async function updatePostService(
  authHeader: string,
  postId: string,
  dto: UpdatePostsRequestDto
): Promise<void> {
  const isUpdated = await updatePostRepo(authHeader, postId, dto.content);

  if (!isUpdated) {
    // RLS 정책에 의해 수정이 되지 않았거나(본인 아님) 글이 없는 경우
    throw new Error('NOT_FOUND: 게시글을 찾을 수 없거나 수정 권한이 없습니다.');
  }
}

export async function deletePostService(authHeader: string, postId: string): Promise<void> {
  const isDeleted = await deletePostRepo(authHeader, postId);

  if (!isDeleted) {
    throw new Error('FORBIDDEN');
  }
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

export async function getRecentPostsService(
  authHeader: string
): Promise<GetRecentPostsResponseDto> {
  // 1. 리포지토리에서 최근 등록된 게시글 최대 3건 수집
  const rawData = await findRecentPostsRepo(authHeader, 3);

  if (!rawData) {
    throw new Error('DATABASE_ERROR: 최근 게시글 목록을 불러오지 못했습니다.');
  }

  // 2. DB 원시 데이터를 RecentPostDto 클래스 인스턴스로 바인딩
  const posts = (rawData as unknown as RawPostRecord[]).map((item) => {
    const profile = Array.isArray(item.profiles) ? item.profiles[0] : item.profiles;
    const snapshot = Array.isArray(item.portfolio_snapshots)
      ? item.portfolio_snapshots[0]
      : item.portfolio_snapshots;
    const portfolio =
      snapshot &&
      (Array.isArray(snapshot.portfolios) ? snapshot.portfolios[0] : snapshot.portfolios);

    const simInput = portfolio?.simulation_input;
    const assetCount = Array.isArray(simInput?.assets) ? simInput.assets.length : 0;
    const investmentPeriodMonths = simInput?.goal?.investment_period_months || 0;

    // RecentPostDto 클래스 생성자를 통해 데이터 정합성을 유지하며 가공
    return new RecentPostDto(
      item.id,
      profile?.display_name || '알 수 없는 사용자',
      portfolio?.name || null,
      assetCount,
      investmentPeriodMonths,
      item.created_at,
      item.comments_count || 0
    );
  });

  // 3. 최종 GetRecentPostsResponseDto 인스턴스를 조립해 반환
  return new GetRecentPostsResponseDto(posts);
}
