import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SimulationTempScreen extends ConsumerStatefulWidget {
  const SimulationTempScreen({super.key});

  @override
  ConsumerState<SimulationTempScreen> createState() =>
      _SimulationTempScreenState();
}

class _SimulationTempScreenState extends ConsumerState<SimulationTempScreen> {
  final _periodController = TextEditingController();
  final _targetAmountController = TextEditingController();
  final _targetDividendController = TextEditingController();
  final _assetNameController = TextEditingController(text: 'SPY');
  final _priceController = TextEditingController(text: '972000');
  final _amountController = TextEditingController(text: '1000000');
  final _yieldController = TextEditingController(text: '10');
  String _selectedAssetType = 'ETF';
  bool _isDividendAsset = false;

  @override
  void dispose() {
    _periodController.dispose();
    _targetAmountController.dispose();
    _targetDividendController.dispose();
    _assetNameController.dispose();
    _priceController.dispose();
    _amountController.dispose();
    _yieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 공통 설정 그룹
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _periodController,
                      decoration: const InputDecoration(
                        labelText: '투자 기간 (년)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _targetAmountController,
                      decoration: const InputDecoration(
                        labelText: '목표 평가금 (₩)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _targetDividendController,
                      decoration: const InputDecoration(
                        labelText: '목표 배당금 (₩)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 개별 자산 설정 그룹
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _assetNameController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _selectedAssetType,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'ETF', child: Text('ETF')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedAssetType = value);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _priceController,
                      decoration: const InputDecoration(
                        prefixText: '₩',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _amountController,
                      decoration: const InputDecoration(
                        prefixText: '₩',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _yieldController,
                      decoration: const InputDecoration(
                        suffixText: '%',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 배당 자산 스위치
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('배당 자산'),
                        Switch(
                          value: _isDividendAsset,
                          onChanged: (v) =>
                              setState(() => _isDividendAsset = v),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // 삭제 버튼
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(40),
                      ),
                      child: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // 하단 실행 플로팅 버튼
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: 데이터 전달 로직 구현
        },
        child: const Icon(Icons.play_arrow),
      ),
    );
  }
}
