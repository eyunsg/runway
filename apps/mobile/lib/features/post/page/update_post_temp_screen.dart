import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:runway/core/providers.dart';
import 'package:runway/domain/entity/portfolio.dart';
import 'package:runway/features/post/controller/update_post_controller.dart';
import 'package:runway/features/post/model/create_post_selected_portfolio.dart';
import 'package:runway/features/post/model/post.dart';

class UpdatePostTempScreen extends ConsumerStatefulWidget {
  const UpdatePostTempScreen({super.key, required this.post});

  final Post post;

  @override
  ConsumerState createState() => _UpdatePostTempScreenState();
}

class _UpdatePostTempScreenState extends ConsumerState<UpdatePostTempScreen> {
  late final TextEditingController _contentController;
  late final UpdatePostController _updatePostController;
  bool _isSyncingFromState = false;

  @override
  void initState() {
    super.initState();

    _updatePostController = ref.read(updatePostControllerProvider.notifier);

    _contentController = TextEditingController();

    Future.microtask(() {
      if (!mounted) return;

      _updatePostController.initialize(widget.post);

      final updatePostState = ref.read(updatePostControllerProvider);

      _isSyncingFromState = true;
      _contentController.text = updatePostState.content;
      _contentController.selection = TextSelection.collapsed(
        offset: updatePostState.content.length,
      );
      _isSyncingFromState = false;
    });

    _contentController.addListener(() {
      if (_isSyncingFromState) return;

      _updatePostController.updateContent(_contentController.text);
    });
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  String _formatInvestmentPeriod(int periodMonths) {
    if (periodMonths % 12 == 0) {
      final int investmentYears = periodMonths ~/ 12;
      return '$investmentYears년';
    }

    return '$periodMonths개월';
  }

  Future<void> _navigateToPortfolioSelection() async {
    final Portfolio? selectedPortfolio = await context.push(
      '/portfolio/get',
      extra: true,
    );

    if (selectedPortfolio == null) {
      return;
    }

    final CreatePostSelectedPortfolio updatePostSelectedPortfolio =
        CreatePostSelectedPortfolio(
          id: selectedPortfolio.id,
          name: selectedPortfolio.name,
          assetCount: selectedPortfolio.assetCount,
          periodMonths: selectedPortfolio.periodMonths,
        );

    ref
        .read(updatePostControllerProvider.notifier)
        .selectPortfolio(updatePostSelectedPortfolio);
  }

  Future<void> _showPortfolioEditDialog() async {
    final String? action = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('포트폴리오 설정'),
          content: const Text('포트폴리오를 변경하거나 삭제할 수 있어요.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop('delete');
              },
              child: const Text('삭제'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop('change');
              },
              child: const Text('변경'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('취소'),
            ),
          ],
        );
      },
    );

    if (!mounted) return;

    if (action == 'change') {
      await _navigateToPortfolioSelection();
      return;
    }

    if (action == 'delete') {
      ref.read(updatePostControllerProvider.notifier).clearSelectedPortfolio();
    }
  }

  @override
  Widget build(BuildContext context) {
    final updatePostState = ref.watch(updatePostControllerProvider);
    final updatePostController = ref.read(
      updatePostControllerProvider.notifier,
    );

    ref.listen(updatePostControllerProvider, (previousState, nextState) {
      if (_contentController.text != nextState.content) {
        _isSyncingFromState = true;
        _contentController.value = TextEditingValue(
          text: nextState.content,
          selection: TextSelection.collapsed(offset: nextState.content.length),
        );
        _isSyncingFromState = false;
      }

      final bool hasNewError =
          previousState?.error != nextState.error && nextState.error != null;

      if (hasNewError) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(nextState.error!)));

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          updatePostController.clearError();
        });
      }

      final bool shouldShowDeletedMessage =
          previousState?.shouldShowPortfolioDeletedMessage !=
              nextState.shouldShowPortfolioDeletedMessage &&
          nextState.shouldShowPortfolioDeletedMessage;

      if (shouldShowDeletedMessage) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('포트폴리오 태그가 삭제되었어요.')));

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          updatePostController.clearDeletedMessage();
        });
      }

      final bool hasNewSuccess =
          previousState?.isSuccess != nextState.isSuccess &&
          nextState.isSuccess;

      if (hasNewSuccess) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('게시글이 수정되었습니다.')));

        WidgetsBinding.instance.addPostFrameCallback((_) async {
          if (!mounted) return;

          updatePostController.clearSuccess();
          ref.read(updatePostControllerProvider.notifier).reset();

          context.go('/post/get/me');
        });
      }
    });

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            final didPop = await Navigator.of(context).maybePop();

            if (!didPop) return;

            WidgetsBinding.instance.addPostFrameCallback((_) {
              ref.read(updatePostControllerProvider.notifier).reset();
            });
          },
        ),
        actions: [
          TextButton(
            onPressed: updatePostState.isSubmitting
                ? null
                : () async {
                    await updatePostController.submitUpdate();
                  },
            child: updatePostState.isSubmitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('수정하기'),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: TextField(
              controller: _contentController,
              maxLines: null,
              autofocus: true,
              decoration: const InputDecoration(
                hintText:
                    '광고, 비난, 도배성 글을 남기면 영구적으로 활동이 제한될 수 있어요. 건강한 커뮤니티 문화를 함께 만들어가요.',
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(16),
              ),
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '포트폴리오는 수정할 수 없어요.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagButton() {
    return OutlinedButton(
      onPressed: _navigateToPortfolioSelection,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
      ),
      child: const Text('포트폴리오 태그'),
    );
  }

  Widget _buildPortfolioCard(CreatePostSelectedPortfolio selectedPortfolio) {
    final String formattedInvestmentPeriod = _formatInvestmentPeriod(
      selectedPortfolio.periodMonths,
    );

    final String portfolioDescription =
        '자산 ${selectedPortfolio.assetCount}개 · 투자 기간 $formattedInvestmentPeriod';

    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  selectedPortfolio.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(portfolioDescription),
              ],
            ),
          ),
        ),
        IconButton(
          onPressed: _showPortfolioEditDialog,
          icon: const Icon(Icons.edit_outlined),
        ),
      ],
    );
  }
}
