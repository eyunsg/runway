import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:runway/core/providers.dart';
import 'package:go_router/go_router.dart';
import 'package:runway/features/simulation/types/simulation_asset.dart';
import 'package:runway/features/portfolio/model/create_portfolio_input.dart';
import 'package:runway/core/theme/app_colors.dart';
import 'package:runway/core/theme/app_typography.dart';
import 'package:runway/shared/widgets/input_card.dart';
import 'package:runway/shared/widgets/button.dart';
import 'package:runway/shared/widgets/dialog.dart';

class SimulationScreen extends ConsumerStatefulWidget {
  const SimulationScreen({super.key});

  @override
  ConsumerState<SimulationScreen> createState() => _SimulationScreenState();
}

class _SimulationScreenState extends ConsumerState<SimulationScreen> {
  final _nameController = TextEditingController();
  final _periodController = TextEditingController();
  final _targetAmountController = TextEditingController();
  final _targetDividendController = TextEditingController();

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

  final Map<String, TextEditingController> _assetNameControllers = {};
  final Map<String, TextEditingController> _assetPriceControllers = {};
  final Map<String, TextEditingController> _initialInvestmentControllers = {};
  final Map<String, TextEditingController> _monthlyContributionControllers = {};
  final Map<String, TextEditingController> _annualGrowthRateControllers = {};
  final Map<String, TextEditingController> _dividendPerShareControllers = {};
  final Map<String, TextEditingController> _dividendGrowthRateControllers = {};

  String _digitsOnly(String value) {
    return value.replaceAll(RegExp(r'[^0-9]'), '');
  }

  int _parseInt(String value) {
    final raw = _digitsOnly(value).trim();
    return int.tryParse(raw) ?? 0;
  }

  double _parseDouble(String value) {
    final raw = value.replaceAll(',', '').trim();
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

  void _ensureAssetControllers(SimulationAsset asset) {
    _assetNameControllers.putIfAbsent(
      asset.id,
      () => TextEditingController(text: asset.assetName),
    );
    _assetPriceControllers.putIfAbsent(
      asset.id,
      () => TextEditingController(
        text: asset.price == 0 ? '' : asset.price.toString(),
      ),
    );
    _initialInvestmentControllers.putIfAbsent(
      asset.id,
      () => TextEditingController(
        text: asset.amount == 0 ? '' : asset.amount.toString(),
      ),
    );
    _monthlyContributionControllers.putIfAbsent(
      asset.id,
      () => TextEditingController(
        text: asset.monthlyContributionAmount == 0
            ? ''
            : asset.monthlyContributionAmount.toString(),
      ),
    );
    _annualGrowthRateControllers.putIfAbsent(
      asset.id,
      () => TextEditingController(
        text: asset.yield == 0 ? '' : asset.yield.toString(),
      ),
    );
    _dividendPerShareControllers.putIfAbsent(
      asset.id,
      () => TextEditingController(
        text: asset.dividendAmount == 0 ? '' : asset.dividendAmount.toString(),
      ),
    );
    _dividendGrowthRateControllers.putIfAbsent(
      asset.id,
      () => TextEditingController(
        text: asset.dividendGrowth == 0 ? '' : asset.dividendGrowth.toString(),
      ),
    );
  }

  void _disposeAssetControllers(String assetId) {
    _assetNameControllers.remove(assetId)?.dispose();
    _assetPriceControllers.remove(assetId)?.dispose();
    _initialInvestmentControllers.remove(assetId)?.dispose();
    _monthlyContributionControllers.remove(assetId)?.dispose();
    _annualGrowthRateControllers.remove(assetId)?.dispose();
    _dividendPerShareControllers.remove(assetId)?.dispose();
    _dividendGrowthRateControllers.remove(assetId)?.dispose();
  }

  @override
  void initState() {
    super.initState();
    _ensureAssetControllers(_assets.first);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _periodController.dispose();
    _targetAmountController.dispose();
    _targetDividendController.dispose();

    for (final controller in _assetNameControllers.values) {
      controller.dispose();
    }
    for (final controller in _assetPriceControllers.values) {
      controller.dispose();
    }
    for (final controller in _initialInvestmentControllers.values) {
      controller.dispose();
    }
    for (final controller in _monthlyContributionControllers.values) {
      controller.dispose();
    }
    for (final controller in _annualGrowthRateControllers.values) {
      controller.dispose();
    }
    for (final controller in _dividendPerShareControllers.values) {
      controller.dispose();
    }
    for (final controller in _dividendGrowthRateControllers.values) {
      controller.dispose();
    }

    super.dispose();
  }

  Future<void> _confirmAndDeleteAsset(int index) async {
    final canDelete = ref
        .read(simulationControllerProvider.notifier)
        .validateCanDeleteAsset(_assets.length);

    if (!canDelete) return;

    final shouldDelete =
        await showDialog<bool>(
          context: context,
          barrierColor: Colors.black.withValues(alpha: 0.4),
          builder: (dialogContext) {
            return Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              insetPadding: const EdgeInsets.symmetric(horizontal: 24),
              child: AppDialog(
                title: '자산 삭제',
                description: '해당 자산 카드를 삭제할까요?',
                secondaryButtonText: '취소',
                primaryButtonText: '확인',
                onSecondaryPressed: () {
                  Navigator.of(dialogContext).pop(false);
                },
                onPrimaryPressed: () {
                  Navigator.of(dialogContext).pop(true);
                },
              ),
            );
          },
        ) ??
        false;

    if (shouldDelete == true) {
      final assetId = _assets[index].id;

      setState(() {
        _assets.removeAt(index);
      });

      _disposeAssetControllers(assetId);
    }
  }

