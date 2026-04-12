import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:runway/core/providers.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import 'package:runway/features/simulation/types/simulation_asset.dart';
import 'package:runway/features/portfolio/model/create_portfolio_input.dart';

// 천 단위 구분자 포맷/해제 유틸 함수
String formatCurrency(String value) {
  if (value.isEmpty) return '';
  final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
  if (digits.isEmpty) return '';
  final buffer = StringBuffer();
  for (int i = 0; i < digits.length; i++) {
    final reverseIndex = digits.length - i;
    buffer.write(digits[i]);
    if (reverseIndex > 1 && reverseIndex % 3 == 1) {
      buffer.write(',');
    }
  }
  return buffer.toString();
}

String unformatCurrency(String value) {
  return value.replaceAll(RegExp(r'[^0-9]'), '');
}

class SimulationTempScreen extends ConsumerStatefulWidget {
  const SimulationTempScreen({super.key});

  @override
  ConsumerState<SimulationTempScreen> createState() =>
      _SimulationTempScreenState();
}

class _SimulationTempScreenState extends ConsumerState<SimulationTempScreen> {
  final _nameController = TextEditingController();
  // 상단 공통 조건(기간, 목표 평가/배당금)만 이 화면 State에
  // 자산별 입력값은 SimulationAsset + 카드 위젯에서 관리하도록 분리
  final _periodController = TextEditingController();
  final _targetAmountController = TextEditingController();
  final _targetDividendController = TextEditingController();

  // 천 단위 구분자를 적용/제거 포커스 노드
  late FocusNode _targetAmountFocusNode;
  late FocusNode _targetDividendFocusNode;

  // 자산 리스트 상태
  final List<SimulationAsset> _assets = [
    SimulationAsset(
      id: UniqueKey().toString(),
      assetName: '',
      assetType: '',
      price: 0.0,
      amount: 0.0,
      monthlyContributionAmount: 0.0,
      yield: 0.0,
      isDividendAsset: false,
      dividendAmount: 0.0,
      dividendGrowth: 0.0,
      dividendPeriod: '',
      isDividendReinvest: false,
      monthlyVolatility: 0.0,
    ),
  ];

  int _parseInt(String value) {
    final raw = unformatCurrency(value).trim();
    return int.tryParse(raw) ?? 0;
  }

  double _parseDouble(String value) {
    final raw = unformatCurrency(value).trim();
    return double.tryParse(raw) ?? 0.0;
  }

  List<Map<String, dynamic>> _buildAssetRequest() {
    return _assets.map((asset) {
      return {
        'assetName': asset.assetName.trim(),
        'assetType': asset.assetType.trim(),
        'price': asset.price,
        'amount': asset.amount,
        'monthlyContributionAmount': asset.monthlyContributionAmount,
        'yield': asset.yield,
        'isDividendAsset': asset.isDividendAsset,
        'dividendAmount': asset.dividendAmount,
        'dividendGrowth': asset.dividendGrowth,
        'dividendPeriod': asset.dividendPeriod.trim(),
        'isDividendReinvest': asset.isDividendReinvest,
        'monthlyVolatility': asset.monthlyVolatility,
      };
    }).toList();
  }

