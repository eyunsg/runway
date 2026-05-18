export class RecentPostDto {
  public postId: string;
  public authorDisplayName: string;
  public portfolioName: string | null;
  public assetCount: number | null;
  public investmentPeriodMonths: number | null;
  public createdAt: string;
  public commentCount: number;

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

export class GetRecentPostsResponseDto {
  public posts: RecentPostDto[];

  constructor(posts: RecentPostDto[]) {
    this.posts = posts;
  }
}
