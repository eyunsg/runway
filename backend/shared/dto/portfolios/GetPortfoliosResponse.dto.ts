export class PortfolioSummaryDto {
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

export class GetPortfoliosResponseDto {
  portfolios: PortfolioSummaryDto[];

  constructor(portfolios: PortfolioSummaryDto[]) {
    this.portfolios = portfolios;
  }
}
