import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:runway/core/providers.dart';
import 'package:runway/core/theme/app_colors.dart';
import 'package:runway/core/theme/app_typography.dart';
import 'package:runway/domain/entity/portfolio.dart';
import 'package:runway/features/post/model/post.dart';
import 'package:runway/shared/widgets/button.dart';
import 'package:runway/shared/widgets/content_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _hasRequestedInitialData = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_hasRequestedInitialData) return;

      _hasRequestedInitialData = true;

      ref
          .read(getRecentPortfolioControllerProvider.notifier)
          .fetchRecentPortfolio();

      ref.read(getRecentPostControllerProvider.notifier).fetchRecentPost();
    });
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
    final portfolioState = ref.watch(getRecentPortfolioControllerProvider);
    final postState = ref.watch(getRecentPostControllerProvider);

    final Portfolio? portfolioItem = portfolioState.portfolio;

    String portfolioDescription = '';

    if (portfolioItem != null) {
      final formattedInvestmentPeriod = _formatInvestmentPeriod(
        portfolioItem.periodMonths,
      );

      portfolioDescription =
          '자산 ${portfolioItem.assetCount}개 · 투자 기간 $formattedInvestmentPeriod';
    }

    final List<Post> posts = postState.posts.cast<Post>();

    return Scaffold(
      backgroundColor: AppColors.natural.backgroundColors.primary,
      appBar: AppBar(
        backgroundColor: AppColors.natural.backgroundColors.primary,
        elevation: 0,
        leading: const Padding(padding: EdgeInsets.only(left: 16)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () {
                context.go("/profile");
              },
              child: Image.asset(
                'icons/hamburger_menu.png',
                width: 20,
                height: 20,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (portfolioState.isLoading)
                Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(minHeight: 69),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.highlight.dark,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.highlight.light,
                      ),
                    ),
                  ),
                )
              else if (portfolioItem != null)
                GestureDetector(
                  onTap: () {
                    context.push('/portfolio/get/detail/${portfolioItem.id}');
                  },
                  child: Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(minHeight: 69),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.highlight.dark,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                portfolioItem.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.heading.h4.copyWith(
                                  color: AppColors.natural.textColors.primary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                portfolioDescription,
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
                          width: 12,
                          height: 12,
                          color: AppColors.natural.textColors.secondary,
                        ),
                      ],
                    ),
                  ),
                ),

              if (portfolioState.isLoading) const SizedBox(height: 8),
              if (portfolioItem != null) const SizedBox(height: 8),

              AppButton(
                text: '새 포트폴리오 구성하기',
                variant: ButtonVariant.primary,
                onPressed: () {
                  context.push('/simulation');
                },
              ),

              const SizedBox(height: 8),

              AppButton(
                text: '내 전략 보기',
                variant: ButtonVariant.secondary,
                onPressed: () {
                  context.push('/portfolio/get');
                },
              ),

              const SizedBox(height: 8),

              Divider(
                color: AppColors.natural.textColors.disabled,
                thickness: 0.5,
              ),

              const SizedBox(height: 8),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '커뮤니티',
                    style: AppTypography.heading.h4.copyWith(
                      color: AppColors.natural.textColors.primary,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      context.push('/post/get');
                    },
                    icon: Image.asset(
                      'assets/icons/arrow_right.png',
                      width: 16,
                      height: 16,
                      color: AppColors.natural.textColors.secondary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              if (postState.isLoading)
                Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.highlight.light,
                    ),
                  ),
                )
              else if (postState.error != null)
                Center(
                  child: Text(
                    postState.error!,
                    style: const TextStyle(color: Colors.grey),
                  ),
                )
              else if (posts.isEmpty)
                Center(
                  child: Text(
                    '게시물이 없습니다.',
                    style: AppTypography.body.l.copyWith(
                      color: AppColors.natural.textColors.secondary,
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: math.min(posts.length, 3),
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    return _buildPostItem(context, post: post);
                  },
                  separatorBuilder: (context, index) => Divider(
                    color: AppColors.natural.textColors.disabled,
                    thickness: 0.5,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPostItem(BuildContext context, {required Post post}) {
    final hasPortfolio = post.portfolioName.trim().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: AppContentCard(
        displayName: post.authorDisplayName,
        dateText: _formatDate(post.createdAt),
        content: post.content,
        onTap: () {
          context.push('/post/get/detail/${post.postId}');
        },
        portfolioData: hasPortfolio
            ? ContentPortfolioData(
                title: post.portfolioName,
                subtitle:
                    '자산 ${post.assetCount}개 · 투자 기간 ${_formatInvestmentPeriodText(post.investmentPeriodMonths)}',
              )
            : null,
        onPortfolioTap: () {
          context.push('/post/get/detail/${post.postId}');
        },
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    final year = dateTime.year;
    final month = dateTime.month.toString().padLeft(2, '0');
    final day = dateTime.day.toString().padLeft(2, '0');

    return '$year.$month.$day';
  }

  String _formatInvestmentPeriodText(int months) {
    final years = months ~/ 12;
    final remainMonths = months % 12;

    if (years > 0 && remainMonths > 0) {
      return '$years년 $remainMonths개월';
    }

    if (years > 0) {
      return '$years년';
    }

    return '$remainMonths개월';
  }
}
