import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:runway/core/providers.dart';
import 'package:runway/features/post/model/post.dart';

class GetMyPostTempScreen extends ConsumerStatefulWidget {
  const GetMyPostTempScreen({super.key});

  @override
  ConsumerState<GetMyPostTempScreen> createState() =>
      _GetMyPostTempScreenState();
}

class _GetMyPostTempScreenState extends ConsumerState<GetMyPostTempScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(getMyPostControllerProvider.notifier).fetchMyPost();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(getMyPostControllerProvider);

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
        title: const Text('내 게시물'),
        centerTitle: true,
      ),
      body: _buildBody(state),
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
                  ref.read(getMyPostControllerProvider.notifier).fetchMyPost();
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.authorDisplayName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        _formatDate(post.createdAt),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    _showPostActionDialog(post);
                  },
                  icon: const Icon(Icons.more_horiz),
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

  Future<void> _showPostActionDialog(Post post) async {
    final action = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('게시물 작업을 선택해주세요.', textAlign: TextAlign.center),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop('edit');
              },
              child: const Text('수정'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop('delete');
              },
              child: const Text('삭제'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop('cancel');
              },
              child: const Text('취소'),
            ),
          ],
        );
      },
    );

    if (action == 'edit') {
      // TODO: 게시물 수정 페이지로 이동
      return;
    }

    if (action == 'delete') {
      _showDeleteDialog(post);
    }
  }

  Future<void> _showDeleteDialog(Post post) async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('게시물을 삭제할까요?', textAlign: TextAlign.center),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // TODO: 게시물 삭제 controller 연결
              },
              child: const Text('삭제'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('취소'),
            ),
          ],
        );
      },
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
