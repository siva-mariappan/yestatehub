import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../config/colors.dart';
import '../../../config/typography.dart';

class PhotoGallery extends StatefulWidget {
  final List<String> images;
  final double? height;

  const PhotoGallery({super.key, required this.images, this.height});

  @override
  State<PhotoGallery> createState() => _PhotoGalleryState();
}

class _PhotoGalleryState extends State<PhotoGallery> {
  final PageController _controller = PageController();
  int _current = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goTo(int page) {
    if (page < 0 || page >= widget.images.length) return;
    _controller.animateToPage(page, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.images.isEmpty) {
      return Container(
        height: widget.height ?? 400,
        color: AppColors.divider,
        child: const Center(
          child: Icon(Icons.image_not_supported_outlined, size: 48, color: AppColors.textTertiary),
        ),
      );
    }

    return SizedBox(
      height: widget.height ?? 400,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Page view
          PageView.builder(
            controller: _controller,
            itemCount: widget.images.length,
            onPageChanged: (i) => setState(() => _current = i),
            itemBuilder: (context, index) {
              final imgUrl = widget.images[index];
              ImageProvider imgProvider;
              if (imgUrl.startsWith('data:image/')) {
                try {
                  final b64 = imgUrl.split(',').last;
                  imgProvider = MemoryImage(base64Decode(b64));
                } catch (_) {
                  imgProvider = const AssetImage('assets/images/placeholder.png');
                }
              } else {
                imgProvider = NetworkImage(imgUrl);
              }
              return Container(
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  image: DecorationImage(
                    image: imgProvider,
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),

          // Left arrow
          if (widget.images.length > 1)
            Positioned(
              left: 16,
              top: 0,
              bottom: 0,
              child: Center(
                child: _arrowButton(Icons.chevron_left, () => _goTo(_current - 1)),
              ),
            ),

          // Right arrow
          if (widget.images.length > 1)
            Positioned(
              right: 16,
              top: 0,
              bottom: 0,
              child: Center(
                child: _arrowButton(Icons.chevron_right, () => _goTo(_current + 1)),
              ),
            ),

          // Photo counter badge (top-right)
          if (widget.images.length > 1)
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.photo_camera_outlined, size: 14, color: Colors.white),
                    const SizedBox(width: 6),
                    Text(
                      '${_current + 1}/${widget.images.length}',
                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),

          // Dot indicators (bottom center)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.images.length, (index) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: _current == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _current == index ? AppColors.primary : Colors.white.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          ),

          // "Tap to expand" label (bottom-left)
          Positioned(
            bottom: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.zoom_out_map, size: 14, color: Colors.white),
                  SizedBox(width: 6),
                  Text(
                    'Tap to expand',
                    style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _arrowButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Center(child: Icon(icon, size: 24, color: AppColors.textPrimary)),
      ),
    );
  }
}
