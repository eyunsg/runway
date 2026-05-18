import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:runway/core/providers.dart';
import 'package:runway/domain/entity/portfolio.dart';

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
      body: Padding(
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
          ],
        ),
      ),
    );
  }
}
