export class PostSummaryDto {
  postId: string;
  content: string;
  authorDisplayName: string;
  portfolioSnapshotId: string | null;
  portfolioName: string | null;
  assetCount: number | null;
  investmentPeriodMonths: number | null;
  createdAt: string;
  commentCount: number;

  constructor(
    postId: string,
    content: string,
    authorDisplayName: string,
    portfolioSnapshotId: string | null,
    portfolioName: string | null,
    assetCount: number | null,
    investmentPeriodMonths: number | null,
    createdAt: string,
    commentCount: number
  ) {
    this.postId = postId;
    this.content = content;
    this.authorDisplayName = authorDisplayName;
    this.portfolioSnapshotId = portfolioSnapshotId;
    this.portfolioName = portfolioName;
    this.assetCount = assetCount;
    this.investmentPeriodMonths = investmentPeriodMonths;
    this.createdAt = createdAt;
    this.commentCount = commentCount;
  }
}

export class GetPostsResponseDto {
  posts: PostSummaryDto[];

  constructor(posts: PostSummaryDto[]) {
    this.posts = posts;
  }
}

export class MyPostSummaryDto {
  postId: string;
  authorDisplayName: string;
  portfolioName: string | null;
  assetCount: number | null;
  investmentPeriodMonths: number | null;
  createdAt: string;
  commentCount: number;

  constructor(
    postId: string,
    authorDisplayName: string,
    portfolioName: string | null,
    assetCount: number | null,
    investmentPeriodMonths: number | null,
    createdAt: string,
    commentCount: number
  ) {
    this.postId = postId;
    this.authorDisplayName = authorDisplayName;
    this.portfolioName = portfolioName;
    this.assetCount = assetCount;
    this.investmentPeriodMonths = investmentPeriodMonths;
    this.createdAt = createdAt;
    this.commentCount = commentCount;
  }
}

export class GetMyPostsResponseDto {
  posts: MyPostSummaryDto[];

  constructor(posts: MyPostSummaryDto[]) {
    this.posts = posts;
  }
}
