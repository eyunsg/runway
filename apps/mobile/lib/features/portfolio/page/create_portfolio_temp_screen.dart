import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:runway/core/providers.dart';

class CreatePortfolioTempScreen extends ConsumerStatefulWidget {
  const CreatePortfolioTempScreen({super.key});

  @override
  ConsumerState<CreatePortfolioTempScreen> createState() =>
      _CreatePortfolioTempScreenState();
}

class _CreatePortfolioTempScreenState
    extends ConsumerState<CreatePortfolioTempScreen> {
  @override
  Widget build(BuildContext context) {
    final portfolioState = ref.watch(createPortfolioControllerProvider);

    ref.listen(createPortfolioControllerProvider, (previous, next) {
      if (next.error != null && next.error!.isNotEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.error!)));
      }

      if (next.isSuccess) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('포트폴리오 생성이 완료되었습니다.')));
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        actions: [
          TextButton(
            onPressed: () {
              // TODO: repository 응답 연결 후 추가하기 액션 연결
            },
            child: const Text('추가하기'),
          ),
        ],
      ),
      body: SafeArea(
        child: portfolioState.isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: const [
                    _ResultPlaceholderCard(),
                    SizedBox(height: 16),

                    _GoalPlaceholderCard(),
                    SizedBox(height: 24),

                    _CenteredSectionTitle(title: '평가금액'),
                    SizedBox(height: 8),

                    _FigureSliderCard(
                      description: '80% 확률로 이 범위 안의 평가금액 달성됩니다.',
                    ),
                    SizedBox(height: 24),

                    _CenteredSectionTitle(title: '배당금액'),
                    SizedBox(height: 8),

                    _FigureSliderCard(
                      description: '80% 확률로 이 범위 안의 평가금액 달성됩니다.',
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _ResultPlaceholderCard extends StatelessWidget {
  const _ResultPlaceholderCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          children: const [
            Text('n년 후 예상 결과'),
            SizedBox(height: 8),
            Text(
              '데이터 준비 중',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('월 배당금: -'),

            SizedBox(height: 4),
            Text('[중위값 기준]'),
          ],
        ),
      ),
    );
  }
}

class _GoalPlaceholderCard extends StatelessWidget {
  const _GoalPlaceholderCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          children: [
            const Text('목표 분석', textAlign: TextAlign.center),
            const SizedBox(height: 16),

            Row(
              children: const [
                Expanded(
                  child: _GoalSummaryItem(
                    topText: '자산 ₩000억까지',
                    bottomText: 'n년',
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _GoalSummaryItem(
                    topText: '배당 ₩000만까지',
                    bottomText: 'n년',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _GoalSummaryItem extends StatelessWidget {
  const _GoalSummaryItem({required this.topText, required this.bottomText});

  final String topText;
  final String bottomText;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(topText, textAlign: TextAlign.center),
        SizedBox(height: 8),
        Text(
          bottomText,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class _CenteredSectionTitle extends StatelessWidget {
  const _CenteredSectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }
}

class _FigureSliderCard extends StatelessWidget {
  const _FigureSliderCard({required this.description});

  final String description;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          description,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12),
        ),
        const SizedBox(height: 12),

        Slider(value: 1, min: 0, max: 2, divisions: 2, onChanged: null),

        const SizedBox(height: 8),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            _BottomValueBox(label: '₩5.7억'),
            _BottomValueBox(label: '₩7.7억'),
            _BottomValueBox(label: '₩9.7억'),
          ],
        ),
      ],
    );
  }
}

class _BottomValueBox extends StatelessWidget {
  const _BottomValueBox({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Text(label),
    );
  }
}
