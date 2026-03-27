import 'package:flutter/material.dart';
import '../../../config/colors.dart';
import '../../../config/typography.dart';
import '../../../models/property.dart';

class PriceTrendChart extends StatelessWidget {
  final String localityName;
  final List<PriceTrend> trends;

  const PriceTrendChart({
    super.key,
    required this.localityName,
    required this.trends,
  });

  @override
  Widget build(BuildContext context) {
    if (trends.isEmpty) return const SizedBox.shrink();

    final maxPrice = trends.map((t) => t.pricePerSqft).reduce((a, b) => a > b ? a : b);
    final minPrice = trends.map((t) => t.pricePerSqft).reduce((a, b) => a < b ? a : b);
    final range = maxPrice - minPrice;

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
          Text('Price Trends', style: AppTypography.headingMedium),
          const SizedBox(height: 4),
          Text(
            '$localityName — Price per sq.ft over 8 quarters',
            style: AppTypography.bodySmall,
          ),
          const SizedBox(height: 6),
          // Trend indicator
          Row(
            children: [
              const Icon(Icons.trending_up, size: 16, color: AppColors.primary),
              const SizedBox(width: 4),
              Text(
                '+${((maxPrice - minPrice) / minPrice * 100).toStringAsFixed(1)}% over 2 years',
                style: AppTypography.labelMedium.copyWith(color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Chart area
          SizedBox(
            height: 180,
            child: CustomPaint(
              size: Size.infinite,
              painter: _TrendChartPainter(
                trends: trends,
                minPrice: minPrice,
                maxPrice: maxPrice,
                range: range,
              ),
            ),
          ),
          const SizedBox(height: 8),
          // X-axis labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: trends.map((t) {
              return Text(
                t.quarter,
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textTertiary,
                  fontSize: 9,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _TrendChartPainter extends CustomPainter {
  final List<PriceTrend> trends;
  final double minPrice;
  final double maxPrice;
  final double range;

  _TrendChartPainter({
    required this.trends,
    required this.minPrice,
    required this.maxPrice,
    required this.range,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (trends.isEmpty) return;

    final w = size.width;
    final h = size.height;
    final padding = range * 0.1;

    // Grid lines
    final gridPaint = Paint()
      ..color = AppColors.border.withOpacity(0.5)
      ..strokeWidth = 0.5;

    for (int i = 0; i <= 4; i++) {
      final y = h * i / 4;
      canvas.drawLine(Offset(0, y), Offset(w, y), gridPaint);
    }

    // Line + fill path
    final linePaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.primary.withOpacity(0.2),
          AppColors.primary.withOpacity(0.02),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    final linePath = Path();
    final fillPath = Path();

    for (int i = 0; i < trends.length; i++) {
      final x = w * i / (trends.length - 1);
      final normalizedY = (trends[i].pricePerSqft - minPrice + padding) / (range + 2 * padding);
      final y = h - normalizedY * h;

      if (i == 0) {
        linePath.moveTo(x, y);
        fillPath.moveTo(x, h);
        fillPath.lineTo(x, y);
      } else {
        linePath.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    fillPath.lineTo(w, h);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(linePath, linePaint);

    // Dots
    final dotPaint = Paint()..color = AppColors.primary;
    final dotBorderPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < trends.length; i++) {
      final x = w * i / (trends.length - 1);
      final normalizedY = (trends[i].pricePerSqft - minPrice + padding) / (range + 2 * padding);
      final y = h - normalizedY * h;
      canvas.drawCircle(Offset(x, y), 4, dotPaint);
      canvas.drawCircle(Offset(x, y), 4, dotBorderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
