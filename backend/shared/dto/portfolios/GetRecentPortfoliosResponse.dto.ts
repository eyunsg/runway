export class RecentPortfolioDto {
  portfolioId: string;
  name: string;
  assetCount: number;
  investmentPeriodMonths: number;
  updatedAt: string;

  constructor(
    portfolioId: string,
    name: string,
    assetCount: number,
    investmentPeriodMonths: number,
    updatedAt: string
  ) {
    this.portfolioId = portfolioId;
    this.name = name;
    this.assetCount = assetCount;
    this.investmentPeriodMonths = investmentPeriodMonths;
    this.updatedAt = updatedAt;
  }
}

export class GetRecentPortfoliosResponseDto {
  portfolios: RecentPortfolioDto[];

  constructor(portfolios: RecentPortfolioDto[]) {
    this.portfolios = portfolios;
  }
}
