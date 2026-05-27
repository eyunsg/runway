import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:runway/core/providers.dart';
import 'package:runway/core/theme/app_colors.dart';
import 'package:runway/features/comment/model/comment.dart';
import 'package:runway/features/post/model/post.dart';
import 'package:runway/features/post/types/create_comment_state.dart';
import 'package:runway/features/comment/types/delete_comment_state.dart';
import 'package:runway/shared/widgets/avatar.dart';
import 'package:runway/shared/widgets/comment_input.dart';
import 'package:runway/shared/widgets/content_card.dart';
import 'package:runway/shared/widgets/dialog.dart';

class GetPostDetailScreen extends ConsumerStatefulWidget {
  const GetPostDetailScreen({super.key, required this.postId});

  final String postId;

  @override
  ConsumerState<GetPostDetailScreen> createState() =>
      _GetPostDetailScreenState();
}

class _GetPostDetailScreenState extends ConsumerState<GetPostDetailScreen> {
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _commentController.addListener(() {
      ref
          .read(createCommentControllerProvider.notifier)
          .updateContent(_commentController.text);
    });

    Future.microtask(() {
      ref
          .read(getPostDetailControllerProvider.notifier)
          .fetchPostDetail(widget.postId);
      ref
          .read(getCommentsControllerProvider.notifier)
          .fetchComments(widget.postId);
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(getPostDetailControllerProvider);
    final createCommentState = ref.watch(createCommentControllerProvider);
    final deleteCommentState = ref.watch(deleteCommentControllerProvider);
    final createCommentController = ref.read(
      createCommentControllerProvider.notifier,
    );
    final deleteCommentController = ref.read(
      deleteCommentControllerProvider.notifier,
    );

    ref.listen<CreateCommentState>(createCommentControllerProvider, (
      previousState,
      nextState,
    ) {
      if (_commentController.text != nextState.content) {
        _commentController.value = TextEditingValue(
          text: nextState.content,
          selection: TextSelection.collapsed(offset: nextState.content.length),
        );
      }

      final bool hasNewError =
          previousState?.error != nextState.error && nextState.error != null;

      if (hasNewError) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(nextState.error!)));

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          createCommentController.clearError();
        });
      }

      final bool hasNewSuccess =
          previousState?.isSuccess != nextState.isSuccess &&
          nextState.isSuccess;

      if (hasNewSuccess) {
        ref
            .read(getCommentsControllerProvider.notifier)
            .fetchComments(widget.postId);

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          createCommentController.clearSuccess();
        });
      }
    });

    ref.listen<DeleteCommentState>(deleteCommentControllerProvider, (
      previousState,
      nextState,
    ) {
      final bool hasNewError =
          previousState?.error != nextState.error && nextState.error != null;

      if (hasNewError) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(nextState.error!)));

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          deleteCommentController.clearError();
        });
      }

      final bool hasNewSuccess =
          previousState?.isSuccess != nextState.isSuccess &&
          nextState.isSuccess;

      if (hasNewSuccess) {
        ref
            .read(getCommentsControllerProvider.notifier)
            .fetchComments(widget.postId);

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          deleteCommentController.clearSuccess();
        });
      }
    });

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        backgroundColor: AppColors.natural.backgroundColors.primary,
        appBar: AppBar(
          backgroundColor: AppColors.natural.backgroundColors.primary,
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.only(left: 16),
            child: GestureDetector(
              onTap: () {
                context.pop();
              },
              child: SizedBox(
                width: 40,
                height: 40,
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
        ),
        body: Column(
          children: [Expanded(child: _buildBody(state, deleteCommentState))],
        ),
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CommentInputWidget(
              controller: _commentController,
              isSubmitting: createCommentState.isSubmitting,
              enabled: !createCommentState.isSubmitting,
              onSubmit: () async {
                FocusManager.instance.primaryFocus?.unfocus();
                await ref
                    .read(createCommentControllerProvider.notifier)
                    .submitComment(postId: widget.postId);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(dynamic state, DeleteCommentState deleteCommentState) {
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
                  ref
                      .read(getPostDetailControllerProvider.notifier)
                      .fetchPostDetail(widget.postId);
                },
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
      );
    }

    final Post? post = state.post;

    if (post == null) {
      return const Center(child: Text('게시물이 없습니다.'));
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      children: [
        _buildPostItem(post: post),
        const Divider(height: 1),
        _buildCommentSection(deleteCommentState),
      ],
    );
  }

  Widget _buildPostItem({required Post post}) {
    final bool hasPortfolioCard = post.portfolioName.trim().isNotEmpty;
    final String portfolioSnapshotId = (post.portfolioSnapshotId ?? '').trim();
    final bool isPortfolioCardTappable = portfolioSnapshotId.isNotEmpty;

    ContentPortfolioData? portfolioData;
    if (hasPortfolioCard) {
      portfolioData = ContentPortfolioData(
        title: post.portfolioName,
        subtitle:
            '자산 ${post.assetCount}개 · 투자 기간 ${_formatInvestmentPeriod(post.investmentPeriodMonths)}',
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: AppContentCard(
        displayName: post.authorDisplayName,
        dateText: _formatDate(post.createdAt),
        content: post.content,
        showMoreAction: false,
        portfolioData: portfolioData,
        onPortfolioTap: isPortfolioCardTappable
            ? () {
                context.push(
                  '/portfolio/get/detail/snapshot/$portfolioSnapshotId',
                );
              }
            : null,
      ),
    );
  }

  Widget _buildCommentSection(DeleteCommentState deleteCommentState) {
    final commentState = ref.watch(getCommentsControllerProvider);

    if (commentState.isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (commentState.error != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24.0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('댓글을 불러오지 못했습니다.'),
              const SizedBox(height: 8),
              Text(
                commentState.error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref
                      .read(getCommentsControllerProvider.notifier)
                      .fetchComments(widget.postId);
                },
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
      );
    }

    final comments = commentState.comments;

    if (comments.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24.0),
        child: Center(child: Text('댓글이 없습니다.')),
      );
    }

    return ListView.builder(
      itemCount: comments.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final comment = comments[index];
        return _buildCommentItem(
          comment: comment,
          isDeleteSubmitting: deleteCommentState.isSubmitting,
        );
      },
    );
  }

  Widget _buildCommentItem({
    required Comment comment,
    required bool isDeleteSubmitting,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: AppContentCard(
        displayName: comment.authorDisplayName,
        dateText: _formatDate(comment.createdAt),
        content: comment.content,
        showMoreAction: true,
        onMoreTap: isDeleteSubmitting
            ? null
            : () {
                _showDeleteCommentDialog(comment.commentId);
              },
        avatarSize: IconSize.xs,
      ),
    );
  }

  Future<void> _showDeleteCommentDialog(String commentId) async {
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 40),
          child: AppDialog(
            title: '댓글을 삭제할까요?',
            secondaryButtonText: '삭제',
            primaryButtonText: '취소',
            onSecondaryPressed: () {
              Navigator.of(dialogContext).pop(true);
            },
            onPrimaryPressed: () {
              Navigator.of(dialogContext).pop(false);
            },
          ),
        );
      },
    );

    if (shouldDelete != true) return;
    if (!mounted) return;

    await ref
        .read(deleteCommentControllerProvider.notifier)
        .deleteComment(commentId: commentId);
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
