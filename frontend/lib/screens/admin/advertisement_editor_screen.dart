import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../config/colors.dart';
import '../../config/typography.dart';
import '../../models/advertisement.dart';
import '../../services/advertisement_store.dart';

/// Advertisement Editor/Manager Screen — Premium UI with text overlays,
/// font selection, color pickers, and live preview.
class AdvertisementEditorScreen extends StatefulWidget {
  const AdvertisementEditorScreen({super.key});

  @override
  State<AdvertisementEditorScreen> createState() =>
      _AdvertisementEditorScreenState();
}

class _AdvertisementEditorScreenState extends State<AdvertisementEditorScreen>
    with SingleTickerProviderStateMixin {
  final _store = AdvertisementStore.instance;
  final _picker = ImagePicker();

  // Controllers
  final _linkController = TextEditingController();
  final _titleController = TextEditingController();
  final _subtitleController = TextEditingController();
  final _buttonTextController = TextEditingController();

  // Editor state
  String? _editingAdId;
  Uint8List? _pickedImageBytes;
  String? _existingImageUrl;
  bool _isSaving = false;
  bool _showListOnMobile = true;

  // Text overlay state
  String _fontFamily = 'Poppins';
  double _titleSize = 28;
  double _subtitleSize = 14;
  int _titleColorValue = 0xFFFFFFFF;
  int _subtitleColorValue = 0xFFFFFFFF;
  int _buttonColorValue = 0xFF10B981;
  int _buttonTextColorValue = 0xFFFFFFFF;
  int _overlayColorValue = 0xFF000000;
  double _overlayOpacity = 0.3;
  String _textAlign = 'left';

  // Tab for editor sections
  late TabController _tabController;

  static const _fontFamilies = [
    'Poppins',
    'Roboto',
    'Playfair Display',
    'Montserrat',
    'Open Sans',
    'Lato',
    'Raleway',
    'Oswald',
    'Merriweather',
    'Nunito',
  ];

  static const _presetColors = [
    0xFFFFFFFF, // White
    0xFF000000, // Black
    0xFF10B981, // Emerald
    0xFF3B82F6, // Blue
    0xFFEF4444, // Red
    0xFFF59E0B, // Amber
    0xFF8B5CF6, // Violet
    0xFFEC4899, // Pink
    0xFF06B6D4, // Cyan
    0xFF84CC16, // Lime
    0xFFD97706, // Orange
    0xFF6366F1, // Indigo
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _store.addListener(_onStoreChanged);
  }

  @override
  void dispose() {
    _store.removeListener(_onStoreChanged);
    _linkController.dispose();
    _titleController.dispose();
    _subtitleController.dispose();
    _buttonTextController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _onStoreChanged() {
    if (mounted) setState(() {});
  }

  void _startNewAd() {
    setState(() {
      _editingAdId = null;
      _pickedImageBytes = null;
      _existingImageUrl = null;
      _linkController.clear();
      _titleController.clear();
      _subtitleController.clear();
      _buttonTextController.clear();
      _fontFamily = 'Poppins';
      _titleSize = 28;
      _subtitleSize = 14;
      _titleColorValue = 0xFFFFFFFF;
      _subtitleColorValue = 0xFFFFFFFF;
      _buttonColorValue = 0xFF10B981;
      _buttonTextColorValue = 0xFFFFFFFF;
      _overlayColorValue = 0xFF000000;
      _overlayOpacity = 0.3;
      _textAlign = 'left';
      _showListOnMobile = false;
      _tabController.index = 0;
    });
  }

  void _editAd(Advertisement ad) {
    setState(() {
      _editingAdId = ad.id;
      _pickedImageBytes = null;
      _existingImageUrl = ad.imageUrl.isNotEmpty ? ad.imageUrl : null;
      _linkController.text = ad.externalLink;
      _titleController.text = ad.title;
      _subtitleController.text = ad.subtitle;
      _buttonTextController.text = ad.buttonText;
      _fontFamily = ad.fontFamily;
      _titleSize = ad.titleSize;
      _subtitleSize = ad.subtitleSize;
      _titleColorValue = ad.titleColorValue;
      _subtitleColorValue = ad.subtitleColorValue;
      _buttonColorValue = ad.buttonColorValue;
      _buttonTextColorValue = ad.buttonTextColorValue;
      _overlayColorValue = ad.overlayColorValue;
      _overlayOpacity = ad.overlayOpacity;
      _textAlign = ad.textAlign;
      _showListOnMobile = false;
      _tabController.index = 0;
    });
  }

  void _cancelEdit() {
    setState(() {
      _editingAdId = null;
      _pickedImageBytes = null;
      _existingImageUrl = null;
      _linkController.clear();
      _titleController.clear();
      _subtitleController.clear();
      _buttonTextController.clear();
      _showListOnMobile = true;
    });
  }

  Future<void> _pickImage() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        imageQuality: 85,
      );
      if (picked != null) {
        final bytes = await picked.readAsBytes();
        setState(() => _pickedImageBytes = bytes);
      }
    } catch (e) {
      debugPrint('Image pick error: $e');
    }
  }

  void _removeImage() {
    setState(() {
      _pickedImageBytes = null;
      _existingImageUrl = null;
    });
  }

  Future<void> _saveAd() async {
    if (_pickedImageBytes == null &&
        (_existingImageUrl == null || _existingImageUrl!.isEmpty)) {
      _showSnack('Please select an image first', AppColors.error);
      return;
    }

    setState(() => _isSaving = true);

    String imageUrl = _existingImageUrl ?? '';
    if (_pickedImageBytes != null) {
      await Future.delayed(const Duration(milliseconds: 400));
      final b64 = base64Encode(_pickedImageBytes!);
      imageUrl = 'data:image/png;base64,$b64';
    }

    final link = _linkController.text.trim();
    final title = _titleController.text.trim();
    final subtitle = _subtitleController.text.trim();
    final buttonText = _buttonTextController.text.trim();

    if (_editingAdId != null) {
      _store.updateAd(
        _editingAdId!,
        imageUrl: imageUrl,
        externalLink: link,
        title: title,
        subtitle: subtitle,
        buttonText: buttonText,
        fontFamily: _fontFamily,
        titleSize: _titleSize,
        subtitleSize: _subtitleSize,
        titleColorValue: _titleColorValue,
        subtitleColorValue: _subtitleColorValue,
        buttonColorValue: _buttonColorValue,
        buttonTextColorValue: _buttonTextColorValue,
        overlayColorValue: _overlayColorValue,
        overlayOpacity: _overlayOpacity,
        textAlign: _textAlign,
      );
      _showSnack('Advertisement updated!', AppColors.primary);
    } else {
      final newAd = Advertisement(
        id: _store.generateId(),
        imageUrl: imageUrl,
        externalLink: link,
        isActive: true,
        createdAt: DateTime.now(),
        title: title,
        subtitle: subtitle,
        buttonText: buttonText,
        fontFamily: _fontFamily,
        titleSize: _titleSize,
        subtitleSize: _subtitleSize,
        titleColorValue: _titleColorValue,
        subtitleColorValue: _subtitleColorValue,
        buttonColorValue: _buttonColorValue,
        buttonTextColorValue: _buttonTextColorValue,
        overlayColorValue: _overlayColorValue,
        overlayOpacity: _overlayOpacity,
        textAlign: _textAlign,
      );
      _store.addAd(newAd);
      _showSnack('Advertisement published!', AppColors.primary);
    }

    setState(() {
      _isSaving = false;
      _editingAdId = null;
      _pickedImageBytes = null;
      _existingImageUrl = null;
      _linkController.clear();
      _titleController.clear();
      _subtitleController.clear();
      _buttonTextController.clear();
      _showListOnMobile = true;
    });
  }

  void _deleteAd(String id) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFFDC2626).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.delete_forever_rounded,
                    size: 28, color: Color(0xFFDC2626)),
              ),
              const SizedBox(height: 16),
              Text('Delete Advertisement',
                  style: AppTypography.headingSmall
                      .copyWith(color: const Color(0xFF0F172A))),
              const SizedBox(height: 10),
              Text(
                'This will remove the ad for ALL users. Continue?',
                style: AppTypography.bodyMedium
                    .copyWith(color: const Color(0xFF475569)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: Color(0xFF10B981)),
                        ),
                      ),
                      child: Text('Cancel',
                          style: AppTypography.labelMedium
                              .copyWith(color: const Color(0xFF10B981))),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        if (_editingAdId == id) _cancelEdit();
                        _store.removeAd(id);
                        _showSnack(
                            'Advertisement deleted', const Color(0xFFDC2626));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFDC2626),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                      ),
                      child: const Text('Delete'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSnack(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              color == AppColors.error
                  ? Icons.error_outline_rounded
                  : Icons.check_circle_rounded,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 10),
            Text(message,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w600)),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // ─── Build ────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width > 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildAppBar(isDesktop),
      body: isDesktop ? _buildDesktopBody() : _buildMobileBody(),
      floatingActionButton: (!isDesktop && _showListOnMobile)
          ? FloatingActionButton.extended(
              onPressed: _startNewAd,
              backgroundColor: const Color(0xFF10B981),
              icon: const Icon(Icons.add_rounded, color: Colors.white),
              label: const Text('New Ad',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w700)),
            )
          : null,
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDesktop) {
    final isNew = _editingAdId == null;
    final activeCount = _store.activeAds.length;

    String title;
    String subtitle;
    if (!isDesktop && !_showListOnMobile) {
      title = isNew ? 'New Advertisement' : 'Edit Advertisement';
      subtitle = 'Customize image, text & style';
    } else {
      title = 'Advertisement Manager';
      subtitle = '$activeCount active ad${activeCount == 1 ? '' : 's'}';
    }

    return AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF0F172A)),
        onPressed: () {
          if (!isDesktop && !_showListOnMobile) {
            _cancelEdit();
          } else {
            Navigator.pop(context);
          }
        },
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: AppTypography.headingSmall.copyWith(
                  color: const Color(0xFF0F172A),
                  fontWeight: FontWeight.w800)),
          Text(subtitle,
              style: AppTypography.bodySmall
                  .copyWith(color: const Color(0xFF475569))),
        ],
      ),
      actions: [
        if (!isDesktop && !_showListOnMobile)
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _isSaving
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Color(0xFF10B981))),
                  )
                : TextButton.icon(
                    onPressed: _saveAd,
                    icon: const Icon(Icons.cloud_upload_rounded,
                        size: 18, color: Color(0xFF10B981)),
                    label: Text(
                      _editingAdId != null ? 'Update' : 'Publish',
                      style: AppTypography.labelMedium.copyWith(
                          color: const Color(0xFF10B981),
                          fontWeight: FontWeight.w700),
                    ),
                  ),
          ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: const Color(0xFFE5E7EB)),
      ),
    );
  }

  // ─── Desktop layout ──────────────────────────────────────────────────

  Widget _buildDesktopBody() {
    return Row(
      children: [
        Expanded(flex: 2, child: _buildEditorPane()),
        Container(width: 1, color: const Color(0xFFE5E7EB)),
        Expanded(
          flex: 1,
          child: Container(color: Colors.white, child: _buildListPane()),
        ),
      ],
    );
  }

  // ─── Mobile layout ───────────────────────────────────────────────────

  Widget _buildMobileBody() {
    return _showListOnMobile ? _buildListPane() : _buildEditorPane();
  }

  // ═══════════════════════════════════════════════════════════════
  // EDITOR PANE — Tabbed: Image & Link | Text Overlay | Style
  // ═══════════════════════════════════════════════════════════════

  Widget _buildEditorPane() {
    final isNew = _editingAdId == null;

    return Column(
      children: [
        // Live Preview
        _buildLivePreview(),
        // Tab bar
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            labelColor: const Color(0xFF10B981),
            unselectedLabelColor: const Color(0xFF64748B),
            indicatorColor: const Color(0xFF10B981),
            indicatorWeight: 3,
            labelStyle: AppTypography.labelMedium
                .copyWith(fontWeight: FontWeight.w700),
            unselectedLabelStyle: AppTypography.labelMedium,
            tabs: const [
              Tab(text: 'Image & Link'),
              Tab(text: 'Text Overlay'),
              Tab(text: 'Style'),
            ],
          ),
        ),
        Container(height: 1, color: const Color(0xFFE5E7EB)),
        // Tab content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildImageLinkTab(),
              _buildTextOverlayTab(),
              _buildStyleTab(),
            ],
          ),
        ),
        // Save button
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
          child: SizedBox(
            height: 52,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _saveAd,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                disabledBackgroundColor:
                    const Color(0xFF10B981).withOpacity(0.5),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: _isSaving
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white)),
                        const SizedBox(width: 12),
                        Text('Uploading...',
                            style: AppTypography.labelLarge
                                .copyWith(color: Colors.white)),
                      ],
                    )
                  : Text(
                      isNew
                          ? 'Publish Advertisement'
                          : 'Update Advertisement',
                      style: AppTypography.labelLarge.copyWith(
                          color: Colors.white, fontWeight: FontWeight.w700),
                    ),
            ),
          ),
        ),
      ],
    );
  }

  // ─── Live Preview ─────────────────────────────────────────────────────

  Widget _buildLivePreview() {
    final hasImage = _pickedImageBytes != null ||
        (_existingImageUrl != null && _existingImageUrl!.isNotEmpty);
    final title = _titleController.text;
    final subtitle = _subtitleController.text;
    final buttonText = _buttonTextController.text;

    TextAlign align;
    switch (_textAlign) {
      case 'center':
        align = TextAlign.center;
        break;
      case 'right':
        align = TextAlign.right;
        break;
      default:
        align = TextAlign.left;
    }

    CrossAxisAlignment crossAlign;
    switch (_textAlign) {
      case 'center':
        crossAlign = CrossAxisAlignment.center;
        break;
      case 'right':
        crossAlign = CrossAxisAlignment.end;
        break;
      default:
        crossAlign = CrossAxisAlignment.start;
    }

    return Container(
      height: 200,
      width: double.infinity,
      color: const Color(0xFF1E293B),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Image
          if (hasImage) _buildPreviewImage(),
          // Overlay
          if (hasImage)
            Container(
              color: Color(_overlayColorValue).withOpacity(_overlayOpacity),
            ),
          // If no image, show placeholder
          if (!hasImage)
            Container(
              color: const Color(0xFF1E293B),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.preview_rounded,
                        size: 32, color: Color(0xFF475569)),
                    const SizedBox(height: 8),
                    Text('Live Preview',
                        style: AppTypography.bodyMedium
                            .copyWith(color: const Color(0xFF64748B))),
                  ],
                ),
              ),
            ),
          // Text overlays
          if (title.isNotEmpty || subtitle.isNotEmpty || buttonText.isNotEmpty)
            Positioned(
              left: 24,
              right: 24,
              bottom: 20,
              child: Column(
                crossAxisAlignment: crossAlign,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (title.isNotEmpty)
                    Text(
                      title,
                      textAlign: align,
                      style: TextStyle(
                        fontFamily: _fontFamily,
                        fontSize: _titleSize.clamp(12, 48),
                        fontWeight: FontWeight.w800,
                        color: Color(_titleColorValue),
                        shadows: const [
                          Shadow(
                              color: Colors.black54,
                              blurRadius: 6,
                              offset: Offset(0, 2)),
                        ],
                      ),
                    ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      textAlign: align,
                      style: TextStyle(
                        fontFamily: _fontFamily,
                        fontSize: _subtitleSize.clamp(10, 32),
                        fontWeight: FontWeight.w400,
                        color: Color(_subtitleColorValue),
                        shadows: const [
                          Shadow(
                              color: Colors.black38,
                              blurRadius: 4,
                              offset: Offset(0, 1)),
                        ],
                      ),
                    ),
                  ],
                  if (buttonText.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: Color(_buttonColorValue),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        buttonText,
                        style: TextStyle(
                          fontFamily: _fontFamily,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(_buttonTextColorValue),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          // Preview label
          Positioned(
            top: 8,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text('PREVIEW',
                  style: AppTypography.labelSmall.copyWith(
                      color: Colors.white70,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewImage() {
    if (_pickedImageBytes != null) {
      return Image.memory(_pickedImageBytes!, fit: BoxFit.cover);
    }
    if (_existingImageUrl != null && _existingImageUrl!.isNotEmpty) {
      if (_existingImageUrl!.startsWith('data:')) {
        try {
          final b64 = _existingImageUrl!.split(',').last;
          return Image.memory(base64Decode(b64), fit: BoxFit.cover);
        } catch (_) {
          return const SizedBox();
        }
      }
      return Image.network(_existingImageUrl!, fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const SizedBox());
    }
    return const SizedBox();
  }

  // ═══════════════════════════════════════════════════════════════
  // TAB 1: Image & Link
  // ═══════════════════════════════════════════════════════════════

  Widget _buildImageLinkTab() {
    final hasImage = _pickedImageBytes != null ||
        (_existingImageUrl != null && _existingImageUrl!.isNotEmpty);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image Upload
              _buildSectionCard(
                icon: Icons.image_rounded,
                title: 'Banner Image',
                subtitle: 'Upload an eye-catching banner image',
                child: Column(
                  children: [
                    // Image preview
                    if (hasImage)
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              height: 160,
                              width: double.infinity,
                              color: const Color(0xFFF1F5F9),
                              child: _buildPreviewImage(),
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: _removeImageBtn(),
                          ),
                        ],
                      ),
                    if (hasImage) const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _pickImage,
                        icon: Icon(
                            hasImage
                                ? Icons.swap_horiz_rounded
                                : Icons.add_photo_alternate_rounded,
                            size: 18,
                            color: const Color(0xFF10B981)),
                        label: Text(
                          hasImage ? 'Change Image' : 'Choose Image',
                          style: AppTypography.labelMedium.copyWith(
                              color: const Color(0xFF10B981),
                              fontWeight: FontWeight.w600),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF10B981)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    if (!hasImage) ...[
                      const SizedBox(height: 10),
                      _buildInfoChip(
                          'Recommended: 3:1 ratio (1200 x 400 px)'),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Link
              _buildSectionCard(
                icon: Icons.link_rounded,
                title: 'External Link',
                subtitle: 'Where should users go when they tap?',
                child: TextField(
                  controller: _linkController,
                  decoration: _inputDecoration(
                      'https://example.com', Icons.link_rounded),
                  style: AppTypography.bodyMedium,
                  keyboardType: TextInputType.url,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // TAB 2: Text Overlay
  // ═══════════════════════════════════════════════════════════════

  Widget _buildTextOverlayTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title
              _buildSectionCard(
                icon: Icons.title_rounded,
                title: 'Title Text',
                subtitle: 'Main heading displayed on the ad',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _titleController,
                      onChanged: (_) => setState(() {}),
                      decoration: _inputDecoration(
                          'e.g. Dream Homes Await', Icons.text_fields_rounded),
                      style: AppTypography.bodyMedium,
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Text('Size',
                            style: AppTypography.labelSmall
                                .copyWith(color: const Color(0xFF64748B))),
                        const SizedBox(width: 8),
                        Expanded(
                          child: SliderTheme(
                            data: SliderThemeData(
                              activeTrackColor: const Color(0xFF10B981),
                              inactiveTrackColor:
                                  const Color(0xFF10B981).withOpacity(0.15),
                              thumbColor: const Color(0xFF10B981),
                              overlayColor:
                                  const Color(0xFF10B981).withOpacity(0.1),
                              trackHeight: 4,
                              thumbShape: const RoundSliderThumbShape(
                                  enabledThumbRadius: 7),
                            ),
                            child: Slider(
                              value: _titleSize,
                              min: 14,
                              max: 48,
                              divisions: 17,
                              onChanged: (v) =>
                                  setState(() => _titleSize = v),
                            ),
                          ),
                        ),
                        Container(
                          width: 40,
                          alignment: Alignment.center,
                          child: Text('${_titleSize.round()}',
                              style: AppTypography.labelMedium.copyWith(
                                  color: const Color(0xFF0F172A),
                                  fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildColorRow('Title Color', _titleColorValue,
                        (c) => setState(() => _titleColorValue = c)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Subtitle
              _buildSectionCard(
                icon: Icons.short_text_rounded,
                title: 'Subtitle Text',
                subtitle: 'Supporting text below the title',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _subtitleController,
                      onChanged: (_) => setState(() {}),
                      decoration: _inputDecoration(
                          'e.g. Find your perfect property',
                          Icons.text_fields_rounded),
                      style: AppTypography.bodyMedium,
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Text('Size',
                            style: AppTypography.labelSmall
                                .copyWith(color: const Color(0xFF64748B))),
                        const SizedBox(width: 8),
                        Expanded(
                          child: SliderTheme(
                            data: SliderThemeData(
                              activeTrackColor: const Color(0xFF10B981),
                              inactiveTrackColor:
                                  const Color(0xFF10B981).withOpacity(0.15),
                              thumbColor: const Color(0xFF10B981),
                              overlayColor:
                                  const Color(0xFF10B981).withOpacity(0.1),
                              trackHeight: 4,
                              thumbShape: const RoundSliderThumbShape(
                                  enabledThumbRadius: 7),
                            ),
                            child: Slider(
                              value: _subtitleSize,
                              min: 10,
                              max: 32,
                              divisions: 11,
                              onChanged: (v) =>
                                  setState(() => _subtitleSize = v),
                            ),
                          ),
                        ),
                        Container(
                          width: 40,
                          alignment: Alignment.center,
                          child: Text('${_subtitleSize.round()}',
                              style: AppTypography.labelMedium.copyWith(
                                  color: const Color(0xFF0F172A),
                                  fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildColorRow('Subtitle Color', _subtitleColorValue,
                        (c) => setState(() => _subtitleColorValue = c)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Button Text
              _buildSectionCard(
                icon: Icons.smart_button_rounded,
                title: 'CTA Button',
                subtitle: 'Call-to-action button on the ad',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _buttonTextController,
                      onChanged: (_) => setState(() {}),
                      decoration: _inputDecoration(
                          'e.g. Explore Now', Icons.touch_app_rounded),
                      style: AppTypography.bodyMedium,
                    ),
                    const SizedBox(height: 14),
                    _buildColorRow('Button Color', _buttonColorValue,
                        (c) => setState(() => _buttonColorValue = c)),
                    const SizedBox(height: 10),
                    _buildColorRow('Button Text', _buttonTextColorValue,
                        (c) => setState(() => _buttonTextColorValue = c)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // TAB 3: Style
  // ═══════════════════════════════════════════════════════════════

  Widget _buildStyleTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Font Family
              _buildSectionCard(
                icon: Icons.font_download_rounded,
                title: 'Font Family',
                subtitle: 'Choose the typeface for your ad text',
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _fontFamilies.map((font) {
                    final isSelected = _fontFamily == font;
                    return GestureDetector(
                      onTap: () => setState(() => _fontFamily = font),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF10B981).withOpacity(0.1)
                              : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF10B981)
                                : const Color(0xFFE5E7EB),
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Text(
                          font,
                          style: TextStyle(
                            fontFamily: font,
                            fontSize: 13,
                            fontWeight:
                                isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected
                                ? const Color(0xFF10B981)
                                : const Color(0xFF475569),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
              // Text Alignment
              _buildSectionCard(
                icon: Icons.format_align_left_rounded,
                title: 'Text Alignment',
                subtitle: 'Position of text on the banner',
                child: Row(
                  children: [
                    _buildAlignButton('left', Icons.format_align_left_rounded),
                    const SizedBox(width: 10),
                    _buildAlignButton(
                        'center', Icons.format_align_center_rounded),
                    const SizedBox(width: 10),
                    _buildAlignButton(
                        'right', Icons.format_align_right_rounded),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Overlay
              _buildSectionCard(
                icon: Icons.gradient_rounded,
                title: 'Image Overlay',
                subtitle: 'Darken the image for better text readability',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('Opacity',
                            style: AppTypography.labelSmall
                                .copyWith(color: const Color(0xFF64748B))),
                        const SizedBox(width: 8),
                        Expanded(
                          child: SliderTheme(
                            data: SliderThemeData(
                              activeTrackColor: const Color(0xFF10B981),
                              inactiveTrackColor:
                                  const Color(0xFF10B981).withOpacity(0.15),
                              thumbColor: const Color(0xFF10B981),
                              overlayColor:
                                  const Color(0xFF10B981).withOpacity(0.1),
                              trackHeight: 4,
                              thumbShape: const RoundSliderThumbShape(
                                  enabledThumbRadius: 7),
                            ),
                            child: Slider(
                              value: _overlayOpacity,
                              min: 0,
                              max: 0.8,
                              divisions: 16,
                              onChanged: (v) =>
                                  setState(() => _overlayOpacity = v),
                            ),
                          ),
                        ),
                        Container(
                          width: 46,
                          alignment: Alignment.center,
                          child: Text(
                              '${(_overlayOpacity * 100).round()}%',
                              style: AppTypography.labelMedium.copyWith(
                                  color: const Color(0xFF0F172A),
                                  fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _buildColorRow('Overlay Color', _overlayColorValue,
                        (c) => setState(() => _overlayColorValue = c)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // SHARED WIDGETS
  // ═══════════════════════════════════════════════════════════════

  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, size: 18, color: const Color(0xFF10B981)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: AppTypography.labelLarge.copyWith(
                            color: const Color(0xFF0F172A),
                            fontWeight: FontWeight.w700)),
                    Text(subtitle,
                        style: AppTypography.bodySmall
                            .copyWith(color: const Color(0xFF64748B), fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _buildColorRow(
      String label, int currentValue, ValueChanged<int> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label,
                style: AppTypography.labelSmall
                    .copyWith(color: const Color(0xFF64748B))),
            const Spacer(),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: Color(currentValue),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: currentValue == 0xFFFFFFFF
                      ? const Color(0xFFE5E7EB)
                      : Colors.transparent,
                ),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 4,
                      offset: const Offset(0, 1)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: _presetColors.map((color) {
            final isSelected = currentValue == color;
            return GestureDetector(
              onTap: () => onChanged(color),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Color(color),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF10B981)
                        : color == 0xFFFFFFFF
                            ? const Color(0xFFE5E7EB)
                            : Colors.transparent,
                    width: isSelected ? 2.5 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                              color:
                                  const Color(0xFF10B981).withOpacity(0.3),
                              blurRadius: 6)
                        ]
                      : null,
                ),
                child: isSelected
                    ? Icon(Icons.check_rounded,
                        size: 16,
                        color: color == 0xFFFFFFFF || color == 0xFFF59E0B
                            ? const Color(0xFF0F172A)
                            : Colors.white)
                    : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAlignButton(String value, IconData icon) {
    final isSelected = _textAlign == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _textAlign = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF10B981).withOpacity(0.1)
                : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF10B981)
                  : const Color(0xFFE5E7EB),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Icon(icon,
              size: 22,
              color: isSelected
                  ? const Color(0xFF10B981)
                  : const Color(0xFF94A3B8)),
        ),
      ),
    );
  }

  Widget _buildInfoChip(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF10B981).withOpacity(0.06),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded,
              size: 14, color: Color(0xFF10B981)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: AppTypography.bodySmall.copyWith(
                    color: const Color(0xFF10B981), fontSize: 11)),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle:
          AppTypography.bodyMedium.copyWith(color: const Color(0xFF94A3B8)),
      prefixIcon: Icon(icon, color: const Color(0xFF94A3B8), size: 20),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF10B981), width: 1.5)),
      contentPadding: const EdgeInsets.symmetric(vertical: 14),
    );
  }

  Widget _removeImageBtn() {
    return GestureDetector(
      onTap: _removeImage,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.close_rounded, size: 18, color: Colors.white),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // LIST PANE
  // ═══════════════════════════════════════════════════════════════

  Widget _buildListPane() {
    final ads = _store.ads;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('All Ads',
                      style: AppTypography.headingSmall.copyWith(
                          color: const Color(0xFF0F172A),
                          fontWeight: FontWeight.w800)),
                  Text(
                      '${ads.length} advertisement${ads.length == 1 ? '' : 's'}',
                      style: AppTypography.bodySmall
                          .copyWith(color: const Color(0xFF475569))),
                ],
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _startNewAd,
                icon: const Icon(Icons.add_rounded,
                    size: 18, color: Colors.white),
                label: const Text('Add Card',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: Color(0xFFE5E7EB)),
        Expanded(
          child: ads.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.inbox_rounded,
                          size: 56, color: const Color(0xFFCBD5E1)),
                      const SizedBox(height: 14),
                      Text('No advertisements yet',
                          style: AppTypography.bodyLarge
                              .copyWith(color: const Color(0xFF94A3B8))),
                      const SizedBox(height: 6),
                      Text('Click Add Card to get started',
                          style: AppTypography.bodySmall
                              .copyWith(color: const Color(0xFFCBD5E1))),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: ads.length,
                  itemBuilder: (context, index) =>
                      _buildAdListTile(ads[index], index),
                ),
        ),
      ],
    );
  }

  Widget _buildAdListTile(Advertisement ad, int index) {
    final isSelected = _editingAdId == ad.id;
    final displayTitle =
        ad.title.isNotEmpty ? ad.title : 'Ad #${index + 1}';

    return GestureDetector(
      onTap: () => _editAd(ad),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF10B981).withOpacity(0.06)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF10B981)
                : const Color(0xFFE5E7EB),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 80,
                height: 56,
                color: const Color(0xFFF1F5F9),
                child: ad.imageUrl.isNotEmpty
                    ? (ad.imageUrl.startsWith('data:')
                        ? Image.memory(
                            base64Decode(ad.imageUrl.split(',').last),
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                                Icons.image_rounded,
                                size: 24,
                                color: Color(0xFFCBD5E1)))
                        : Image.network(ad.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                                Icons.image_rounded,
                                size: 24,
                                color: Color(0xFFCBD5E1))))
                    : const Icon(Icons.image_rounded,
                        size: 24, color: Color(0xFFCBD5E1)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(displayTitle,
                            style: AppTypography.labelLarge.copyWith(
                                color: const Color(0xFF0F172A),
                                fontWeight: FontWeight.w700),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: ad.isActive
                              ? const Color(0xFF10B981).withOpacity(0.1)
                              : const Color(0xFF94A3B8).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          ad.isActive ? 'Active' : 'Inactive',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: ad.isActive
                                ? const Color(0xFF10B981)
                                : const Color(0xFF94A3B8),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    ad.subtitle.isNotEmpty
                        ? ad.subtitle
                        : ad.externalLink.isNotEmpty
                            ? ad.externalLink
                            : 'No details',
                    style: AppTypography.bodySmall
                        .copyWith(color: const Color(0xFF475569)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => _deleteAd(ad.id),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFDC2626).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.delete_outline_rounded,
                    size: 18, color: Color(0xFFDC2626)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
