import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../config/colors.dart';
import '../../config/typography.dart';

/// Step 4: Media Upload (Photos & Video) — Real device gallery/camera integration
class AddPropertyScreen4 extends StatefulWidget {
  final Map<String, dynamic> data;
  final ValueChanged<Map<String, dynamic>> onUpdate;

  const AddPropertyScreen4({super.key, required this.data, required this.onUpdate});

  @override
  State<AddPropertyScreen4> createState() => _AddPropertyScreen4State();
}

class _PickedImage {
  final XFile file;
  final Uint8List? bytes; // For web preview
  final String name;
  final int size; // bytes

  _PickedImage({required this.file, this.bytes, required this.name, required this.size});

  String get sizeLabel {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

class _AddPropertyScreen4State extends State<AddPropertyScreen4> {
  final ImagePicker _picker = ImagePicker();
  final List<_PickedImage> _pickedImages = [];
  late String _videoUrl;
  XFile? _pickedVideo;
  bool _isPickingImages = false;

  @override
  void initState() {
    super.initState();
    _videoUrl = widget.data['videoUrl'] ?? '';
  }

  // ─── Pick from Gallery (multiple) ──────────────────────────────────
  Future<void> _pickFromGallery() async {
    if (_pickedImages.length >= 20) {
      _showSnackBar('Maximum 20 photos allowed', Colors.amber);
      return;
    }
    setState(() => _isPickingImages = true);
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (images.isNotEmpty) {
        final remaining = 20 - _pickedImages.length;
        final toAdd = images.take(remaining).toList();

        for (final img in toAdd) {
          final bytes = await img.readAsBytes();
          _pickedImages.add(_PickedImage(
            file: img,
            bytes: bytes,
            name: img.name,
            size: bytes.length,
          ));
        }
        setState(() {});
        _syncImages();

        if (images.length > remaining) {
          _showSnackBar('Only $remaining more photo(s) could be added (max 20)', Colors.amber);
        }
      }
    } catch (e) {
      debugPrint('Gallery pick error: $e');
      _showSnackBar('Failed to pick images', Colors.red);
    }
    if (mounted) setState(() => _isPickingImages = false);
  }

  // ─── Pick from Camera ──────────────────────────────────────────────
  Future<void> _pickFromCamera() async {
    if (_pickedImages.length >= 20) {
      _showSnackBar('Maximum 20 photos allowed', Colors.amber);
      return;
    }
    setState(() => _isPickingImages = true);
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _pickedImages.add(_PickedImage(
            file: image,
            bytes: bytes,
            name: image.name,
            size: bytes.length,
          ));
        });
        _syncImages();
      }
    } catch (e) {
      debugPrint('Camera pick error: $e');
      _showSnackBar('Failed to capture photo', Colors.red);
    }
    if (mounted) setState(() => _isPickingImages = false);
  }

  // ─── Pick Video ────────────────────────────────────────────────────
  Future<void> _pickVideo() async {
    try {
      final XFile? video = await _picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 5),
      );
      if (video != null) {
        setState(() {
          _pickedVideo = video;
          _videoUrl = video.name;
        });
        widget.onUpdate({'videoUrl': video.path});
      }
    } catch (e) {
      debugPrint('Video pick error: $e');
      _showSnackBar('Failed to pick video', Colors.red);
    }
  }

  void _removeImage(int index) {
    setState(() => _pickedImages.removeAt(index));
    _syncImages();
  }

  void _removeVideo() {
    setState(() {
      _pickedVideo = null;
      _videoUrl = '';
    });
    widget.onUpdate({'videoUrl': ''});
  }

  void _reorderImage(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final item = _pickedImages.removeAt(oldIndex);
      _pickedImages.insert(newIndex, item);
    });
    _syncImages();
  }

  void _syncImages() {
    // Convert picked images to base64 data URIs so they persist across sessions.
    // On Flutter Web, file.path gives blob: URLs which can't be persisted.
    final List<String> imageDataUris = [];
    for (final img in _pickedImages) {
      if (img.bytes != null) {
        final b64 = base64Encode(img.bytes!);
        imageDataUris.add('data:image/png;base64,$b64');
      } else {
        // Fallback to file path (native platforms)
        imageDataUris.add(img.file.path);
      }
    }
    widget.onUpdate({'images': imageDataUris});
  }

  void _showUploadOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text('Upload Photos', style: AppTypography.headingSmall),
              const SizedBox(height: 6),
              Text(
                'Choose how you want to add photos',
                style: AppTypography.bodySmall.copyWith(color: const Color(0xFF94A3B8)),
              ),
              const SizedBox(height: 24),
              // Gallery option
              _uploadOptionTile(
                icon: Icons.photo_library_rounded,
                color: const Color(0xFF10B981),
                title: 'Choose from Gallery',
                subtitle: 'Select multiple photos at once',
                onTap: () {
                  Navigator.pop(context);
                  _pickFromGallery();
                },
              ),
              const SizedBox(height: 12),
              // Camera option
              _uploadOptionTile(
                icon: Icons.camera_alt_rounded,
                color: const Color(0xFF3B82F6),
                title: 'Take a Photo',
                subtitle: 'Use your camera to capture',
                onTap: () {
                  Navigator.pop(context);
                  _pickFromCamera();
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _uploadOptionTile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.15)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w700)),
                  Text(subtitle, style: AppTypography.bodySmall.copyWith(color: const Color(0xFF64748B))),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 16, color: color),
          ],
        ),
      ),
    );
  }

  bool get _hasMinImages => _pickedImages.length >= 3;
  int get _remainingPhotos => 20 - _pickedImages.length;

  void _showSnackBar(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(color: Colors.white)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ========== PHOTOS SECTION ==========
          _buildSectionHeader(Icons.image_rounded, 'Upload Photos'),
          const SizedBox(height: 12),

          // Upload zone
          GestureDetector(
            onTap: _isPickingImages ? null : _showUploadOptions,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 160,
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withOpacity(0.04),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF10B981).withOpacity(0.4), width: 1.5),
              ),
              child: _isPickingImages
                  ? const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(color: Color(0xFF10B981), strokeWidth: 3),
                          SizedBox(height: 12),
                          Text('Processing images...', style: TextStyle(color: Color(0xFF64748B))),
                        ],
                      ),
                    )
                  : Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(Icons.add_a_photo_rounded, size: 28, color: Color(0xFF10B981)),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _pickedImages.isEmpty ? 'Upload Photos' : 'Add More Photos',
                            style: AppTypography.labelLarge.copyWith(
                              color: const Color(0xFF10B981),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Gallery or Camera  •  Min 3, Max 20',
                            style: AppTypography.bodySmall.copyWith(color: const Color(0xFF94A3B8)),
                          ),
                        ],
                      ),
                    ),
            ),
          ),

          const SizedBox(height: 14),

          // Status bar
          Row(
            children: [
              // Status badge
              if (_hasMinImages)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle_rounded, size: 14, color: Color(0xFF10B981)),
                      const SizedBox(width: 5),
                      Text('Minimum met', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: const Color(0xFF10B981))),
                    ],
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Add ${3 - _pickedImages.length} more photo${3 - _pickedImages.length != 1 ? 's' : ''}',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: const Color(0xFFF59E0B)),
                  ),
                ),
              const Spacer(),
              Text(
                '${_pickedImages.length}/20 Photos',
                style: AppTypography.labelSmall.copyWith(color: const Color(0xFF94A3B8)),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Image grid with previews
          if (_pickedImages.isNotEmpty) ...[
            ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              buildDefaultDragHandles: false,
              itemCount: _pickedImages.length,
              onReorder: _reorderImage,
              proxyDecorator: (child, index, animation) {
                return Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(14),
                  child: child,
                );
              },
              itemBuilder: (context, index) {
                final img = _pickedImages[index];
                return _buildImageTile(img, index, key: ValueKey('img_$index'));
              },
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Long press and drag to reorder  •  First image = cover photo',
                style: AppTypography.labelSmall.copyWith(color: const Color(0xFFCBD5E1)),
              ),
            ),
          ],

          const SizedBox(height: 28),

          // ========== VIDEO SECTION ==========
          _buildSectionHeader(Icons.videocam_rounded, 'Upload Video Tour'),
          const SizedBox(height: 12),

          GestureDetector(
            onTap: _videoUrl.isEmpty ? _pickVideo : null,
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6).withOpacity(0.04),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.3), width: 1.5),
              ),
              child: _videoUrl.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: const Color(0xFF3B82F6).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(Icons.video_library_rounded, size: 24, color: Color(0xFF3B82F6)),
                          ),
                          const SizedBox(height: 10),
                          Text('Upload Video Tour', style: AppTypography.labelLarge.copyWith(color: const Color(0xFF3B82F6), fontWeight: FontWeight.w600)),
                          Text('Optional  •  Max 5 minutes', style: AppTypography.bodySmall.copyWith(color: const Color(0xFF94A3B8))),
                        ],
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              color: const Color(0xFF3B82F6).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Stack(
                              alignment: Alignment.center,
                              children: [
                                Icon(Icons.movie_rounded, size: 30, color: Color(0xFF3B82F6)),
                              ],
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _pickedVideo?.name ?? 'Video Tour',
                                  style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w600),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text('Video added', style: AppTypography.bodySmall.copyWith(color: const Color(0xFF10B981))),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: _removeVideo,
                            child: Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: const Color(0xFFEF4444).withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close_rounded, size: 18, color: Color(0xFFEF4444)),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),

          const SizedBox(height: 28),

          // ========== TIPS SECTION ==========
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6).withOpacity(0.05),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.12)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B82F6).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.lightbulb_rounded, size: 16, color: Color(0xFF3B82F6)),
                    ),
                    const SizedBox(width: 10),
                    Text('Tips for Best Results', style: AppTypography.labelLarge.copyWith(color: const Color(0xFF3B82F6), fontWeight: FontWeight.w700)),
                  ],
                ),
                const SizedBox(height: 14),
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

  // ─── Widgets ───────────────────────────────────────────────────────────

  Widget _buildSectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 22, color: const Color(0xFF10B981)),
        const SizedBox(width: 8),
        Text(title, style: AppTypography.headingSmall.copyWith(fontWeight: FontWeight.w700)),
      ],
    );
  }

  Widget _buildImageTile(_PickedImage img, int index, {Key? key}) {
    final isCover = index == 0;

    return ReorderableDragStartListener(
      key: key!,
      index: index,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isCover ? const Color(0xFF10B981) : const Color(0xFFE2E8F0),
            width: isCover ? 2 : 1,
          ),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            // Drag handle
            Icon(Icons.drag_handle_rounded, size: 20, color: const Color(0xFFCBD5E1)),
            const SizedBox(width: 10),
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 64,
                height: 64,
                child: img.bytes != null
                    ? Image.memory(img.bytes!, fit: BoxFit.cover)
                    : Container(
                        color: const Color(0xFFF1F5F9),
                        child: const Icon(Icons.image_rounded, color: Color(0xFFCBD5E1)),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (isCover)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          margin: const EdgeInsets.only(right: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text('Cover', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.white)),
                        ),
                      Flexible(
                        child: Text(
                          img.name,
                          style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    img.sizeLabel,
                    style: AppTypography.labelSmall.copyWith(color: const Color(0xFF94A3B8)),
                  ),
                ],
              ),
            ),
            // Delete button
            GestureDetector(
              onTap: () => _removeImage(index),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close_rounded, size: 16, color: Color(0xFFEF4444)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipItem(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 5,
          height: 5,
          margin: const EdgeInsets.only(top: 7, right: 10),
          decoration: const BoxDecoration(color: Color(0xFF3B82F6), shape: BoxShape.circle),
        ),
        Expanded(
          child: Text(text, style: AppTypography.bodySmall.copyWith(color: const Color(0xFF475569), height: 1.4)),
        ),
      ],
    );
  }
}
