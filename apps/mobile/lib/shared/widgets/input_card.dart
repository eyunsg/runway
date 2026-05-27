import 'package:flutter/material.dart';
import 'package:runway/core/theme/app_colors.dart';
import 'package:runway/core/theme/app_typography.dart';
import 'button.dart';

class AppTargetInputCard extends StatelessWidget {
  final TextEditingController? targetAgeController;
  final TextEditingController? targetEvaluationController;
  final TextEditingController? targetDividendController;

  const AppTargetInputCard({
    super.key,
    this.targetAgeController,
    this.targetEvaluationController,
    this.targetDividendController,
  });

  @override
  Widget build(BuildContext context) {
    return _InputCardContainer(
      minHeight: 196,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _InputCardTextField(
            controller: targetAgeController,
            hintText: '투자 기간 (년)',
          ),
          const SizedBox(height: 16),
          _InputCardTextField(
            controller: targetEvaluationController,
            hintText: '목표 평가금 (₩)',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          _InputCardTextField(
            controller: targetDividendController,
            hintText: '목표 배당금 (₩)',
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    );
  }
}

class AppAssetInputCard extends StatefulWidget {
  final TextEditingController? assetNameController;
  final TextEditingController? assetPriceController;
  final TextEditingController? initialInvestmentController;
  final TextEditingController? annualGrowthRateController;
  final TextEditingController? dividendPerShareController;
  final TextEditingController? dividendGrowthRateController;

  final String? selectedAssetType;
  final String? selectedDividendCycle;
  final List<String> assetTypeOptions;
  final List<String> dividendCycleOptions;

  final ValueChanged<String?>? onAssetTypeChanged;
  final ValueChanged<String?>? onDividendCycleChanged;
  final VoidCallback? onRemoveTap;

  final bool initialIsDividendAsset;
  final bool initialIsDividendReinvestment;

  const AppAssetInputCard({
    super.key,
    this.assetNameController,
    this.assetPriceController,
    this.initialInvestmentController,
    this.annualGrowthRateController,
    this.dividendPerShareController,
    this.dividendGrowthRateController,
    this.selectedAssetType,
    this.selectedDividendCycle,
    required this.assetTypeOptions,
    required this.dividendCycleOptions,
    this.onAssetTypeChanged,
    this.onDividendCycleChanged,
    this.onRemoveTap,
    this.initialIsDividendAsset = false,
    this.initialIsDividendReinvestment = false,
  });

  @override
  State<AppAssetInputCard> createState() => _AppAssetInputCardState();
}

class _AppAssetInputCardState extends State<AppAssetInputCard> {
  late bool _isDividendAsset;
  late bool _isDividendReinvestment;
  String? _assetType;
  String? _dividendCycle;

  TextEditingController? get _dividendPerShareController =>
      widget.dividendPerShareController;
  TextEditingController? get _dividendGrowthRateController =>
      widget.dividendGrowthRateController;

  @override
  void initState() {
    super.initState();
    _isDividendAsset = widget.initialIsDividendAsset;
    _isDividendReinvestment = widget.initialIsDividendReinvestment;
    _assetType = widget.selectedAssetType;
    _dividendCycle = widget.selectedDividendCycle;
  }

  void _handleDividendAssetChanged(bool value) {
    setState(() {
      _isDividendAsset = value;

      if (!value) {
        _isDividendReinvestment = false;
        _dividendCycle = null;
        _dividendPerShareController?.clear();
        _dividendGrowthRateController?.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return _InputCardContainer(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _InputCardTextField(
            controller: widget.assetNameController,
            hintText: '자산명',
          ),
          const SizedBox(height: 16),
          _InputCardSelectField(
            value: _assetType,
            hintText: '자산 타입',
            options: widget.assetTypeOptions,
            onChanged: (value) {
              setState(() => _assetType = value);
              widget.onAssetTypeChanged?.call(value);
            },
          ),
          const SizedBox(height: 16),
          _InputCardTextField(
            controller: widget.assetPriceController,
            hintText: '자산 가격 (₩)',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          _InputCardTextField(
            controller: widget.initialInvestmentController,
            hintText: '초기 투자금 (₩)',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          _InputCardTextField(
            controller: widget.annualGrowthRateController,
            hintText: '연 성장률 (%)',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 16),
          _ToggleRow(
            label: '배당 자산',
            value: _isDividendAsset,
            onChanged: _handleDividendAssetChanged,
          ),
          if (_isDividendAsset) ...[
            const SizedBox(height: 16),
            const _InputCardDivider(),
            const SizedBox(height: 16),
            _DividendSection(
              dividendPerShareController: widget.dividendPerShareController,
              dividendGrowthRateController: widget.dividendGrowthRateController,
              dividendCycle: _dividendCycle,
              dividendCycleOptions: widget.dividendCycleOptions,
              isDividendReinvestment: _isDividendReinvestment,
              onDividendCycleChanged: (value) {
                setState(() => _dividendCycle = value);
                widget.onDividendCycleChanged?.call(value);
              },
              onDividendReinvestmentChanged: (value) {
                setState(() => _isDividendReinvestment = value);
              },
            ),
          ],
          const SizedBox(height: 16),
          _InputCardBottomAction(onTap: widget.onRemoveTap),
        ],
      ),
    );
  }
}

class _InputCardContainer extends StatelessWidget {
  final Widget child;
  final double? minHeight;

  const _InputCardContainer({required this.child, this.minHeight});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: minHeight ?? 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.highlight.dark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}

class _InputCardTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String hintText;
  final TextInputType? keyboardType;

  const _InputCardTextField({
    required this.hintText,
    this.controller,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: AppTypography.body.m.copyWith(
          color: AppColors.natural.textColors.primary,
        ),
        cursorColor: AppColors.natural.textColors.primary,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: AppTypography.body.m.copyWith(
            color: AppColors.natural.textColors.secondary,
          ),
          filled: false,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: AppColors.natural.textColors.secondary,
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: AppColors.natural.textColors.primary,
              width: 1,
            ),
          ),
        ),
      ),
    );
  }
}

