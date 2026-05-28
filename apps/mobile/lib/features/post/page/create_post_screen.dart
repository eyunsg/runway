import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:runway/core/providers.dart';
import 'package:runway/core/theme/app_colors.dart';
import 'package:runway/core/theme/app_typography.dart';
import 'package:runway/domain/entity/portfolio.dart';
import 'package:runway/features/post/model/create_post_selected_portfolio.dart';
import 'package:runway/features/post/controller/create_post_controller.dart';
import 'package:runway/shared/widgets/button.dart';

class CreatePostScreen extends ConsumerStatefulWidget {
  const CreatePostScreen({super.key});

  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends ConsumerState<CreatePostScreen> {
  late final TextEditingController _contentController;
  late final CreatePostController _createPostController;
  bool _isSyncingFromState = false;

  @override
  void initState() {
    super.initState();

    _createPostController = ref.read(createPostControllerProvider.notifier);

    final createPostState = ref.read(createPostControllerProvider);

    _contentController = TextEditingController(text: createPostState.content);

    _contentController.addListener(() {
      if (_isSyncingFromState) return;

      _createPostController.updateContent(_contentController.text);
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
    final Portfolio? selectedPortfolio = await context.push<Portfolio>(
      '/portfolio/get',
      extra: true,
    );

    if (selectedPortfolio == null) {
      return;
    }

    final CreatePostSelectedPortfolio createPostSelectedPortfolio =
        CreatePostSelectedPortfolio(
          id: selectedPortfolio.id,
          name: selectedPortfolio.name,
          assetCount: selectedPortfolio.assetCount,
          periodMonths: selectedPortfolio.periodMonths,
        );

    ref
        .read(createPostControllerProvider.notifier)
        .selectPortfolio(createPostSelectedPortfolio);
  }

  @override
  Widget build(BuildContext context) {
    final createPostState = ref.watch(createPostControllerProvider);
    final createPostController = ref.read(
      createPostControllerProvider.notifier,
    );

    ref.listen(createPostControllerProvider, (previousState, nextState) {
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
          createPostController.clearError();
        });
      }

      final bool hasNewSuccess =
          previousState?.isSuccess != nextState.isSuccess &&
          nextState.isSuccess;

      if (hasNewSuccess) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('게시물이 등록되었습니다.')));

        WidgetsBinding.instance.addPostFrameCallback((_) async {
          if (!mounted) return;

          createPostController.clearSuccess();
          ref.read(createPostControllerProvider.notifier).reset();

          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
        });
      }
    });

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
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: createPostState.isSubmitting
                  ? null
                  : () async {
                      await createPostController.submitPost();
                    },
              child: Center(
                child: createPostState.isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        "남기기",
                        style: AppTypography.action.m.copyWith(
                          color: AppColors.natural.textColors.secondary,
                        ),
                      ),
              ),
            ),
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
              style: AppTypography.body.l.copyWith(
                color: AppColors.natural.textColors.primary,
              ),
              decoration: InputDecoration(
                hintText:
                    '광고, 비난, 도배성 글을 남기면 영구적으로 활동이 제한될 수 있어요. 건강한 커뮤니티 문화를 함께 만들어가요.',
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(24),

                hintStyle: AppTypography.body.l.copyWith(
                  color: AppColors.natural.textColors.secondary,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(height: 0.5, color: AppColors.natural.textColors.disabled),

          Padding(
            padding: const EdgeInsets.all(24.0),
            child: createPostState.selectedPortfolio != null
                ? _buildPortfolioCard(createPostState.selectedPortfolio!)
                : AppButton(
                    text: '포트폴리오 태그',
                    onPressed: _navigateToPortfolioSelection,
                    variant: ButtonVariant.secondary,
                  ),
          ),
        ],
      ),
    );
  }

  void _deleteSelectedPortfolio() {
    ref.read(createPostControllerProvider.notifier).clearSelectedPortfolio();
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
          child: GestureDetector(
            onTap: _navigateToPortfolioSelection,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.highlight.dark,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.natural.textColors.disabled.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    selectedPortfolio.name,
                    style: AppTypography.heading.h4.copyWith(
                      color: AppColors.natural.textColors.primary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    portfolioDescription,
                    style: AppTypography.body.s.copyWith(
                      color: AppColors.natural.textColors.secondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        // 👇 우측 동그란 버튼은 이제 바로 '삭제' 액션을 실행하도록 변경
        GestureDetector(
          onTap: _deleteSelectedPortfolio,
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.natural.textColors.disabled,
            ),
            child: Center(
              child: Image.asset(
                'icons/trash.png',
                width: 15,
                height: 15,
                color: AppColors.natural.textColors.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