  // 자산 추가 처리 함수
  void _addAsset() {
    final canAdd = ref
        .read(simulationControllerProvider.notifier)
        .validateCanAddAsset(_assets.length);

    if (!canAdd) return;

    final newAsset = SimulationAsset(
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
    );

    _ensureAssetControllers(newAsset);

    setState(() {
      _assets.add(newAsset);
    });
  }

  void _updateAssetFromControllers(int index) {
    final asset = _assets[index];
    final assetId = asset.id;

    setState(() {
      _assets[index] = SimulationAsset(
        id: asset.id,
        assetName: _assetNameControllers[assetId]?.text.trim() ?? '',
        assetType: asset.assetType,
        price:
            double.tryParse(
              (_assetPriceControllers[assetId]?.text ?? '').replaceAll(',', ''),
            ) ??
            0.0,
        amount:
            double.tryParse(
              (_initialInvestmentControllers[assetId]?.text ?? '').replaceAll(
                ',',
                '',
              ),
            ) ??
            0.0,
        monthlyContributionAmount:
            double.tryParse(
              (_monthlyContributionControllers[assetId]?.text ?? '').replaceAll(
                ',',
                '',
              ),
            ) ??
            0.0,
        yield:
            double.tryParse(
              _annualGrowthRateControllers[assetId]?.text ?? '',
            ) ??
            0.0,
        isDividendAsset: asset.isDividendAsset,
        dividendAmount:
            double.tryParse(
              (_dividendPerShareControllers[assetId]?.text ?? '').replaceAll(
                ',',
                '',
              ),
            ) ??
            0.0,
        dividendGrowth:
            double.tryParse(
              _dividendGrowthRateControllers[assetId]?.text ?? '',
            ) ??
            0.0,
        dividendPeriod: asset.dividendPeriod,
        isDividendReinvest: asset.isDividendReinvest,
        monthlyVolatility: asset.assetType.isEmpty
            ? 0.0
            : ref
                  .read(simulationControllerProvider.notifier)
                  .resolveMonthlyVolatility(asset.assetType),
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
        centerTitle: true,
        title: Text(
          '추가',
          style: AppTypography.body.m.copyWith(
            color: AppColors.natural.textColors.primary,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppPortfolioNameInputCard(
                portfolioNameController: _nameController,
              ),
              const SizedBox(height: 16),

              AppTargetInputCard(
                targetAgeController: _periodController,
                targetEvaluationController: _targetAmountController,
                targetDividendController: _targetDividendController,
              ),
              const SizedBox(height: 16),

              ..._assets.asMap().entries.map((entry) {
                final int index = entry.key;
                final SimulationAsset asset = entry.value;

                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index == _assets.length - 1 ? 0 : 16,
                  ),
                  child: AppAssetInputCard(
                    key: ValueKey(asset.id),
                    assetNameController: _assetNameControllers[asset.id],
                    assetPriceController: _assetPriceControllers[asset.id],
                    initialInvestmentController:
                        _initialInvestmentControllers[asset.id],
                    monthlyContributionController:
                        _monthlyContributionControllers[asset.id],
                    annualGrowthRateController:
                        _annualGrowthRateControllers[asset.id],
                    dividendPerShareController:
                        _dividendPerShareControllers[asset.id],
                    dividendGrowthRateController:
                        _dividendGrowthRateControllers[asset.id],
                    selectedAssetType: asset.assetType.isEmpty
                        ? null
                        : asset.assetType,
                    selectedDividendCycle: asset.dividendPeriod.isEmpty
                        ? null
                        : asset.dividendPeriod,
                    assetTypeOptions: const [
                      'STOCK',
                      'CRYPTO',
                      'INDEX',
                      'COMMODITY',
                      'GOLD',
                    ],
                    dividendCycleOptions: const ['월', '분기'],
                    initialIsDividendAsset: asset.isDividendAsset,
                    initialIsDividendReinvestment: asset.isDividendReinvest,
                    onAssetFieldsChanged: () {
                      _updateAssetFromControllers(index);
                    },

                    onAssetTypeChanged: (value) {
                      setState(() {
                        final current = _assets[index];
                        _assets[index] = SimulationAsset(
                          id: current.id,
                          assetName: current.assetName,
                          assetType: value ?? '',
                          price: current.price,
                          amount: current.amount,
                          monthlyContributionAmount:
                              current.monthlyContributionAmount,
                          yield: current.yield,
                          isDividendAsset: current.isDividendAsset,
                          dividendAmount: current.dividendAmount,
                          dividendGrowth: current.dividendGrowth,
                          dividendPeriod: current.dividendPeriod,
                          isDividendReinvest: current.isDividendReinvest,
                          monthlyVolatility: value == null || value.isEmpty
                              ? 0.0
                              : ref
                                    .read(simulationControllerProvider.notifier)
                                    .resolveMonthlyVolatility(value),
                        );
                      });
                    },
                    onDividendCycleChanged: (value) {
                      setState(() {
                        final current = _assets[index];
                        _assets[index] = SimulationAsset(
                          id: current.id,
                          assetName: current.assetName,
                          assetType: current.assetType,
                          price: current.price,
                          amount: current.amount,
                          monthlyContributionAmount:
                              current.monthlyContributionAmount,
                          yield: current.yield,
                          isDividendAsset: current.isDividendAsset,
                          dividendAmount: current.dividendAmount,
                          dividendGrowth: current.dividendGrowth,
                          dividendPeriod: value ?? '',
                          isDividendReinvest: current.isDividendReinvest,
                          monthlyVolatility: current.monthlyVolatility,
                        );
                      });
                    },

                    onDividendAssetChanged: (value) {
                      setState(() {
                        final current = _assets[index];
                        _assets[index] = SimulationAsset(
                          id: current.id,
                          assetName: current.assetName,
                          assetType: current.assetType,
                          price: current.price,
                          amount: current.amount,
                          monthlyContributionAmount:
                              current.monthlyContributionAmount,
                          yield: current.yield,
                          isDividendAsset: value,
                          dividendAmount: value ? current.dividendAmount : 0.0,
                          dividendGrowth: value ? current.dividendGrowth : 0.0,
                          dividendPeriod: value ? current.dividendPeriod : '',
                          isDividendReinvest: value
                              ? current.isDividendReinvest
                              : false,
                          monthlyVolatility: current.monthlyVolatility,
                        );
                      });

                      if (!value) {
                        _dividendPerShareControllers[_assets[index].id]
                            ?.clear();
                        _dividendGrowthRateControllers[_assets[index].id]
                            ?.clear();
                        _updateAssetFromControllers(index);
                      }
                    },

                    onDividendReinvestmentChanged: (value) {
                      setState(() {
                        final current = _assets[index];
                        _assets[index] = SimulationAsset(
                          id: current.id,
                          assetName: current.assetName,
                          assetType: current.assetType,
                          price: current.price,
                          amount: current.amount,
                          monthlyContributionAmount:
                              current.monthlyContributionAmount,
                          yield: current.yield,
                          isDividendAsset: current.isDividendAsset,
                          dividendAmount: current.dividendAmount,
                          dividendGrowth: current.dividendGrowth,
                          dividendPeriod: current.dividendPeriod,
                          isDividendReinvest: value,
                          monthlyVolatility: current.monthlyVolatility,
                        );
                      });
                    },

                    onRemoveTap: () async {
                      await _confirmAndDeleteAsset(index);
                    },
                  ),
                );
              }),

              const SizedBox(height: 16),

              AppButton(
                text: '자산 추가하기',
                variant: ButtonVariant.secondary,
                onPressed: _addAsset,
              ),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      floatingActionButton: SizedBox(
        width: 56,
        height: 56,
        child: FloatingActionButton(
          heroTag: 'simulation_run_fab',
          elevation: 10,
          highlightElevation: 14,
          disabledElevation: 8,
          backgroundColor: AppColors.highlight.light,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          onPressed: simulationState.isLoading
              ? null
              : () async {
                  for (int i = 0; i < _assets.length; i++) {
                    _updateAssetFromControllers(i);
                  }

                  await ref
                      .read(simulationControllerProvider.notifier)
                      .runSimulation(
                        periodMonths: _parseInt(_periodController.text) * 12,
                        targetValue: _parseDouble(_targetAmountController.text),
                        targetDividend: _parseDouble(
                          _targetDividendController.text,
                        ),
                        assets: _buildAssetRequest(),
                      );
                },
          child: simulationState.isLoading
              ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    color: AppColors.natural.textColors.primary,
                  ),
                )
              : Image.asset(
                  'assets/icons/Play.png',
                  width: 12,
                  height: 12,
                  color: AppColors.natural.textColors.primary,
                ),
        ),
      ),
    );
  }
}
