import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:runway/core/providers.dart';
import 'package:runway/features/post/model/post.dart';
import 'package:runway/features/post/types/create_comment_state.dart';

class GetPostDetailTempScreen extends ConsumerStatefulWidget {
  const GetPostDetailTempScreen({super.key, required this.postId});

  final String postId;

  @override
  ConsumerState<GetPostDetailTempScreen> createState() =>
      _GetPostDetailTempScreenState();
}

class _GetPostDetailTempScreenState
    extends ConsumerState<GetPostDetailTempScreen> {
  final TextEditingController _commentController = TextEditingController();
  bool _isSyncingCommentFromState = false;

  final List<_MockComment> _mockComments = const [
    _MockComment(
      authorDisplayName: 'displayName',
      createdAt: '2026.05.08',
      content: '좋은 게시물이네요.',
    ),
    _MockComment(
      authorDisplayName: 'displayName',
      createdAt: '2026.05.08',
      content: '저도 비슷하게 생각했어요.',
    ),
    _MockComment(
      authorDisplayName: 'displayName',
      createdAt: '2026.05.08',
      content: '댓글 API 연동 전 임시 mock 데이터입니다.',
    ),
  ];

  @override
  void initState() {
    super.initState();

    _commentController.addListener(() {
      if (_isSyncingCommentFromState) return;

      ref
          .read(createCommentControllerProvider.notifier)
          .updateContent(_commentController.text);
    });

    Future.microtask(() {
      ref
          .read(getPostDetailControllerProvider.notifier)
          .fetchPostDetail(widget.postId);
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
    final createCommentController = ref.read(
      createCommentControllerProvider.notifier,
    );

    ref.listen(createCommentControllerProvider, (previousState, nextState) {
      if (_commentController.text != nextState.content) {
        _isSyncingCommentFromState = true;
        _commentController.value = TextEditingValue(
          text: nextState.content,
          selection: TextSelection.collapsed(offset: nextState.content.length),
        );
        _isSyncingCommentFromState = false;
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('댓글이 등록되었습니다.')));

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          createCommentController.clearSuccess();
        });
      }
    });

    final double keyboardInset = MediaQuery.of(context).viewInsets.bottom;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              FocusManager.instance.primaryFocus?.unfocus();
              if (context.canPop()) {
                context.pop();
                return;
              }
              Navigator.of(context).maybePop();
            },
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          ),
        ),
        body: Column(
          children: [
            Expanded(child: _buildBody(state)),
            AnimatedPadding(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              padding: EdgeInsets.only(bottom: keyboardInset),
              child: _buildBottomInputArea(createCommentState),
            ),
          ],
        ),
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
        _buildCommentSection(),
      ],
    );
  }

  Widget _buildPostItem({required Post post}) {
    final bool hasPortfolioCard = post.portfolioName.trim().isNotEmpty;
    final String portfolioSnapshotId = (post.portfolioSnapshotId ?? '').trim();
    final bool isPortfolioCardTappable = portfolioSnapshotId.isNotEmpty;

    return Padding(
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
          if (hasPortfolioCard) ...[
            const SizedBox(height: 12),
            _buildPortfolioCard(
              post: post,
              isEnabled: isPortfolioCardTappable,
              onTap: isPortfolioCardTappable
                  ? () {
                      context.push(
                        '/portfolio/get/detail/snapshot/$portfolioSnapshotId',
                      );
                    }
                  : null,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPortfolioCard({
    required Post post,
    required bool isEnabled,
    required VoidCallback? onTap,
  }) {
    final BorderRadius borderRadius = BorderRadius.circular(12);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        child: Ink(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.blueGrey.withOpacity(isEnabled ? 0.2 : 0.12),
            borderRadius: borderRadius,
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
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: isEnabled ? null : Colors.black26,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCommentSection() {
    if (_mockComments.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24.0),
        child: Center(child: Text('댓글이 없습니다.')),
      );
    }

    return ListView.builder(
      itemCount: _mockComments.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final comment = _mockComments[index];
        return _buildCommentItem(comment: comment);
      },
    );
  }

  Widget _buildCommentItem({required _MockComment comment}) {
    return Padding(
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
                      comment.authorDisplayName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      comment.createdAt,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  _showDeleteCommentDialog();
                },
                icon: const Icon(Icons.more_horiz),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(left: 52.0),
            child: Text(comment.content),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteCommentDialog() async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('댓글을 삭제할까요?', textAlign: TextAlign.center),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
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

  Widget _buildBottomInputArea(CreateCommentState createCommentState) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey, width: 0.5)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const CircleAvatar(radius: 18, child: Icon(Icons.person, size: 20)),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: Colors.blueGrey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextField(
                  controller: _commentController,
                  minLines: 1,
                  maxLines: 5,

                  enabled: !createCommentState.isSubmitting,
                  decoration: const InputDecoration(
                    hintText: '댓글로 의견을 남겨보세요',
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: createCommentState.isSubmitting
                  ? null
                  : () async {
                      FocusManager.instance.primaryFocus?.unfocus();
                      await ref
                          .read(createCommentControllerProvider.notifier)
                          .submitComment(postId: widget.postId);
                    },
              icon: createCommentState.isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send),
            ),
          ],
        ),
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

class _MockComment {
  final String authorDisplayName;
  final String createdAt;
  final String content;

  const _MockComment({
    required this.authorDisplayName,
    required this.createdAt,
    required this.content,
  });
}
