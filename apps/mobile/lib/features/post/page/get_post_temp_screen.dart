import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:runway/core/providers.dart';
import 'package:runway/features/post/model/post.dart';

class GetPostTempScreen extends ConsumerStatefulWidget {
  const GetPostTempScreen({super.key});

  @override
  ConsumerState<GetPostTempScreen> createState() => _GetPostTempScreenState();
}

class _GetPostTempScreenState extends ConsumerState<GetPostTempScreen> {
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
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            if (context.canPop()) {
              context.pop();
              return;
            }
            Navigator.of(context).maybePop();
          },
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
        ),
        title: const Text('커뮤니티'),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              context.push('/post/get/me');
            },
            child: const Text('내 게시물'),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: _buildBody(state)),
          _buildBottomInputArea(),
        ],
      ),
    );
  }

  Widget _buildBody(dynamic state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
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
      separatorBuilder: (context, index) => const Divider(height: 1),
    );
  }

  // 게시글 기본 아이템 구성
  Widget _buildPostItem({required Post post}) {
    final hasPortfolio = post.portfolioName.trim().isNotEmpty;

    return InkWell(
      onTap: () {
        // TODO: get post detail screen 작업 시 이동 코드 작성
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

  // 중앙 포트폴리오 카드 위젯
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
                '자산 ${post.assetCount}개 · 투자 기간 ${_formatInvestmentPeriod(post.investmentPeriodMonths)}',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
          const Icon(Icons.arrow_forward_ios, size: 16),
        ],
      ),
    );
  }

  // 하단 입력 창 영역
  Widget _buildBottomInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey, width: 0.5)),
      ),
      child: Row(
        children: [
          const CircleAvatar(radius: 18, child: Icon(Icons.person, size: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                context.push('/post/create');
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.blueGrey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '무슨 생각을 하고 있나요?',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ),
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
