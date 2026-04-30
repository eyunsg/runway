import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CreatePostTempScreen extends ConsumerStatefulWidget {
  const CreatePostTempScreen({super.key});

  @override
  ConsumerState<CreatePostTempScreen> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends ConsumerState<CreatePostTempScreen> {
  late TextEditingController _contentController;
  bool _isPortfolioTagged = false;

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController();
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        actions: [
          TextButton(
            onPressed: () {
              // TODO: Controller 호출
            },
            child: const Text('남기기'),
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
            child: _isPortfolioTagged
                ? _buildPortfolioCard()
                : _buildTagButton(),
          ),
        ],
      ),
    );
  }

  // 포트폴리오 태그 버튼
  Widget _buildTagButton() {
    return OutlinedButton(
      onPressed: () => setState(() => _isPortfolioTagged = true),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
      ),
      child: const Text('포트폴리오 태그'),
    );
  }

  // 포트폴리오 카드, 편집 아이콘
  Widget _buildPortfolioCard() {
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
              children: const [
                Text('포트폴리오명', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text('자산 5개 · 투자 기간 10년', style: TextStyle(fontSize: 12)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: () {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('포트폴리오 선택 기능 예정')));
          },
          icon: const Icon(Icons.edit),
        ),
      ],
    );
  }
}
