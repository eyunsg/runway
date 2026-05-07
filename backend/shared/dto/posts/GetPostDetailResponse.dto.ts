export class PostDetailDto {
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

export class GetPostDetailResponseDto {
  post: PostDetailDto;

  constructor(post: PostDetailDto) {
    this.post = post;
  }
}
