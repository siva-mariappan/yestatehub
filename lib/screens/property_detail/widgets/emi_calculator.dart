import 'dart:math';
import 'package:flutter/material.dart';
import '../../../config/colors.dart';
import '../../../config/typography.dart';

class EMICalculator extends StatefulWidget {
  final double totalPrice;

  const EMICalculator({super.key, required this.totalPrice});

  @override
  State<EMICalculator> createState() => _EMICalculatorState();
}

class _EMICalculatorState extends State<EMICalculator> {
  bool _isExpanded = false;
  double _downPaymentPercent = 20;
  double _tenure = 20;
  double _interestRate = 8.5;

  double get _loanAmount => widget.totalPrice * (1 - _downPaymentPercent / 100);

  double get _monthlyEMI {
    final r = _interestRate / 12 / 100;
    final n = _tenure * 12;
    if (r == 0) return _loanAmount / n;
    return _loanAmount * r * pow(1 + r, n) / (pow(1 + r, n) - 1);
  }

  String _formatAmount(double amount) {
    if (amount >= 10000000) return '\u20B9${(amount / 10000000).toStringAsFixed(2)} Cr';
    if (amount >= 100000) return '\u20B9${(amount / 100000).toStringAsFixed(1)} L';
    if (amount >= 1000) return '\u20B9${(amount / 1000).toStringAsFixed(0)}K';
    return '\u20B9${amount.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: AppColors.cardShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Header
          GestureDetector(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Container(
              padding: const EdgeInsets.all(16),
              color: AppColors.primaryExtraLight,
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.calculate_rounded, color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('EMI Calculator', style: AppTypography.headingSmall),
                        Text(
                          'Est. EMI: ${_formatAmount(_monthlyEMI)}/mo',
                          style: AppTypography.labelMedium.copyWith(color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ),
          // Calculator body
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Down Payment
                  _buildSliderRow(
                    label: 'Down Payment',
                    value: _downPaymentPercent,
                    displayValue: '${_downPaymentPercent.toStringAsFixed(0)}%',
                    min: 10,
                    max: 50,
                    onChanged: (v) => setState(() => _downPaymentPercent = v),
                  ),
                  const SizedBox(height: 16),
                  // Tenure
                  _buildSliderRow(
                    label: 'Loan Tenure',
                    value: _tenure,
                    displayValue: '${_tenure.toStringAsFixed(0)} years',
                    min: 5,
                    max: 30,
                    onChanged: (v) => setState(() => _tenure = v),
                  ),
                  const SizedBox(height: 16),
                  // Interest Rate
                  _buildSliderRow(
                    label: 'Interest Rate',
                    value: _interestRate,
                    displayValue: '${_interestRate.toStringAsFixed(1)}%',
                    min: 6,
                    max: 14,
                    onChanged: (v) => setState(() => _interestRate = v),
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 16),
                  // Results
                  Row(
                    children: [
                      _resultCard('Loan Amount', _formatAmount(_loanAmount)),
                      const SizedBox(width: 12),
                      _resultCard('Monthly EMI', _formatAmount(_monthlyEMI)),
                      const SizedBox(width: 12),
                      _resultCard(
                        'Total Interest',
                        _formatAmount(_monthlyEMI * _tenure * 12 - _loanAmount),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            crossFadeState: _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }

  Widget _buildSliderRow({
    required String label,
    required double value,
    required String displayValue,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary)),
            Text(displayValue, style: AppTypography.labelLarge.copyWith(color: AppColors.primary)),
          ],
        ),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: AppColors.primaryLight,
            thumbColor: AppColors.primary,
            overlayColor: AppColors.primary.withOpacity(0.1),
            trackHeight: 4,
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _resultCard(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(color: AppColors.textTertiary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: AppTypography.labelLarge.copyWith(color: AppColors.textPrimary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
