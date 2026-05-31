import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:runway/core/providers.dart';
import 'package:runway/core/theme/app_colors.dart';
import 'package:runway/core/theme/app_typography.dart';
import 'package:runway/features/post/controller/update_post_controller.dart';
import 'package:runway/features/post/model/post.dart';
import 'package:runway/shared/widgets/button.dart';

class UpdatePostScreen extends ConsumerStatefulWidget {
  const UpdatePostScreen({super.key, required this.post});

  final Post post;

  @override
  ConsumerState createState() => _UpdatePostScreenState();
}

class _UpdatePostScreenState extends ConsumerState<UpdatePostScreen> {
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

          context.pop();
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
              onTap: updatePostState.isSubmitting
                  ? null
                  : () async {
                      await updatePostController.submitUpdate();
                    },
              child: Center(
                child: updatePostState.isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        "수정하기",
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
          Container(height: 0.5, color: AppColors.natural.textColors.disabled),
          Padding(
            padding: const EdgeInsets.all(16),
            child: AppButton(
              text: "포트폴리오는 수정할 수 없어요",
              onPressed: () {},
              variant: ButtonVariant.disabled,
            ),
          ),
        ],
      ),
    );
  }
}
