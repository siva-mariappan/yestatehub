import 'dart:async';
import 'package:flutter/material.dart';
import '../../config/colors.dart';
import '../../config/typography.dart';

class AdBanner {
  final String id;
  final String title;
  final String subtitle;
  final String imageUrl;
  final String ctaText;
  final Color bgColor;

  const AdBanner({
    required this.id,
    required this.title,
    required this.subtitle,
    this.imageUrl = '',
    this.ctaText = 'Learn More',
    this.bgColor = const Color(0xFF10B981),
  });
}

class AdCarousel extends StatefulWidget {
  final List<AdBanner> ads;
  final double height;

  const AdCarousel({super.key, required this.ads, this.height = 180});

  @override
  State<AdCarousel> createState() => _AdCarouselState();
}

class _AdCarouselState extends State<AdCarousel> {
  late PageController _controller;
  int _currentPage = 0;
  Timer? _autoPlayTimer;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
    _startAutoPlay();
  }

  void _startAutoPlay() {
    _autoPlayTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      final next = (_currentPage + 1) % widget.ads.length;
      _controller.animateToPage(next,
          duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
    });
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.ads.isEmpty) return const SizedBox.shrink();
    return Column(
      children: [
        SizedBox(
          height: widget.height,
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.ads.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (context, index) => _buildAdCard(widget.ads[index]),
          ),
        ),
        const SizedBox(height: 12),
        // Dot indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.ads.length, (i) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: _currentPage == i ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _currentPage == i ? AppColors.primary : AppColors.border,
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildAdCard(AdBanner ad) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [ad.bgColor, ad.bgColor.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: ad.bgColor.withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(32),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  ad.title,
                  style: AppTypography.headingMedium.copyWith(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Text(
                  ad.subtitle,
                  style: AppTypography.bodyMedium.copyWith(color: Colors.white.withOpacity(0.85), fontSize: 16, height: 1.5),
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    ad.ctaText,
                    style: AppTypography.buttonMedium.copyWith(color: ad.bgColor, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          Container(
            width: 130,
            height: 130,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(24),
            ),
            child: ad.imageUrl.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.network(ad.imageUrl, fit: BoxFit.cover),
                  )
                : const Icon(Icons.campaign_rounded, size: 52, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

// ── Default mock ads ──
final List<AdBanner> mockAds = [
  const AdBanner(
    id: 'ad1',
    title: 'Zero Brokerage Properties',
    subtitle: 'Save thousands — connect directly with owners on YEstateHub',
    ctaText: 'Explore Now',
    bgColor: AppColors.primary,
  ),
  const AdBanner(
    id: 'ad2',
    title: 'Home Interiors Starting \u20B999/sq.ft',
    subtitle: 'Transform your space with professional interior design',
    ctaText: 'Get Quote',
    bgColor: AppColors.navy,
  ),
  const AdBanner(
    id: 'ad3',
    title: 'Pay Rent & Earn Cashback',
    subtitle: 'Pay via credit card and get up to 2% cashback every month',
    ctaText: 'Pay Now',
    bgColor: Color(0xFFD97706),
  ),
];
