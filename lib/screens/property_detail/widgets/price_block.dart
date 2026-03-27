import 'package:flutter/material.dart';
import '../../../config/colors.dart';
import '../../../config/typography.dart';
import '../../../models/property.dart';

class PriceBlock extends StatelessWidget {
  final Property property;

  const PriceBlock({super.key, required this.property});

  @override
  Widget build(BuildContext context) {
    final isRent = property.transactionType == TransactionType.rent ||
        property.transactionType == TransactionType.pg;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\u20B9${property.formattedPrice}',
                style: AppTypography.priceHero,
              ),
              if (isRent)
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 4),
                  child: Text(
                    '/month',
                    style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                  ),
                ),
              const Spacer(),
              if (property.pricePerSqft != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.primaryExtraLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '\u20B9${property.pricePerSqft!.toStringAsFixed(0)}/sq.ft',
                    style: AppTypography.labelMedium.copyWith(color: AppColors.primaryDark),
                  ),
                ),
            ],
          ),
          if (property.noBrokerage) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.amberLight,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.amber.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.savings_outlined, size: 16, color: AppColors.amber),
                  const SizedBox(width: 6),
                  Text(
                    'Zero Brokerage — Save up to \u20B9${_estimateSavings()}',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.amber,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _estimateSavings() {
    final savings = property.price * 0.02;
    if (savings >= 100000) {
      return '${(savings / 100000).toStringAsFixed(0)}K';
    }
    return savings.toStringAsFixed(0);
  }
}
