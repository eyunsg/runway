import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:runway/core/theme/app_colors.dart';
import 'package:runway/core/theme/app_typography.dart';
import 'button.dart';

String _formatCurrency(String value) {
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

String _unformatCurrency(String value) {
  return value.replaceAll(RegExp(r'[^0-9]'), '');
}

class _DigitsOnlySafeFormatter extends TextInputFormatter {
  const _DigitsOnlySafeFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final sanitized = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (sanitized == newValue.text) {
      return newValue;
    }

    return TextEditingValue(
      text: sanitized,
      selection: TextSelection.collapsed(offset: sanitized.length),
      composing: TextRange.empty,
    );
  }
}

class _DecimalNumberFormatter extends TextInputFormatter {
  const _DecimalNumberFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final source = newValue.text;

    if (source.isEmpty) {
      return newValue;
    }

    final buffer = StringBuffer();
    bool hasDot = false;

    for (int i = 0; i < source.length; i++) {
      final char = source[i];

      if (RegExp(r'[0-9]').hasMatch(char)) {
        buffer.write(char);
        continue;
      }

      if (char == '.' && !hasDot && buffer.isNotEmpty) {
        hasDot = true;
        buffer.write(char);
      }
    }

    final sanitized = buffer.toString();

    if (sanitized == newValue.text) {
      return newValue;
    }

    return TextEditingValue(
      text: sanitized,
      selection: TextSelection.collapsed(offset: sanitized.length),
      composing: TextRange.empty,
    );
  }
}

class AppPortfolioNameInputCard extends StatelessWidget {
  final TextEditingController? portfolioNameController;

  const AppPortfolioNameInputCard({super.key, this.portfolioNameController});

  @override
  Widget build(BuildContext context) {
    return _InputCardContainer(
      minHeight: 76,
      child: _InputCardTextField(
        controller: portfolioNameController,
        hintText: '포트폴리오 이름',
      ),
    );
  }
}

class AppTargetInputCard extends StatefulWidget {
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
  State<AppTargetInputCard> createState() => _AppTargetInputCardState();
}

class _AppTargetInputCardState extends State<AppTargetInputCard> {
  late FocusNode _targetEvaluationFocusNode;
  late FocusNode _targetDividendFocusNode;

  @override
  void initState() {
    super.initState();

    _targetEvaluationFocusNode = FocusNode();
    _targetDividendFocusNode = FocusNode();

    _targetEvaluationFocusNode.addListener(() {
      final controller = widget.targetEvaluationController;
      if (controller == null) return;

      if (_targetEvaluationFocusNode.hasFocus) {
        controller.value = controller.value.copyWith(
          text: _unformatCurrency(controller.text),
          selection: TextSelection.collapsed(
            offset: _unformatCurrency(controller.text).length,
          ),
          composing: TextRange.empty,
        );
      } else {
        final formatted = _formatCurrency(controller.text);
        controller.value = controller.value.copyWith(
          text: formatted,
          selection: TextSelection.collapsed(offset: formatted.length),
          composing: TextRange.empty,
        );
      }
    });

    _targetDividendFocusNode.addListener(() {
      final controller = widget.targetDividendController;
      if (controller == null) return;

      if (_targetDividendFocusNode.hasFocus) {
        controller.value = controller.value.copyWith(
          text: _unformatCurrency(controller.text),
          selection: TextSelection.collapsed(
            offset: _unformatCurrency(controller.text).length,
          ),
          composing: TextRange.empty,
        );
      } else {
        final formatted = _formatCurrency(controller.text);
        controller.value = controller.value.copyWith(
          text: formatted,
          selection: TextSelection.collapsed(offset: formatted.length),
          composing: TextRange.empty,
        );
      }
    });
  }

