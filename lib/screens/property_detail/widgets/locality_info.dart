import 'package:flutter/material.dart';
import '../../../config/colors.dart';
import '../../../config/typography.dart';
import '../../../models/property.dart';

class LocalityInfo extends StatelessWidget {
  final String localityName;
  final LocalityScore score;

  const LocalityInfo({
    super.key,
    required this.localityName,
    required this.score,
  });

  @override
  Widget build(BuildContext context) {
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
            children: [
              Text('Locality Score', style: AppTypography.headingMedium),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${score.overall.toStringAsFixed(1)}/5',
                  style: AppTypography.labelLarge.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            localityName,
            style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),
          _buildScoreBar('Connectivity', score.connectivity),
          const SizedBox(height: 12),
          _buildScoreBar('Safety', score.safety),
          const SizedBox(height: 12),
          _buildScoreBar('Lifestyle', score.lifestyle),
          const SizedBox(height: 12),
          _buildScoreBar('Environment', score.environment),
          const SizedBox(height: 12),
          _buildScoreBar('Value for Money', score.valueForMoney),
          const SizedBox(height: 20),
          // Map placeholder
          Container(
            height: 160,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.map_rounded, size: 36, color: AppColors.textTertiary),
                  const SizedBox(height: 8),
                  Text(
                    'Google Maps — $localityName',
                    style: AppTypography.bodySmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Schools, Hospitals, Metro nearby',
                    style: AppTypography.labelSmall.copyWith(color: AppColors.textTertiary),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreBar(String label, double value) {
    return Row(
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value / 5,
              backgroundColor: AppColors.primaryLight,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 8,
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 28,
          child: Text(
            value.toStringAsFixed(1),
            style: AppTypography.labelMedium.copyWith(color: AppColors.primary),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