class _InputCardSelectField extends StatelessWidget {
  final String? value;
  final String hintText;
  final List<String> options;
  final ValueChanged<String?> onChanged;

  const _InputCardSelectField({
    required this.value,
    required this.hintText,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.only(left: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.natural.textColors.secondary,
          width: 1,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: AppColors.highlight.dark,
          icon: Padding(
            padding: const EdgeInsets.only(left: 8, right: 16),
            child: Image.asset(
              'assets/icons/Arrow Down.png',
              width: 12,
              height: 12,
              color: AppColors.natural.textColors.disabled,
            ),
          ),
          style: AppTypography.body.m.copyWith(
            color: AppColors.natural.textColors.primary,
          ),
          hint: Text(
            hintText,
            style: AppTypography.body.m.copyWith(
              color: AppColors.natural.textColors.secondary,
            ),
          ),
          items: options
              .map(
                (e) => DropdownMenuItem<String>(
                  value: e,
                  child: Text(
                    e,
                    style: AppTypography.body.m.copyWith(
                      color: AppColors.natural.textColors.primary,
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _InputCardDivider extends StatelessWidget {
  const _InputCardDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 1,
      color: AppColors.natural.textColors.disabled,
    );
  }
}

class _InputCardBottomAction extends StatelessWidget {
  final VoidCallback? onTap;

  const _InputCardBottomAction({this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      width: double.infinity,
      child: AppButton(
        text: 'X',
        variant: ButtonVariant.danger,
        onPressed: onTap ?? () {},
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text(
                label,
                style: AppTypography.body.m.copyWith(
                  color: AppColors.natural.textColors.primary,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: _InputCardToggle(value: value, onChanged: onChanged),
          ),
        ],
      ),
    );
  }
}

class _InputCardToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _InputCardToggle({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = value
        ? AppColors.highlight.light
        : AppColors.natural.textColors.secondary;

    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 45,
        height: 28,
        padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 4),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(200),
        ),
        child: Align(
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: AppColors.natural.textColors.primary,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ),
      ),
    );
  }
}

class _DividendSection extends StatelessWidget {
  final TextEditingController? dividendPerShareController;
  final TextEditingController? dividendGrowthRateController;
  final String? dividendCycle;
  final List<String> dividendCycleOptions;
  final bool isDividendReinvestment;
  final ValueChanged<String?> onDividendCycleChanged;
  final ValueChanged<bool> onDividendReinvestmentChanged;

  const _DividendSection({
    this.dividendPerShareController,
    this.dividendGrowthRateController,
    required this.dividendCycle,
    required this.dividendCycleOptions,
    required this.isDividendReinvestment,
    required this.onDividendCycleChanged,
    required this.onDividendReinvestmentChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _InputCardTextField(
          controller: dividendPerShareController,
          hintText: '주당 배당금 (₩)',
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        _InputCardTextField(
          controller: dividendGrowthRateController,
          hintText: '배당 성장률 (%)',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
        const SizedBox(height: 16),
        _InputCardSelectField(
          value: dividendCycle,
          hintText: '배당 주기',
          options: dividendCycleOptions,
          onChanged: onDividendCycleChanged,
        ),
        const SizedBox(height: 16),
        _ToggleRow(
          label: '배당 재투자',
          value: isDividendReinvestment,
          onChanged: onDividendReinvestmentChanged,
        ),
      ],
    );
  }
}