  @override
  void dispose() {
    _targetEvaluationFocusNode.dispose();
    _targetDividendFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _InputCardContainer(
      minHeight: 196,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _InputCardTextField(
            controller: widget.targetAgeController,
            hintText: '투자 기간 (년)',
            keyboardType: TextInputType.number,
            inputFormatters: const [_DigitsOnlySafeFormatter()],
          ),
          const SizedBox(height: 16),
          _InputCardTextField(
            controller: widget.targetEvaluationController,
            hintText: '목표 평가금 (₩)',
            focusNode: _targetEvaluationFocusNode,
            keyboardType: TextInputType.number,
            inputFormatters: const [_DigitsOnlySafeFormatter()],
            prefixText: '₩',
          ),
          const SizedBox(height: 16),
          _InputCardTextField(
            controller: widget.targetDividendController,
            hintText: '목표 배당금 (₩)',
            focusNode: _targetDividendFocusNode,
            keyboardType: TextInputType.number,
            inputFormatters: const [_DigitsOnlySafeFormatter()],
            prefixText: '₩',
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

  final TextEditingController? monthlyContributionController;

  final TextEditingController? annualGrowthRateController;
  final TextEditingController? dividendPerShareController;
  final TextEditingController? dividendGrowthRateController;

  final String? selectedAssetType;
  final String? selectedDividendCycle;
  final List<String> assetTypeOptions;
  final List<String> dividendCycleOptions;

  final ValueChanged<String?>? onAssetTypeChanged;
  final ValueChanged<String?>? onDividendCycleChanged;

  final VoidCallback? onAssetFieldsChanged;
  final ValueChanged<bool>? onDividendAssetChanged;
  final ValueChanged<bool>? onDividendReinvestmentChanged;

  final VoidCallback? onRemoveTap;

  final bool initialIsDividendAsset;
  final bool initialIsDividendReinvestment;

  const AppAssetInputCard({
    super.key,
    this.assetNameController,
    this.assetPriceController,
    this.initialInvestmentController,
    this.monthlyContributionController,
    this.annualGrowthRateController,
    this.dividendPerShareController,
    this.dividendGrowthRateController,
    this.selectedAssetType,
    this.selectedDividendCycle,
    required this.assetTypeOptions,
    required this.dividendCycleOptions,
    this.onAssetTypeChanged,
    this.onDividendCycleChanged,
    this.onAssetFieldsChanged,
    this.onDividendAssetChanged,
    this.onDividendReinvestmentChanged,
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

  late FocusNode _assetPriceFocusNode;
  late FocusNode _initialInvestmentFocusNode;
  late FocusNode _monthlyContributionFocusNode;
  late FocusNode _dividendPerShareFocusNode;

  TextEditingController? get _dividendPerShareController =>
      widget.dividendPerShareController;
  TextEditingController? get _dividendGrowthRateController =>
      widget.dividendGrowthRateController;

  void _notifyAssetFieldsChanged() {
    widget.onAssetFieldsChanged?.call();
  }

  @override
  void initState() {
    super.initState();
    _isDividendAsset = widget.initialIsDividendAsset;
    _isDividendReinvestment = widget.initialIsDividendReinvestment;
    _assetType = widget.selectedAssetType;
    _dividendCycle = widget.selectedDividendCycle;

    _assetPriceFocusNode = FocusNode();
    _initialInvestmentFocusNode = FocusNode();
    _monthlyContributionFocusNode = FocusNode();
    _dividendPerShareFocusNode = FocusNode();

    _assetPriceFocusNode.addListener(() {
      final controller = widget.assetPriceController;
      if (controller == null) return;

      if (_assetPriceFocusNode.hasFocus) {
        final unformatted = _unformatCurrency(controller.text);
        controller.value = controller.value.copyWith(
          text: unformatted,
          selection: TextSelection.collapsed(offset: unformatted.length),
          composing: TextRange.empty,
        );
      } else {
        final formatted = _formatCurrency(controller.text);
        controller.value = controller.value.copyWith(
          text: formatted,
          selection: TextSelection.collapsed(offset: formatted.length),
          composing: TextRange.empty,
        );
      }

      _notifyAssetFieldsChanged();
    });

    _initialInvestmentFocusNode.addListener(() {
      final controller = widget.initialInvestmentController;
      if (controller == null) return;

      if (_initialInvestmentFocusNode.hasFocus) {
        final unformatted = _unformatCurrency(controller.text);
        controller.value = controller.value.copyWith(
          text: unformatted,
          selection: TextSelection.collapsed(offset: unformatted.length),
          composing: TextRange.empty,
        );
      } else {
        final formatted = _formatCurrency(controller.text);
        controller.value = controller.value.copyWith(
          text: formatted,
          selection: TextSelection.collapsed(offset: formatted.length),
          composing: TextRange.empty,
        );
      }

      _notifyAssetFieldsChanged();
    });

    _monthlyContributionFocusNode.addListener(() {
      final controller = widget.monthlyContributionController;
      if (controller == null) return;

      if (_monthlyContributionFocusNode.hasFocus) {
        final unformatted = _unformatCurrency(controller.text);
        controller.value = controller.value.copyWith(
          text: unformatted,
          selection: TextSelection.collapsed(offset: unformatted.length),
          composing: TextRange.empty,
        );
      } else {
        final formatted = _formatCurrency(controller.text);
        controller.value = controller.value.copyWith(
          text: formatted,
          selection: TextSelection.collapsed(offset: formatted.length),
          composing: TextRange.empty,
        );
      }

      _notifyAssetFieldsChanged();
    });

    _dividendPerShareFocusNode.addListener(() {
      final controller = widget.dividendPerShareController;
      if (controller == null) return;

      if (_dividendPerShareFocusNode.hasFocus) {
        final unformatted = _unformatCurrency(controller.text);
        controller.value = controller.value.copyWith(
          text: unformatted,
          selection: TextSelection.collapsed(offset: unformatted.length),
          composing: TextRange.empty,
        );
      } else {
        final formatted = _formatCurrency(controller.text);
        controller.value = controller.value.copyWith(
          text: formatted,
          selection: TextSelection.collapsed(offset: formatted.length),
          composing: TextRange.empty,
        );
      }

      _notifyAssetFieldsChanged();
    });
  }

  @override
  void didUpdateWidget(covariant AppAssetInputCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.selectedAssetType != widget.selectedAssetType) {
      _assetType = widget.selectedAssetType;
    }
    if (oldWidget.selectedDividendCycle != widget.selectedDividendCycle) {
      _dividendCycle = widget.selectedDividendCycle;
    }
    if (oldWidget.initialIsDividendAsset != widget.initialIsDividendAsset) {
      _isDividendAsset = widget.initialIsDividendAsset;
    }
    if (oldWidget.initialIsDividendReinvestment !=
        widget.initialIsDividendReinvestment) {
      _isDividendReinvestment = widget.initialIsDividendReinvestment;
    }
  }

  @override
  void dispose() {
    _assetPriceFocusNode.dispose();
    _initialInvestmentFocusNode.dispose();
    _monthlyContributionFocusNode.dispose();
    _dividendPerShareFocusNode.dispose();
    super.dispose();
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

    widget.onDividendAssetChanged?.call(value);

    if (!value) {
      widget.onDividendCycleChanged?.call(null);
      widget.onDividendReinvestmentChanged?.call(false);
      _notifyAssetFieldsChanged();
    }
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
            onChanged: (_) => _notifyAssetFieldsChanged(),
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
            focusNode: _assetPriceFocusNode,
            keyboardType: TextInputType.number,
            inputFormatters: const [_DigitsOnlySafeFormatter()],
            prefixText: '₩',
            onChanged: (_) => _notifyAssetFieldsChanged(),
          ),
          const SizedBox(height: 16),
          _InputCardTextField(
            controller: widget.initialInvestmentController,
            hintText: '초기 투자금 (₩)',
            focusNode: _initialInvestmentFocusNode,
            keyboardType: TextInputType.number,
            inputFormatters: const [_DigitsOnlySafeFormatter()],
            prefixText: '₩',
            onChanged: (_) => _notifyAssetFieldsChanged(),
          ),
          const SizedBox(height: 16),

          _InputCardTextField(
            controller: widget.monthlyContributionController,
            hintText: '월 투자금 (₩)',
            focusNode: _monthlyContributionFocusNode,
            keyboardType: TextInputType.number,
            inputFormatters: const [_DigitsOnlySafeFormatter()],
            prefixText: '₩',
            onChanged: (_) => _notifyAssetFieldsChanged(),
          ),
          const SizedBox(height: 16),

          _InputCardTextField(
            controller: widget.annualGrowthRateController,
            hintText: '연 성장률 (%)',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: const [_DecimalNumberFormatter()],
            onChanged: (_) => _notifyAssetFieldsChanged(),
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
              dividendPerShareFocusNode: _dividendPerShareFocusNode,
              onDividendCycleChanged: (value) {
                setState(() => _dividendCycle = value);
                widget.onDividendCycleChanged?.call(value);
              },
              onDividendReinvestmentChanged: (value) {
                setState(() => _isDividendReinvestment = value);
                widget.onDividendReinvestmentChanged?.call(value);
              },
              onFieldsChanged: _notifyAssetFieldsChanged,
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
  final FocusNode? focusNode;
  final List<TextInputFormatter>? inputFormatters;
  final String? prefixText;
  final ValueChanged<String>? onChanged;

  const _InputCardTextField({
    required this.hintText,
    this.controller,
    this.keyboardType,
    this.focusNode,
    this.inputFormatters,
    this.prefixText,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        textInputAction: TextInputAction.done,
        onChanged: onChanged,
        style: AppTypography.body.m.copyWith(
          color: AppColors.natural.textColors.primary,
        ),
        cursorColor: AppColors.natural.textColors.primary,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: AppTypography.body.m.copyWith(
            color: AppColors.natural.textColors.secondary,
          ),
          prefixText: prefixText,
          prefixStyle: AppTypography.body.m.copyWith(
            color: AppColors.natural.textColors.primary,
          ),
          suffixText: hintText.contains('(%)') ? '%' : null,
          suffixStyle: AppTypography.body.m.copyWith(
            color: AppColors.natural.textColors.primary,
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
              'assets/icons/arrow_down.png',
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
  final FocusNode? dividendPerShareFocusNode;
  final VoidCallback? onFieldsChanged;

  const _DividendSection({
    this.dividendPerShareController,
    this.dividendGrowthRateController,
    required this.dividendCycle,
    required this.dividendCycleOptions,
    required this.isDividendReinvestment,
    required this.onDividendCycleChanged,
    required this.onDividendReinvestmentChanged,
    this.dividendPerShareFocusNode,
    this.onFieldsChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _InputCardTextField(
          controller: dividendPerShareController,
          hintText: '주당 배당금 (₩)',
          focusNode: dividendPerShareFocusNode,
          keyboardType: TextInputType.number,
          inputFormatters: const [_DigitsOnlySafeFormatter()],
          prefixText: '₩',
          onChanged: (_) => onFieldsChanged?.call(),
        ),
        const SizedBox(height: 16),
        _InputCardTextField(
          controller: dividendGrowthRateController,
          hintText: '배당 성장률 (%)',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: const [_DecimalNumberFormatter()],
          onChanged: (_) => onFieldsChanged?.call(),
        ),
        const SizedBox(height: 16),
        _InputCardSelectField(
          value: dividendCycle,
          hintText: '배당 주기',
          options: dividendCycleOptions,
          onChanged: (value) {
            onDividendCycleChanged(value);
            onFieldsChanged?.call();
          },
        ),
        const SizedBox(height: 16),
        _ToggleRow(
          label: '배당 재투자',
          value: isDividendReinvestment,
          onChanged: (value) {
            onDividendReinvestmentChanged(value);
            onFieldsChanged?.call();
          },
        ),
      ],
    );
  }
}
