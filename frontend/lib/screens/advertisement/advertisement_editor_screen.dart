import 'package:flutter/material.dart';
import '../../config/colors.dart';
import '../../config/typography.dart';
import '../../config/responsive.dart';

/// Advertisement Editor — Create and manage property advertisements
class AdvertisementEditorScreen extends StatefulWidget {
  const AdvertisementEditorScreen({super.key});

  @override
  State<AdvertisementEditorScreen> createState() => _AdvertisementEditorScreenState();
}

class _AdvertisementEditorScreenState extends State<AdvertisementEditorScreen> {
  final _titleController = TextEditingController(text: 'Premium 3 BHK in Gachibowli');
  final _subtitleController = TextEditingController(text: 'Starting at 85L — Zero Brokerage');
  final _ctaController = TextEditingController(text: 'View Details');
  final _linkController = TextEditingController(text: 'https://yestatehub.com/property/123');

  String _adType = 'Banner';
  String _placement = 'Home Page';
  String _status = 'Draft';
  Color _bgColor = AppColors.navy;
  DateTimeRange? _dateRange;

  // Existing ads
  final _existingAds = [
    _Ad('Premium Villas in Kokapet', 'Banner', 'Home Page', 'Active', '1,284 views', '45 clicks'),
    _Ad('Zero Brokerage — 2 BHK Kondapur', 'Card', 'Listing Page', 'Active', '892 views', '32 clicks'),
    _Ad('Invest in Hyderabad Real Estate', 'Banner', 'Home Page', 'Paused', '2,100 views', '78 clicks'),
    _Ad('New Launch — Jubilee Hills', 'Featured', 'Search Results', 'Draft', '0 views', '0 clicks'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Advertisement Editor', style: AppTypography.headingMedium),
        actions: [
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.save, size: 18, color: AppColors.primary),
            label: Text('Save Draft', style: AppTypography.labelMedium.copyWith(color: AppColors.primary)),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.publish, size: 18, color: Colors.white),
            label: Text('Publish', style: AppTypography.labelMedium.copyWith(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: isDesktop
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: _editorPanel()),
                  const SizedBox(width: 20),
                  Expanded(flex: 2, child: Column(children: [_previewPanel(), const SizedBox(height: 20), _existingAdsPanel()])),
                ],
              )
            : Column(
                children: [
                  _editorPanel(),
                  const SizedBox(height: 20),
                  _previewPanel(),
                  const SizedBox(height: 20),
                  _existingAdsPanel(),
                ],
              ),
      ),
    );
  }

  Widget _editorPanel() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Create Advertisement', style: AppTypography.headingSmall),
          const SizedBox(height: 20),

          // Ad Type
          Text('Ad Type', style: AppTypography.labelMedium),
          const SizedBox(height: 8),
          Row(
            children: ['Banner', 'Card', 'Featured', 'Popup'].map((type) {
              final active = _adType == type;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _adType = type),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: active ? AppColors.primary : AppColors.background,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: active ? AppColors.primary : AppColors.border),
                      ),
                      child: Center(
                        child: Text(type, style: AppTypography.labelSmall.copyWith(color: active ? Colors.white : AppColors.textSecondary)),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Title
          _inputField('Ad Title', _titleController, Icons.title),
          const SizedBox(height: 14),

          // Subtitle
          _inputField('Subtitle / Offer', _subtitleController, Icons.subtitles),
          const SizedBox(height: 14),

          // CTA Button Text
          _inputField('CTA Button Text', _ctaController, Icons.touch_app),
          const SizedBox(height: 14),

          // Link
          _inputField('Target Link', _linkController, Icons.link),
          const SizedBox(height: 16),

          // Placement
          Text('Placement', style: AppTypography.labelMedium),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _placement,
            items: ['Home Page', 'Listing Page', 'Search Results', 'Property Detail', 'Dashboard']
                .map((e) => DropdownMenuItem(value: e, child: Text(e, style: AppTypography.bodyMedium)))
                .toList(),
            onChanged: (v) => setState(() => _placement = v!),
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
          const SizedBox(height: 16),

          // Image Upload
          Text('Ad Image', style: AppTypography.labelMedium),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border, style: BorderStyle.solid),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.cloud_upload_outlined, size: 36, color: AppColors.textTertiary),
                const SizedBox(height: 8),
                Text('Drop image here or click to upload', style: AppTypography.bodySmall),
                Text('PNG, JPG up to 2MB — 1200x400 recommended', style: AppTypography.labelSmall.copyWith(color: AppColors.textTertiary)),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Date Range
          Text('Schedule', style: AppTypography.labelMedium),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () async {
              final range = await showDateRangePicker(
                context: context,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (range != null) setState(() => _dateRange = range);
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, size: 18, color: AppColors.textTertiary),
                  const SizedBox(width: 10),
                  Text(
                    _dateRange != null
                        ? '${_formatDate(_dateRange!.start)} — ${_formatDate(_dateRange!.end)}'
                        : 'Select date range',
                    style: AppTypography.bodyMedium.copyWith(
                      color: _dateRange != null ? AppColors.textPrimary : AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Background color
          Text('Background Color', style: AppTypography.labelMedium),
          const SizedBox(height: 8),
          Row(
            children: [
              AppColors.navy,
              AppColors.primary,
              AppColors.primaryDark,
              AppColors.info,
              AppColors.amber,
              AppColors.error,
            ].map((color) {
              final active = _bgColor == color;
              return GestureDetector(
                onTap: () => setState(() => _bgColor = color),
                child: Container(
                  width: 36,
                  height: 36,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(color: active ? AppColors.textPrimary : Colors.transparent, width: 3),
                  ),
                  child: active ? const Icon(Icons.check, size: 18, color: Colors.white) : null,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _previewPanel() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Preview', style: AppTypography.headingSmall),
          ),
          // Ad preview
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: _bgColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(_adType.toUpperCase(), style: AppTypography.labelSmall.copyWith(color: Colors.white)),
                ),
                const SizedBox(height: 12),
                Text(
                  _titleController.text.isEmpty ? 'Ad Title' : _titleController.text,
                  style: AppTypography.headingMedium.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 6),
                Text(
                  _subtitleController.text.isEmpty ? 'Subtitle text here' : _subtitleController.text,
                  style: AppTypography.bodyMedium.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _ctaController.text.isEmpty ? 'CTA Button' : _ctaController.text,
                    style: AppTypography.buttonMedium.copyWith(color: _bgColor),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _existingAdsPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your Advertisements', style: AppTypography.headingSmall),
          const SizedBox(height: 12),
          ..._existingAds.map((ad) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _statusColor(ad.status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        ad.type == 'Banner' ? Icons.view_carousel : ad.type == 'Card' ? Icons.credit_card : Icons.star,
                        size: 18,
                        color: _statusColor(ad.status),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(ad.title, style: AppTypography.labelMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                          Row(
                            children: [
                              Text('${ad.placement} · ', style: AppTypography.labelSmall.copyWith(color: AppColors.textTertiary)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                decoration: BoxDecoration(
                                  color: _statusColor(ad.status).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(ad.status, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: _statusColor(ad.status))),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text('${ad.views} · ${ad.clicks}', style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    IconButton(icon: const Icon(Icons.edit, size: 18, color: AppColors.primary), onPressed: () {}),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _inputField(String label, TextEditingController controller, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.labelMedium),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 18, color: AppColors.textTertiary),
            filled: true,
            fillColor: AppColors.background,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
          ),
          style: AppTypography.bodyMedium,
        ),
      ],
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Active':
        return AppColors.primary;
      case 'Paused':
        return AppColors.amber;
      case 'Draft':
        return AppColors.textTertiary;
      default:
        return AppColors.textSecondary;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _Ad {
  final String title, type, placement, status, views, clicks;

  const _Ad(this.title, this.type, this.placement, this.status, this.views, this.clicks);
}
