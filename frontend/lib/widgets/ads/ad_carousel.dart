import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/colors.dart';
import '../../config/typography.dart';
import '../../models/advertisement.dart';
import '../../services/advertisement_store.dart';
import '../../screens/admin/advertisement_editor_screen.dart';

/// Full-width image-based ad carousel.
/// Shows advertisements from AdvertisementStore.
/// Admin users see an Edit button on each card.
class AdCarousel extends StatefulWidget {
  final bool isAdmin;
  final double desktopHeight;
  final double mobileHeight;

  const AdCarousel({
    super.key,
    this.isAdmin = false,
    this.desktopHeight = 600,
    this.mobileHeight = 420,
  });

  @override
  State<AdCarousel> createState() => _AdCarouselState();
}

class _AdCarouselState extends State<AdCarousel> {
  late PageController _controller;
  int _currentPage = 0;
  Timer? _autoPlayTimer;
  final _store = AdvertisementStore.instance;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
    _store.addListener(_onStoreChanged);
    _startAutoPlay();
  }

  void _onStoreChanged() {
    if (mounted) setState(() {});
  }

  void _startAutoPlay() {
    _autoPlayTimer?.cancel();
    _autoPlayTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (!mounted) return;
      final ads = _store.activeAds;
      if (ads.isEmpty) return;
      final next = (_currentPage + 1) % ads.length;
      if (_controller.hasClients) {
        _controller.animateToPage(next,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut);
      }
    });
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _controller.dispose();
    _store.removeListener(_onStoreChanged);
    super.dispose();
  }

  void _openEditor() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AdvertisementEditorScreen()),
    ).then((_) {
      // Refresh when coming back from editor
      if (mounted) setState(() {});
    });
  }

  Future<void> _launchLink(String url) async {
    if (url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri != null) {
      try {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    final height = isMobile ? widget.mobileHeight : widget.desktopHeight;
    final ads = _store.activeAds;

    // Empty state — placeholder card
    if (ads.isEmpty) {
      return _buildPlaceholder(height);
    }

    return Column(
      children: [
        SizedBox(
          height: height,
          child: PageView.builder(
            controller: _controller,
            itemCount: ads.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (context, index) => _buildAdCard(ads[index], height),
          ),
        ),
        const SizedBox(height: 12),
        // Expanding dot indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(ads.length, (i) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: _currentPage == i ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _currentPage == i
                    ? const Color(0xFF10B981)
                    : AppColors.border,
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
      ],
    );
  }

  /// Build the appropriate image widget for an ad (supports base64 data URIs and network URLs)
  Widget _buildAdImage(String imageUrl) {
    if (imageUrl.startsWith('data:')) {
      // Base64 data URI — decode and display from memory
      try {
        final b64 = imageUrl.split(',').last;
        final bytes = base64Decode(b64);
        return Image.memory(bytes, fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _imagePlaceholder());
      } catch (_) {
        return _imagePlaceholder();
      }
    }
    // Network URL
    return Image.network(imageUrl, fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _imagePlaceholder());
  }

  Widget _imagePlaceholder() {
    return Container(
      color: const Color(0xFFF1F5F9),
      child: const Center(
        child: Icon(Icons.image_rounded, size: 48, color: Color(0xFFCBD5E1)),
      ),
    );
  }

  Widget _buildAdCard(Advertisement ad, double height) {
    TextAlign textAlign;
    switch (ad.textAlign) {
      case 'center':
        textAlign = TextAlign.center;
        break;
      case 'right':
        textAlign = TextAlign.right;
        break;
      default:
        textAlign = TextAlign.left;
    }

    CrossAxisAlignment crossAlign;
    switch (ad.textAlign) {
      case 'center':
        crossAlign = CrossAxisAlignment.center;
        break;
      case 'right':
        crossAlign = CrossAxisAlignment.end;
        break;
      default:
        crossAlign = CrossAxisAlignment.start;
    }

    final hasTextOverlay =
        ad.title.isNotEmpty || ad.subtitle.isNotEmpty || ad.buttonText.isNotEmpty;

    return GestureDetector(
      onTap: () => _launchLink(ad.externalLink),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 0),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRect(
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Full-width image
              ad.imageUrl.isNotEmpty
                  ? _buildAdImage(ad.imageUrl)
                  : _imagePlaceholder(),
              // Overlay for text readability
              if (hasTextOverlay && ad.imageUrl.isNotEmpty)
                Container(
                  color: Color(ad.overlayColorValue)
                      .withOpacity(ad.overlayOpacity),
                ),
              // Text overlays
              if (hasTextOverlay)
                Positioned(
                  left: 24,
                  right: 24,
                  bottom: 28,
                  child: Column(
                    crossAxisAlignment: crossAlign,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (ad.title.isNotEmpty)
                        Text(
                          ad.title,
                          textAlign: textAlign,
                          style: TextStyle(
                            fontFamily: ad.fontFamily,
                            fontSize: ad.titleSize,
                            fontWeight: FontWeight.w800,
                            color: Color(ad.titleColorValue),
                            shadows: const [
                              Shadow(
                                  color: Colors.black54,
                                  blurRadius: 6,
                                  offset: Offset(0, 2)),
                            ],
                          ),
                        ),
                      if (ad.subtitle.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          ad.subtitle,
                          textAlign: textAlign,
                          style: TextStyle(
                            fontFamily: ad.fontFamily,
                            fontSize: ad.subtitleSize,
                            fontWeight: FontWeight.w400,
                            color: Color(ad.subtitleColorValue),
                            shadows: const [
                              Shadow(
                                  color: Colors.black38,
                                  blurRadius: 4,
                                  offset: Offset(0, 1)),
                            ],
                          ),
                        ),
                      ],
                      if (ad.buttonText.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          decoration: BoxDecoration(
                            color: Color(ad.buttonColorValue),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            ad.buttonText,
                            style: TextStyle(
                              fontFamily: ad.fontFamily,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(ad.buttonTextColorValue),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              // Admin edit button
              if (widget.isAdmin)
                Positioned(
                  top: 12,
                  right: 12,
                  child: GestureDetector(
                    onTap: _openEditor,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2)),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.edit_rounded,
                              size: 14, color: Colors.white),
                          const SizedBox(width: 5),
                          Text('Edit',
                              style: AppTypography.labelSmall.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(double height) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.image_rounded,
                    size: 56, color: const Color(0xFFCBD5E1)),
                const SizedBox(height: 12),
                Text('Advertisement Space',
                    style: AppTypography.bodyLarge
                        .copyWith(color: const Color(0xFF94A3B8))),
              ],
            ),
          ),
          // Admin "Edit Ad" button
          if (widget.isAdmin)
            Positioned(
              top: 12,
              right: 12,
              child: GestureDetector(
                onTap: _openEditor,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 6,
                          offset: const Offset(0, 2)),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.edit_rounded,
                          size: 15, color: Colors.white),
                      const SizedBox(width: 6),
                      Text('Edit Ad',
                          style: AppTypography.labelMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
