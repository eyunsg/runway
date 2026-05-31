import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:runway/core/providers.dart';
import 'package:runway/domain/entity/portfolio.dart';
import 'package:go_router/go_router.dart';
import 'package:runway/core/theme/app_colors.dart';
import 'package:runway/core/theme/app_typography.dart';

class GetPortfolioScreen extends ConsumerStatefulWidget {
  const GetPortfolioScreen({super.key, this.isSelectionMode = false});

  final bool isSelectionMode;

  @override
  ConsumerState createState() => _GetPortfolioScreenState();
}

class _GetPortfolioScreenState extends ConsumerState<GetPortfolioScreen> {
  bool _hasRequestedInitialData = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_hasRequestedInitialData) return;
      _hasRequestedInitialData = true;

      ref.read(getPortfolioControllerProvider.notifier).fetchPortfolio();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  String _formatInvestmentPeriod(int periodMonths) {
    if (periodMonths % 12 == 0) {
      final int investmentYears = periodMonths ~/ 12;
      return '$investmentYears년';
    }

    return '$periodMonths개월';
  }

  @override
  Widget build(BuildContext context) {
    final portfolioState = ref.watch(getPortfolioControllerProvider);

    ref.listen(getPortfolioControllerProvider, (previousState, nextState) {
      final bool hasNewError =
          previousState?.error != nextState.error && nextState.error != null;

      if (hasNewError) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(nextState.error!)));
      }
    });

    final List<Portfolio> portfolioList = portfolioState.portfolios;
    final bool isInitialLoading =
        portfolioState.isLoading && portfolioList.isEmpty;
    final bool isEmptyState =
        !portfolioState.isLoading &&
        portfolioState.error == null &&
        portfolioList.isEmpty;

    return Scaffold(
      backgroundColor: AppColors.natural.backgroundColors.primary,
      appBar: AppBar(
        backgroundColor: AppColors.natural.backgroundColors.primary,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: SizedBox(
            width: 40,
            height: 40,
            child: GestureDetector(
              onTap: () {
                context.go('/home');
              },
              child: Center(
                child: Image.asset(
                  'icons/arrow_left.png',
                  width: 20,
                  height: 20,
                ),
              ),
            ),
          ),
        ),
        centerTitle: true,
        title: Text(
          '포트폴리오',
          style: AppTypography.heading.h4.copyWith(
            color: AppColors.natural.textColors.primary,
          ),
        ),
        actions: [
          if (!widget.isSelectionMode)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: GestureDetector(
                onTap: () {
                  context.push('/simulation');
                },
                child: Text(
                  '만들기',
                  style: AppTypography.action.m.copyWith(
                    color: AppColors.natural.textColors.secondary,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Builder(
          builder: (context) {
            if (isInitialLoading) {
              return Center(
                child: CircularProgressIndicator(
                  color: AppColors.highlight.light,
                ),
              );
            }

            if (isEmptyState) {
              return Center(
                child: Text(
                  '조회된 포트폴리오가 없습니다.',
                  style: AppTypography.body.s.copyWith(
                    color: AppColors.natural.textColors.secondary,
                  ),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              itemCount: portfolioList.length,
              itemBuilder: (context, index) {
                final Portfolio portfolioItem = portfolioList[index];
                final String formattedInvestmentPeriod =
                    _formatInvestmentPeriod(portfolioItem.periodMonths);
                final String portfolioDescription =
                    '자산 ${portfolioItem.assetCount}개 · 투자 기간 $formattedInvestmentPeriod';

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildPortfolioCard(
                    title: portfolioItem.name,
                    subtitle: portfolioDescription,
                    onTap: () {
                      if (widget.isSelectionMode) {
                        Navigator.of(context).pop(portfolioItem);
                      } else {
                        context.push(
                          '/portfolio/get/detail/${portfolioItem.id}',
                        );
                      }
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildPortfolioCard({
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    const double minHeight = 69;
    const double radius = 16;
    const double horizontalPadding = 16;
    const double verticalPadding = 14;
    const double titleSubtitleGap = 4;
    const double chevronSize = 12;

    final child = Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: minHeight),
      padding: const EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      decoration: BoxDecoration(
        color: AppColors.highlight.dark,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.heading.h4.copyWith(
                    color: AppColors.natural.textColors.primary,
                  ),
                ),
                const SizedBox(height: titleSubtitleGap),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.body.s.copyWith(
                    color: AppColors.natural.textColors.secondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Image.asset(
            'assets/icons/arrow_right.png',
            width: chevronSize,
            height: chevronSize,
            color: AppColors.natural.textColors.secondary,
          ),
        ],
      ),
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        splashColor: AppColors.natural.textColors.primary.withValues(
          alpha: 0.05,
        ),
        highlightColor: Colors.transparent,
        child: child,
      ),
    );
  }
}
