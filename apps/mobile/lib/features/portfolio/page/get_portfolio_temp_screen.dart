import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:runway/core/providers.dart';
import 'package:runway/domain/entity/portfolio.dart';
import 'package:go_router/go_router.dart';

class GetPortfolioTempScreen extends ConsumerStatefulWidget {
  const GetPortfolioTempScreen({super.key, this.isSelectionMode = false});

  final bool isSelectionMode;

  @override
  ConsumerState<GetPortfolioTempScreen> createState() =>
      _GetPortfolioTempScreenState();
}

class _GetPortfolioTempScreenState
    extends ConsumerState<GetPortfolioTempScreen> {
  // final ScrollController _scrollController = ScrollController();
  bool _hasRequestedInitialData = false;

  // double? _pendingRestoreOffset;

  @override
  void initState() {
    super.initState();
    // _scrollController.addListener(_handleScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_hasRequestedInitialData) return;
      _hasRequestedInitialData = true;

      ref.read(getPortfolioControllerProvider.notifier).fetchPortfolio();
    });
  }

  @override
  void dispose() {
    // _scrollController
    //   ..removeListener(_handleScroll)
    //   ..dispose();
    super.dispose();
  }

  //  pagination용 하단 도달 감지, 추가 조회 로직
  // void _handleScroll() {
  //   if (!_scrollController.hasClients) return;

  //   final double currentScrollOffset = _scrollController.position.pixels;
  //   final double maxScrollOffset = _scrollController.position.maxScrollExtent;

  //   final bool isNearBottom = currentScrollOffset >= maxScrollOffset - 1;

  //   if (!isNearBottom) return;

  //   _pendingRestoreOffset = maxScrollOffset;

  //   ref.read(getPortfolioControllerProvider.notifier).fetchMore();
  // }

  String _formatInvestmentPeriod(int periodMonths) {
    if (periodMonths % 12 == 0) {
      final int investmentYears = periodMonths ~/ 12;
      return '$investmentYears년';
    }

    return '$periodMonths개월';
  }

  @override
  Widget build(BuildContext context) {
    final portfolioState = ref.watch(getPortfolioControllerProvider);

    ref.listen(getPortfolioControllerProvider, (previousState, nextState) {
      final bool hasNewError =
          previousState?.error != nextState.error && nextState.error != null;

      if (hasNewError) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(nextState.error!)));
      }

      // final bool hasAppendedItems =
      //     previousState != null &&
      //     nextState.portfolios.length > previousState.portfolios.length &&
      //     _pendingRestoreOffset != null &&
      //     !nextState.isLoading;

      // if (!hasAppendedItems) return;

      // WidgetsBinding.instance.addPostFrameCallback((_) {
      //   if (!_scrollController.hasClients || _pendingRestoreOffset == null) {
      //     return;
      //   }

      //   _scrollController.jumpTo(_pendingRestoreOffset!);
      //   _pendingRestoreOffset = null;
      // });
    });

    final List<Portfolio> portfolioList = portfolioState.portfolios;
    final bool isInitialLoading =
        portfolioState.isLoading && portfolioList.isEmpty;
    // final bool isBottomLoading =
    //     portfolioState.isLoading && portfolioList.isNotEmpty;
    final bool isEmptyState =
        !portfolioState.isLoading &&
        portfolioState.error == null &&
        portfolioList.isEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('포트폴리오'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          if (!widget.isSelectionMode)
            TextButton(
              onPressed: () {
                // TODO: create portfolio 화면 route 연결 후 수정 가능
              },
              child: const Text('만들기'),
            ),
        ],
      ),
      body: SafeArea(
        child: Builder(
          builder: (context) {
            if (isInitialLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (isEmptyState) {
              return const Center(child: Text('조회된 포트폴리오가 없습니다.'));
            }

            return ListView.builder(
              // controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              itemCount: portfolioList.length,
              itemBuilder: (context, index) {
                // if (index == portfolioList.length) {
                //   return const Padding(
                //     padding: EdgeInsets.symmetric(vertical: 16),
                //     child: Center(child: CircularProgressIndicator()),
                //   );
                // }

                final Portfolio portfolioItem = portfolioList[index];
                final String formattedInvestmentPeriod =
                    _formatInvestmentPeriod(portfolioItem.periodMonths);
                final String portfolioDescription =
                    '자산 ${portfolioItem.assetCount}개 · 투자 기간 $formattedInvestmentPeriod';

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Card(
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
                        if (widget.isSelectionMode) {
                          Navigator.of(context).pop<Portfolio>(portfolioItem);
                        } else {
                          context.go(
                            '/portfolio/get/detail/${portfolioItem.id}',
                          );
                        }
                      },
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
