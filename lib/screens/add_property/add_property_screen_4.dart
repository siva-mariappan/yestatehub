import 'package:flutter/material.dart';
import '../../config/colors.dart';
import '../../config/typography.dart';

/// Step 4: Media Upload (Photos & Video)
class AddPropertyScreen4 extends StatefulWidget {
  final Map<String, dynamic> data;
  final ValueChanged<Map<String, dynamic>> onUpdate;

  const AddPropertyScreen4({super.key, required this.data, required this.onUpdate});

  @override
  State<AddPropertyScreen4> createState() => _AddPropertyScreen4State();
}

class _AddPropertyScreen4State extends State<AddPropertyScreen4> {
  late List<String> _images;
  late String _videoUrl;

  @override
  void initState() {
    super.initState();
    _images = List<String>.from(widget.data['images'] ?? []);
    _videoUrl = widget.data['videoUrl'] ?? '';
  }

  void _addImage() {
    if (_images.length < 20) {
      setState(() {
        // Mock image URL using Unsplash placeholder
        final imageUrl = 'https://images.unsplash.com/photo-${1600000000 + _images.length}?w=500&h=500';
        _images.add(imageUrl);
      });
      widget.onUpdate({'images': _images});
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
    widget.onUpdate({'images': _images});
  }

  void _addVideo() {
    setState(() {
      _videoUrl = 'https://youtu.be/dummyvideo${_videoUrl.isEmpty ? '1' : '2'}';
    });
    widget.onUpdate({'videoUrl': _videoUrl});
  }

  void _removeVideo() {
    setState(() {
      _videoUrl = '';
    });
    widget.onUpdate({'videoUrl': ''});
  }

  bool get _hasMinImages => _images.length >= 3;
  int get _remainingPhotos => 20 - _images.length;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ========== PHOTOS SECTION ==========
          _buildSectionHeader(Icons.image_rounded, 'Upload Photos'),
          const SizedBox(height: 12),

          // Upload zone with dotted border
          GestureDetector(
            onTap: _addImage,
            child: Container(
              height: 150,
              decoration: BoxDecoration(
                color: const Color(0xFF1DBAA6).withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF1DBAA6),
                  width: 1.5,
                  strokeAlign: BorderSide.strokeAlignInside,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.camera_alt_rounded,
                      size: 40,
                      color: const Color(0xFF1DBAA6).withOpacity(0.7),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Upload Photos',
                      style: AppTypography.labelLarge.copyWith(
                        color: const Color(0xFF1DBAA6),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Min 3, Max 20 photos',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Status badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (_hasMinImages)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle, size: 16, color: Color(0xFF4CAF50)),
                      const SizedBox(width: 6),
                      Text(
                        'Minimum met ✓',
                        style: AppTypography.labelSmall.copyWith(
                          color: const Color(0xFF4CAF50),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Add ${3 - _images.length} more photo${3 - _images.length != 1 ? 's' : ''}',
                    style: AppTypography.labelSmall.copyWith(
                      color: Colors.amber[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              Text(
                '${_images.length}/20 Photos',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Images grid
          if (_images.isNotEmpty)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: _images.length,
              itemBuilder: (context, index) {
                return _buildImageCard(index);
              },
            ),

          const SizedBox(height: 32),

          // ========== VIDEO SECTION ==========
          _buildSectionHeader(Icons.videocam_rounded, 'Upload Video Tour'),
          const SizedBox(height: 12),

          // Video upload zone
          GestureDetector(
            onTap: _videoUrl.isEmpty ? _addVideo : null,
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFF1DBAA6).withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF1DBAA6),
                  width: 1.5,
                ),
              ),
              child: _videoUrl.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.video_library_rounded,
                            size: 36,
                            color: const Color(0xFF1DBAA6).withOpacity(0.7),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Upload Video Tour',
                            style: AppTypography.labelLarge.copyWith(
                              color: const Color(0xFF1DBAA6),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Optional, max 5 min',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(12),
                      child: _buildVideoPreview(),
                    ),
            ),
          ),

          const SizedBox(height: 32),

          // ========== TIPS SECTION ==========
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFBBDEFB),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.lightbulb_outline,
                      size: 20,
                      color: Color(0xFF1976D2),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Tips for Best Results',
                      style: AppTypography.labelLarge.copyWith(
                        color: const Color(0xFF1976D2),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildTipItem('Upload clear, well-lit photos of every room'),
                const SizedBox(height: 8),
                _buildTipItem('Include exterior and neighbourhood shots'),
                const SizedBox(height: 8),
                _buildTipItem('Video walkthrough increases buyer interest by 40%'),
                const SizedBox(height: 8),
                _buildTipItem('First photo becomes your listing\'s cover image'),
              ],
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 24, color: const Color(0xFF1DBAA6)),
        const SizedBox(width: 8),
        Text(
          title,
          style: AppTypography.headingSmall.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildImageCard(int index) {
    return Stack(
      children: [
        // Image container
        Container(
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 100 + (index * 20) % 155, 150, 100 + (index * 30) % 155),
            borderRadius: BorderRadius.circular(10),
            border: index == 0
                ? Border.all(color: const Color(0xFF4CAF50), width: 2)
                : null,
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.image, size: 32, color: Colors.white70),
                const SizedBox(height: 8),
                Text(
                  'Photo ${index + 1}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Cover badge
        if (index == 0)
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Cover Photo',
                style: AppTypography.labelSmall.copyWith(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

        // Remove button
        Positioned(
          top: 6,
          right: 6,
          child: GestureDetector(
            onTap: () => _removeImage(index),
            child: Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                color: Color(0xFFF44336),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                size: 16,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVideoPreview() {
    return Row(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Icon(
                Icons.video_library,
                size: 32,
                color: Colors.black45,
              ),
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFF1DBAA6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow,
                  size: 20,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Property Tour.mp4',
                style: AppTypography.labelLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                '4:35 Duration',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: _removeVideo,
          child: Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: Color(0xFFF44336),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.close,
              size: 16,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTipItem(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.only(top: 8, right: 10),
          decoration: const BoxDecoration(
            color: Color(0xFF1976D2),
            shape: BoxShape.circle,
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textPrimary,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
