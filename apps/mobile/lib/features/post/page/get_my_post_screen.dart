import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:runway/core/providers.dart';
import 'package:runway/core/theme/app_colors.dart';
import 'package:runway/core/theme/app_typography.dart';
import 'package:runway/features/post/model/post.dart';
import 'package:runway/shared/widgets/content_card.dart';
import 'package:runway/shared/widgets/dialog.dart';

class GetMyPostScreen extends ConsumerStatefulWidget {
  const GetMyPostScreen({super.key});

  @override
  ConsumerState<GetMyPostScreen> createState() => _GetMyPostScreenState();
}

class _GetMyPostScreenState extends ConsumerState<GetMyPostScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(getMyPostControllerProvider.notifier).fetchMyPost();
    });

    ref.listenManual(deletePostControllerProvider, (previous, next) {
      if (next.isSuccess && mounted) {
        ref.read(getMyPostControllerProvider.notifier).fetchMyPost();
      }

      if (next.error != null && mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.error!)));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(getMyPostControllerProvider);

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
          '내 게시물',
          style: AppTypography.heading.h4.copyWith(
            color: AppColors.natural.textColors.primary,
          ),
        ),
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

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: AppContentCard(
        displayName: post.authorDisplayName,
        dateText: _formatDate(post.createdAt),
        content: post.content,
        showMoreAction: true,
        onMoreTap: () {
          _showPostActionDialog(post);
        },
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

  Future<void> _showPostActionDialog(Post post) async {
    final action = await showDialog<String>(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: AppDialog(
            title: '이 게시물을 어떻게 할까요?',
            secondaryButtonText: '삭제',
            primaryButtonText: '수정',
            onSecondaryPressed: () {
              Navigator.of(context).pop('delete');
            },
            onPrimaryPressed: () {
              Navigator.of(context).pop('edit');
            },
          ),
        );
      },
    );

    if (action == 'edit') {
      if (!mounted) return;
      context.push('/post/update', extra: post);
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
        return Dialog(
          backgroundColor: Colors.transparent,
          child: AppDialog(
            title: '게시물을 삭제할까요?',
            description: '삭제한 게시물은 복구할 수 없습니다.',
            secondaryButtonText: '취소',
            primaryButtonText: '삭제',
            onSecondaryPressed: () {
              Navigator.of(context).pop();
            },
            onPrimaryPressed: () async {
              await ref
                  .read(deletePostControllerProvider.notifier)
                  .deletePost(post.postId);

              if (!context.mounted) return;

              Navigator.of(context).pop();
            },
          ),
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
