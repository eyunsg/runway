export class PortfolioSummaryDto {
  constructor(
    public portfolioId: string,
    public name: string,
    public assetCount: number,
    public investmentPeriodMonths: number,
    public updatedAt: string
  ) {}
}

export class GetPortfoliosResponseDto {
  constructor(public portfolios: PortfolioSummaryDto[]) {}
}
