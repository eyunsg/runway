import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:runway/core/providers.dart';
import 'package:runway/domain/entity/portfolio.dart';
import 'package:runway/features/post/model/post.dart';

class HomeTempScreen extends ConsumerStatefulWidget {
  const HomeTempScreen({super.key});

  @override
  ConsumerState<HomeTempScreen> createState() => _HomeTempScreenState();
}

class _HomeTempScreenState extends ConsumerState<HomeTempScreen> {
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

      ref.read(getPostControllerProvider.notifier).fetchPost();
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
    final postState = ref.watch(getPostControllerProvider);

    final Portfolio? portfolioItem = portfolioState.portfolio;

    final bool isInitialLoading =
        portfolioState.isLoading && portfolioItem == null;

    final bool isEmptyState =
        !portfolioState.isLoading &&
        portfolioState.error == null &&
        portfolioItem == null;

    if (isInitialLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (isEmptyState) {
      return const Scaffold(body: Center(child: Text('조회된 포트폴리오가 없습니다.')));
    }

    if (portfolioItem == null) {
      return const SizedBox.shrink();
    }

    final String formattedInvestmentPeriod = _formatInvestmentPeriod(
      portfolioItem.periodMonths,
    );

    final String portfolioDescription =
        '자산 ${portfolioItem.assetCount}개 · 투자 기간 $formattedInvestmentPeriod';

    final List<Post> posts = postState.posts.cast<Post>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dev Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              context.push('/profile');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  title: Text(portfolioItem.name),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(portfolioDescription),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    context.push('/portfolio/get/detail/${portfolioItem.id}');
                  },
                ),
              ),

              const SizedBox(height: 16),

              FilledButton(
                onPressed: () {
                  context.push('/simulation');
                },
                child: const Text('새 포트폴리오 구성하기'),
              ),

              const SizedBox(height: 12),

              OutlinedButton(
                onPressed: () {
                  context.push('/portfolio/get');
                },
                child: const Text('내 전략 보기'),
              ),

              const SizedBox(height: 12),

              const Divider(height: 1),

              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '커뮤니티',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  IconButton(
                    onPressed: () {
                      context.push('/post/get');
                    },
                    icon: const Icon(Icons.chevron_right),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              if (postState.isLoading)
                const Center(child: CircularProgressIndicator())
              else if (postState.error != null)
                Center(
                  child: Text(
                    postState.error!,
                    style: const TextStyle(color: Colors.grey),
                  ),
                )
              else if (posts.isEmpty)
                const Center(child: Text('게시물이 없습니다.'))
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: posts.length > 3 ? 3 : posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    return _buildPostItem(post: post);
                  },
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPostItem({required Post post}) {
    final hasPortfolio = post.portfolioName.trim().isNotEmpty;

    return InkWell(
      onTap: () {
        context.push('/post/get/detail/${post.postId}');
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(child: Icon(Icons.person)),
                const SizedBox(width: 12),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.authorDisplayName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),

                    Text(
                      _formatDate(post.createdAt),
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),

            Text(post.content),

            if (hasPortfolio) ...[
              const SizedBox(height: 12),
              _buildPortfolioCard(post: post),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPortfolioCard({required Post post}) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.blueGrey.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                post.portfolioName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 4),

              Text(
                '자산 ${post.assetCount}개 · 투자 기간 ${_formatInvestmentPeriodText(post.investmentPeriodMonths)}',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),

          const Icon(Icons.arrow_forward_ios, size: 16),
        ],
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
