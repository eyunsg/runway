import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:runway/core/providers.dart';
import 'package:runway/core/theme/app_colors.dart';
import 'package:runway/core/theme/app_typography.dart';
import 'package:runway/features/post/model/post.dart';
import 'package:runway/shared/widgets/content_card.dart';
import 'package:runway/shared/widgets/post_composer_trigger.dart';

class GetPostScreen extends ConsumerStatefulWidget {
  const GetPostScreen({super.key});

  @override
  ConsumerState<GetPostScreen> createState() => _GetPostScreenState();
}

class _GetPostScreenState extends ConsumerState<GetPostScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(getPostControllerProvider.notifier).fetchPost();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(getPostControllerProvider);

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
                context.pop();
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
          '커뮤니티',
          style: AppTypography.heading.h4.copyWith(
            color: AppColors.natural.textColors.primary,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () {
                context.go('/post/get/me');
              },
              child: Text(
                "내 게시물",
                style: AppTypography.action.m.copyWith(
                  color: AppColors.natural.textColors.secondary,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(children: [Expanded(child: _buildBody(state))]),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(height: 0.5, color: AppColors.natural.textColors.disabled),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: PostComposerTrigger(
              onTap: () => context.push('/post/create'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(dynamic state) {
    if (state.isLoading) {
      return Center(
        child: CircularProgressIndicator(color: AppColors.highlight.light),
      );
    }

    if (state.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('게시물을 불러오지 못했습니다.'),
              const SizedBox(height: 8),
              Text(
                state.error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.read(getPostControllerProvider.notifier).fetchPost();
                },
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
      );
    }

    final posts = state.posts.cast<Post>();

    if (posts.isEmpty) {
      return const Center(child: Text('게시물이 없습니다.'));
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        return _buildPostItem(post: post);
      },
      separatorBuilder: (context, index) =>
          Divider(color: AppColors.natural.textColors.disabled, thickness: 0.5),
    );
  }

  Widget _buildPostItem({required Post post}) {
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
                    '자산 ${post.assetCount}개 · 투자 기간 ${_formatInvestmentPeriod(post.investmentPeriodMonths)}',
              )
            : null,
        onPortfolioTap: hasPortfolio
            ? () {
                context.push('/post/get/detail/${post.postId}');
              }
            : null,
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    final year = dateTime.year;
    final month = dateTime.month.toString().padLeft(2, '0');
    final day = dateTime.day.toString().padLeft(2, '0');
    return '$year.$month.$day';
  }

  String _formatInvestmentPeriod(int months) {
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