  // simulation 성공 결과/화면 입력값
  CreatePortfolioInput _buildCreatePortfolioInput(
    Map<String, dynamic> resultData,
  ) {
    final periodMonths = _parseInt(_periodController.text) * 12;
    final targetPortfolioValue = _parseDouble(_targetAmountController.text);
    final targetMonthlyDividend = _parseDouble(_targetDividendController.text);

    return CreatePortfolioInput(
      name: _nameController.text.trim().isEmpty
          ? '포트폴리오'
          : _nameController.text.trim(),
      simulationInput: SimulationInput(
        goal: GoalInput(
          investmentPeriodMonths: periodMonths,
          targetPortfolioValue: targetPortfolioValue,
          targetMonthlyDividend: targetMonthlyDividend,
        ),
        assets: _assets.map((asset) {
          return AssetInput(
            assetName: asset.assetName.trim(),
            assetType: asset.assetType.trim(),
            initialPrice: asset.price,
            expectedAnnualPriceGrowthRate: asset.yield,
            initialInvestmentAmount: asset.amount,
            monthlyContributionAmount: asset.monthlyContributionAmount,
            isDividendAsset: asset.isDividendAsset,
            dividendPerShare: asset.isDividendAsset
                ? asset.dividendAmount
                : null,
            expectedAnnualDividendGrowthRate: asset.isDividendAsset
                ? asset.dividendGrowth
                : null,
            dividendFrequency: asset.isDividendAsset
                ? asset.dividendPeriod.trim()
                : null,
            isReinvestDividends: asset.isDividendAsset
                ? asset.isDividendReinvest
                : null,
          );
        }).toList(),
      ),
      simulationResult: SimulationResult(
        percentiles: PercentilesInput(
          portfolioValue: PortfolioValueInput(
            p10: resultData['percentiles']['portfolioValue']['p10'] as num,
            p50: resultData['percentiles']['portfolioValue']['p50'] as num,
            p90: resultData['percentiles']['portfolioValue']['p90'] as num,
          ),
          monthlyDividend: MonthlyDividendInput(
            p10: resultData['percentiles']['monthlyDividend']['p10'] as num,
            p50: resultData['percentiles']['monthlyDividend']['p50'] as num,
            p90: resultData['percentiles']['monthlyDividend']['p90'] as num,
          ),
        ),
        goalAnalysis: GoalAnalysisInput(
          portfolioValueGoal: PortfolioValueGoalInput(
            expectedMonthsToTarget:
                resultData['goalAnalysis']['portfolioValueGoal']['expectedMonthsToTarget']
                    as int?,
          ),
          monthlyDividendGoal: MonthlyDividendGoalInput(
            expectedMonthsToTarget:
                resultData['goalAnalysis']['monthlyDividendGoal']['expectedMonthsToTarget']
                    as int?,
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _targetAmountFocusNode = FocusNode();
    _targetDividendFocusNode = FocusNode();

    // 포커스 리스너
    // 포커스를 얻으면 콤마 제거, 잃으면 천 단위 구분자를 적용
    _targetAmountFocusNode.addListener(() {
      if (_targetAmountFocusNode.hasFocus) {
        _targetAmountController.text = unformatCurrency(
          _targetAmountController.text,
        );
      } else {
        _targetAmountController.text = formatCurrency(
          _targetAmountController.text,
        );
      }
    });

    _targetDividendFocusNode.addListener(() {
      if (_targetDividendFocusNode.hasFocus) {
        _targetDividendController.text = unformatCurrency(
          _targetDividendController.text,
        );
      } else {
        _targetDividendController.text = formatCurrency(
          _targetDividendController.text,
        );
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _periodController.dispose();
    _targetAmountController.dispose();
    _targetDividendController.dispose();
    _targetAmountFocusNode.dispose();
    _targetDividendFocusNode.dispose();
    super.dispose();
  }

  // 자산 삭제 처리 함수
  Future<void> _confirmAndDeleteAsset(int index) async {
    final canDelete = ref
        .read(simulationControllerProvider.notifier)
        .validateCanDeleteAsset(_assets.length);

    if (!canDelete) return;

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('자산 삭제'),
          content: const Text('해당 자산 카드를 삭제할까요?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('확인'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      // 실제 삭제 수행
      setState(() {
        _assets.removeAt(index);
      });
    }
  }

  // 자산 추가 처리 함수
  void _addAsset() {
    final canAdd = ref
        .read(simulationControllerProvider.notifier)
        .validateCanAddAsset(_assets.length);

    if (!canAdd) return;

    setState(() {
      _assets.add(
        SimulationAsset(
          id: UniqueKey().toString(),
          assetName: '',
          assetType: '',
          price: 0.0,
          amount: 0.0,
          monthlyContributionAmount: 0.0,
          yield: 0.0,
          isDividendAsset: false,
          dividendAmount: 0.0,
          dividendGrowth: 0.0,
          dividendPeriod: '',
          isDividendReinvest: false,
          monthlyVolatility: 0.0,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final simulationState = ref.watch(simulationControllerProvider);

    ref.listen(simulationControllerProvider, (previous, next) {
      if (next.error != null && next.error!.isNotEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.error!)));
        ref.read(simulationControllerProvider.notifier).clearError();
        return;
      }

      // simulation 성공
      if (previous?.isSuccess != true &&
          next.isSuccess &&
          next.resultData != null) {
        final resultData = next.resultData as Map<String, dynamic>;
        final createPortfolioInput = _buildCreatePortfolioInput(resultData);

        if (!context.mounted) return;

        context.push('/portfolio/create', extra: createPortfolioInput);
      }
    });

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
                      controller: _nameController,
                      decoration: const InputDecoration(
                        hintText: '포트폴리오 이름',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _periodController,

                      // 숫자 전용 키패드 및 입력 제한
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        hintText: '투자 기간 (년)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _targetAmountController,
                      focusNode: _targetAmountFocusNode,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        prefixText: '₩',
                        hintText: '목표 평가금 (₩)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _targetDividendController,
                      focusNode: _targetDividendFocusNode,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        prefixText: '₩',
                        hintText: '목표 배당금 (₩)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // _assets 리스트 길이만큼 카드를 만들어 아래에 쌓는 구조
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _assets.length,
              itemBuilder: (context, index) {
                final asset = _assets[index];
                return _AssetCard(
                  // 각 카드에 고유 key 부여
                  key: ValueKey(asset.id),
                  asset: asset,
                  onChanged: (updated) {
                    // 개별 카드에서 텍스트를 수정하면 그 값이 상위 _assets[index]에 반영되도록 하는 콜백
                    setState(() {
                      _assets[index] = updated;
                    });
                  },
                  onDelete: () async {
                    await _confirmAndDeleteAsset(index);
                  },
                  resolveMonthlyVolatility: (assetType) {
                    return ref
                        .read(simulationControllerProvider.notifier)
                        .resolveMonthlyVolatility(assetType);
                  },
                );
              },
            ),
            const SizedBox(height: 12),

            // 자산 추가하기 버튼
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _addAsset,
                  child: const Text('자산 추가하기'),
                ),
              ),
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),

      // 하단 실행 플로팅 버튼
      floatingActionButton: FloatingActionButton(
        onPressed: simulationState.isLoading
            ? null
            : () async {
                await ref
                    .read(simulationControllerProvider.notifier)
                    .runSimulation(
                      periodMonths:
                          _parseInt(_periodController.text) *
                          12, // UI가 '년'으로 받고있음
                      targetValue: _parseDouble(_targetAmountController.text),
                      targetDividend: _parseDouble(
                        _targetDividendController.text,
                      ),
                      assets: _buildAssetRequest(),
                    );
              },
        child: simulationState.isLoading
            ? const CircularProgressIndicator()
            : const Icon(Icons.play_arrow),
      ),
    );
  }
}

// 개별 자산 카드를 그리는 위젯
// SimulationAsset 하나를 받아서 TextField들 + 배당 스위치 + 삭제 버튼을 포함한 Card를 그림
// 내부에서 TextEditingController를 만들어 초기값만 Asset에서 가져오고
// 변경될 때마다 onChanged 콜백으로 상위에 변경된 SimulationAsset을 넘겨준다.
class _AssetCard extends StatefulWidget {
  const _AssetCard({
    super.key,
    required this.asset,
    required this.onChanged,
    required this.onDelete,
    required this.resolveMonthlyVolatility,
  });

  final SimulationAsset asset;
  final ValueChanged<SimulationAsset> onChanged;
  final VoidCallback onDelete;
  final double Function(String assetType) resolveMonthlyVolatility;

  @override
  State<_AssetCard> createState() => _AssetCardState();
}

class _AssetCardState extends State<_AssetCard> {
  late TextEditingController _assetNameController;
  late TextEditingController _priceController;
  late TextEditingController _amountController;
  late TextEditingController _monthlyContributionController; // 새 컨트롤러
  late TextEditingController _yieldController;
  String? _selectedAssetType;
  late bool _isDividendAsset;

  late TextEditingController _dividendAmountController;
  late TextEditingController _dividendGrowthController;
  String? _selectedDividendPeriod;
  late bool _isDividendReinvest;

  late FocusNode _priceFocusNode;
  late FocusNode _amountFocusNode;
  late FocusNode _monthlyContributionFocusNode; // 새 FocusNode
  late FocusNode _dividendAmountFocusNode;

  @override
  void initState() {
    super.initState();
    _assetNameController = TextEditingController(text: widget.asset.assetName);
    _priceController = TextEditingController(
      text: widget.asset.price == 0 ? '' : widget.asset.price.toString(),
    );
    _amountController = TextEditingController(
      text: widget.asset.amount == 0 ? '' : widget.asset.amount.toString(),
    );
    _monthlyContributionController = TextEditingController(
      text: widget.asset.monthlyContributionAmount == 0
          ? ''
          : widget.asset.monthlyContributionAmount.toString(),
    );
    _yieldController = TextEditingController(
      text: widget.asset.yield == 0 ? '' : widget.asset.yield.toString(),
    );
    _selectedAssetType = widget.asset.assetType.isEmpty
        ? null
        : widget.asset.assetType;
    _isDividendAsset = widget.asset.isDividendAsset;

    _dividendAmountController = TextEditingController(
      text: widget.asset.dividendAmount == 0
          ? ''
          : widget.asset.dividendAmount.toString(),
    );
    _dividendGrowthController = TextEditingController(
      text: widget.asset.dividendGrowth == 0
          ? ''
          : widget.asset.dividendGrowth.toString(),
    );
    _selectedDividendPeriod = widget.asset.dividendPeriod.isEmpty
        ? null
        : widget.asset.dividendPeriod;
    _isDividendReinvest = widget.asset.isDividendReinvest;

    _priceFocusNode = FocusNode();
    _amountFocusNode = FocusNode();
    _monthlyContributionFocusNode = FocusNode();
    _dividendAmountFocusNode = FocusNode();

    // Focus 리스너 등록
    _priceFocusNode.addListener(() {
      if (_priceFocusNode.hasFocus) {
        _priceController.text = unformatCurrency(_priceController.text);
      } else {
        _priceController.text = formatCurrency(_priceController.text);
      }
    });

    _amountFocusNode.addListener(() {
      if (_amountFocusNode.hasFocus) {
        _amountController.text = unformatCurrency(_amountController.text);
      } else {
        _amountController.text = formatCurrency(_amountController.text);
      }
    });

    _monthlyContributionFocusNode.addListener(() {
      if (_monthlyContributionFocusNode.hasFocus) {
        _monthlyContributionController.text = unformatCurrency(
          _monthlyContributionController.text,
        );
      } else {
        _monthlyContributionController.text = formatCurrency(
          _monthlyContributionController.text,
        );
      }
    });

    _dividendAmountFocusNode.addListener(() {
      if (_dividendAmountFocusNode.hasFocus) {
        _dividendAmountController.text = unformatCurrency(
          _dividendAmountController.text,
        );
      } else {
        _dividendAmountController.text = formatCurrency(
          _dividendAmountController.text,
        );
      }
    });
  }

  @override
  void dispose() {
    _assetNameController.dispose();
    _priceController.dispose();
    _amountController.dispose();
    _monthlyContributionController.dispose();
    _yieldController.dispose();
    _dividendAmountController.dispose();
    _dividendGrowthController.dispose();
    _priceFocusNode.dispose();
    _amountFocusNode.dispose();
    _monthlyContributionFocusNode.dispose();
    _dividendAmountFocusNode.dispose();
    super.dispose();
  }

  void _notifyParent() {
    widget.onChanged(
      SimulationAsset(
        id: widget.asset.id,
        assetName: _assetNameController.text.trim(),
        assetType: _selectedAssetType ?? '',
        price: double.tryParse(unformatCurrency(_priceController.text)) ?? 0.0,
        amount:
            double.tryParse(unformatCurrency(_amountController.text)) ?? 0.0,
        monthlyContributionAmount:
            double.tryParse(
              unformatCurrency(_monthlyContributionController.text),
            ) ??
            0.0,
        yield: double.tryParse(_yieldController.text.trim()) ?? 0.0,
        isDividendAsset: _isDividendAsset,
        dividendAmount:
            double.tryParse(unformatCurrency(_dividendAmountController.text)) ??
            0.0,
        dividendGrowth:
            double.tryParse(_dividendGrowthController.text.trim()) ?? 0.0,
        dividendPeriod: _selectedDividendPeriod ?? '',
        isDividendReinvest: _isDividendReinvest,
        monthlyVolatility: _selectedAssetType == null
            ? 0.0
            : widget.resolveMonthlyVolatility(_selectedAssetType!),
      ),
    );
  }

  void _resetDividendFields() {
    _dividendAmountController.clear();
    _dividendGrowthController.clear();
    _selectedDividendPeriod = null;
    _isDividendReinvest = false;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _assetNameController,
              onChanged: (_) => _notifyParent(),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: '자산명',
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedAssetType,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: '자산 타입',
              ),
              items: const [
                DropdownMenuItem(value: 'STOCK', child: Text('개별 주식')),
                DropdownMenuItem(value: 'CRYPTO', child: Text('암호화폐')),
                DropdownMenuItem(
                  value: 'INDEX',
                  child: Text('인덱스형 자산(ETF, 지수펀드)'),
                ),
                DropdownMenuItem(value: 'COMMODITY', child: Text('원자재')),
                DropdownMenuItem(value: 'GOLD', child: Text('금')),
              ],
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _selectedAssetType = value;
                });
                _notifyParent();
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _priceController,
              focusNode: _priceFocusNode,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (_) => _notifyParent(),
              decoration: const InputDecoration(
                prefixText: '₩',
                border: OutlineInputBorder(),
                hintText: '자산 가격 (₩)',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _amountController,
              focusNode: _amountFocusNode,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (_) => _notifyParent(),
              decoration: const InputDecoration(
                prefixText: '₩',
                border: OutlineInputBorder(),
                hintText: '초기 투자금 (₩)',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _monthlyContributionController,
              focusNode: _monthlyContributionFocusNode,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (_) => _notifyParent(),
              decoration: const InputDecoration(
                prefixText: '₩',
                border: OutlineInputBorder(),
                hintText: '월 투자금 (₩)',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _yieldController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (_) => _notifyParent(),
              decoration: const InputDecoration(
                suffixText: '%',
                border: OutlineInputBorder(),
                hintText: '연 성장률 (%)',
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('배당 자산'),
                Switch(
                  value: _isDividendAsset,
                  onChanged: (v) {
                    setState(() {
                      _isDividendAsset = v;

                      if (!v) {
                        _resetDividendFields();
                      }
                    });
                    _notifyParent();
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 배당 자산이 true일 때만 배당 관련 입력 영역을 노출
            if (_isDividendAsset) ...[
              TextField(
                controller: _dividendAmountController,
                focusNode: _dividendAmountFocusNode,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (_) => _notifyParent(),
                decoration: const InputDecoration(
                  prefixText: '₩',
                  border: OutlineInputBorder(),
                  hintText: '주당 배당금 (₩)',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _dividendGrowthController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (_) => _notifyParent(),
                decoration: const InputDecoration(
                  suffixText: '%',
                  border: OutlineInputBorder(),
                  hintText: '배당 성장률 (%)',
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedDividendPeriod,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: '배당 주기',
                ),
                items: const [
                  DropdownMenuItem(value: '월', child: Text('월')),
                  DropdownMenuItem(value: '분기', child: Text('분기')),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    _selectedDividendPeriod = value;
                  });
                  _notifyParent();
                },
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('배당 재투자'),
                  Switch(
                    value: _isDividendReinvest,
                    onChanged: (v) {
                      setState(() {
                        _isDividendReinvest = v;
                      });
                      _notifyParent();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],

            // 삭제 버튼 (X 아이콘)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: widget.onDelete,
                child: const Icon(Icons.close),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
