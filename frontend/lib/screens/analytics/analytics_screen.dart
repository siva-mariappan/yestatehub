import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../config/colors.dart';
import '../../config/typography.dart';
import '../../config/responsive.dart';
import '../../config/assets.dart';
import '../../widgets/footer/app_footer.dart';

/// Analytics Screen — AI-powered property price prediction & market analytics
class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> with SingleTickerProviderStateMixin {
  // Form inputs
  String _city = 'Hyderabad';
  String _locality = 'Gachibowli';
  final TextEditingController _sqftController = TextEditingController(text: '1200');
  int _bedrooms = 2;
  final TextEditingController _ageController = TextEditingController(text: '3');
  int _targetYear = 2028;
  bool _showResult = false;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  // Mock calculations
  double get _sqft => double.tryParse(_sqftController.text) ?? 1200;
  int get _buildingAge => int.tryParse(_ageController.text) ?? 3;

  double get _currentMarketValue =>
      (_sqft * 7200 + _bedrooms * 600000 - _buildingAge * 120000).clamp(1500000, 80000000).toDouble();
  double get _currentAssetValue => _currentMarketValue * 0.88;
  double get _futureMarketValue =>
      (_currentMarketValue * pow(1.085, _targetYear - 2026)).clamp(1500000, 200000000).toDouble();
  double get _futureAssetValue => _futureMarketValue * 0.90;
  double get _yearlyGrowth => 8.5;
  double get _pricePerSqft => _currentMarketValue / _sqft;
  double get _appreciation => ((_futureMarketValue - _currentMarketValue) / _currentMarketValue * 100);

  static const _cities = ['Hyderabad', 'Bangalore', 'Mumbai', 'Chennai', 'Pune', 'Delhi NCR', 'Kolkata', 'Ahmedabad'];
  static const _localities = {
    'Hyderabad': ['Gachibowli', 'Kondapur', 'Kokapet', 'Miyapur', 'Banjara Hills', 'Jubilee Hills', 'Madhapur', 'Kukatpally', 'Tellapur', 'Nallagandla'],
    'Bangalore': ['Whitefield', 'HSR Layout', 'Koramangala', 'Electronic City', 'Sarjapur Road', 'Marathahalli'],
    'Mumbai': ['Andheri', 'Bandra', 'Powai', 'Thane', 'Navi Mumbai', 'Worli'],
    'Chennai': ['OMR', 'Anna Nagar', 'T.Nagar', 'Velachery', 'Porur', 'Adyar'],
    'Pune': ['Hinjewadi', 'Baner', 'Wakad', 'Kharadi', 'Viman Nagar', 'Aundh'],
    'Delhi NCR': ['Gurgaon', 'Noida', 'Greater Noida', 'Dwarka', 'Faridabad'],
    'Kolkata': ['Salt Lake', 'New Town', 'Rajarhat', 'EM Bypass', 'Tollygunge'],
    'Ahmedabad': ['SG Highway', 'Prahlad Nagar', 'Vastrapur', 'Bopal', 'Satellite'],
  };

  // Nearby property markers (mock data for map)
  static const _mapMarkers = [
    {'name': 'Green Valley Apt.', 'price': '78L', 'lat': 0.35, 'lng': 0.45},
    {'name': 'Prestige Towers', 'price': '1.2Cr', 'lat': 0.55, 'lng': 0.30},
    {'name': 'Aparna Sarovar', 'price': '95L', 'lat': 0.25, 'lng': 0.65},
    {'name': 'My Home Bhooja', 'price': '1.8Cr', 'lat': 0.70, 'lng': 0.55},
    {'name': 'Ramky One North', 'price': '62L', 'lat': 0.45, 'lng': 0.75},
    {'name': 'Sri Aditya Athena', 'price': '88L', 'lat': 0.60, 'lng': 0.20},
    {'name': 'Phoenix Towers', 'price': '1.05Cr', 'lat': 0.15, 'lng': 0.40},
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _sqftController.dispose();
    _ageController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _predict() {
    FocusScope.of(context).unfocus();
    setState(() => _showResult = true);
    _animController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header bar ──
            _buildHeader(isDesktop),
            const Divider(height: 1, color: AppColors.border),
            // ── Content ──
            Expanded(
              child: SingleChildScrollView(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1360),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 40 : 16, vertical: 24),
                      child: Column(
                        children: [
                          // Hero section
                          _buildHeroSection(isDesktop),
                          const SizedBox(height: 28),
                          // Main content: form + results
                          isDesktop
                              ? Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(width: 400, child: _buildInputPanel()),
                                    const SizedBox(width: 24),
                                    Expanded(child: _showResult ? _buildResultsSection(isDesktop) : _buildPlaceholder()),
                                  ],
                                )
                              : Column(
                                  children: [
                                    _buildInputPanel(),
                                    if (_showResult) ...[
                                      const SizedBox(height: 24),
                                      _buildResultsSection(isDesktop),
                                    ],
                                  ],
                                ),
                          const SizedBox(height: 32),
                          // Market Overview section (always visible)
                          _buildMarketOverview(isDesktop),
                          const SizedBox(height: 32),
                          const AppFooter(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // HEADER
  // ═══════════════════════════════════════════════════════════════
  Widget _buildHeader(bool isDesktop) {
    return Container(
      color: AppColors.surface,
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 40 : 16, vertical: 12),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1360),
          child: Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.background,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.primaryExtraLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SvgPicture.asset(AppAssets.icAnalytic, width: 20, height: 20, colorFilter: const ColorFilter.mode(AppColors.primary, BlendMode.srcIn)),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('EstateIQ', style: AppTypography.headingSmall.copyWith(fontSize: 17)),
                  Text('AI-powered price prediction & market insights', style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary, fontSize: 12)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // HERO SECTION
  // ═══════════════════════════════════════════════════════════════
  Widget _buildHeroSection(bool isDesktop) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isDesktop ? 32 : 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF10B981), Color(0xFF059669)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Know Your Property Value',
                  style: AppTypography.headingMedium.copyWith(color: Colors.white, fontSize: isDesktop ? 26 : 20),
                ),
                const SizedBox(height: 8),
                Text(
                  'Get AI-powered price predictions, market trends, and investment insights for any property across India.',
                  style: AppTypography.bodyMedium.copyWith(color: Colors.white.withOpacity(0.85), height: 1.5),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _heroBadge(Icons.auto_awesome, '98% Accuracy'),
                    const SizedBox(width: 10),
                    _heroBadge(Icons.speed_rounded, 'Instant Results'),
                    if (isDesktop) ...[
                      const SizedBox(width: 10),
                      _heroBadge(Icons.map_rounded, '50+ Cities'),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (isDesktop) ...[
            const SizedBox(width: 24),
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: SvgPicture.asset(AppAssets.icAnalytic, width: 64, height: 64, colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _heroBadge(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 5),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // INPUT PANEL
  // ═══════════════════════════════════════════════════════════════
  Widget _buildInputPanel() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SvgPicture.asset(AppAssets.icFilter, width: 20, height: 20, colorFilter: const ColorFilter.mode(AppColors.textPrimary, BlendMode.srcIn)),
              const SizedBox(width: 8),
              Text('Property Details', style: AppTypography.headingSmall.copyWith(fontSize: 17)),
            ],
          ),
          const SizedBox(height: 6),
          Text('Fill in the details to get a price prediction', style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary)),
          const SizedBox(height: 20),

          // City dropdown
          _buildDropdown('City', _city, _cities, (v) {
            setState(() {
              _city = v!;
              _locality = (_localities[_city] ?? [''])[0];
            });
          }),
          const SizedBox(height: 16),

          // Locality dropdown
          _buildDropdown('Location', _locality, _localities[_city] ?? [], (v) => setState(() => _locality = v!)),
          const SizedBox(height: 16),

          // Sqft + Age in a row
          Row(
            children: [
              Expanded(child: _buildTextField('Square Footage', _sqftController, 'sq.ft')),
              const SizedBox(width: 12),
              Expanded(child: _buildTextField('Building Age', _ageController, 'years')),
            ],
          ),
          const SizedBox(height: 16),

          // Bedrooms
          Text('Bedrooms', style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Row(
            children: List.generate(6, (i) {
              final val = i + 1;
              final label = val <= 5 ? '$val BHK' : '5+';
              final active = val == _bedrooms;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: i < 5 ? 6 : 0),
                  child: GestureDetector(
                    onTap: () => setState(() => _bedrooms = val),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: 40,
                      decoration: BoxDecoration(
                        color: active ? AppColors.primary : AppColors.background,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: active ? AppColors.primary : AppColors.border),
                      ),
                      child: Center(
                        child: Text(
                          label,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: active ? Colors.white : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),

          // Target Year slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Target Year', style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w600)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryExtraLight,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text('$_targetYear', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: AppColors.primaryLight,
              thumbColor: AppColors.primary,
              overlayColor: AppColors.primary.withOpacity(0.1),
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            ),
            child: Slider(
              value: _targetYear.toDouble(),
              min: 2026,
              max: 2036,
              divisions: 10,
              onChanged: (v) => setState(() => _targetYear = v.round()),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('2026', style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary, fontSize: 11)),
              Text('2036', style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 20),

          // Predict button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _predict,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text('Predict Price', style: AppTypography.buttonLarge.copyWith(color: Colors.white)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // RESULTS SECTION
  // ═══════════════════════════════════════════════════════════════
  Widget _buildResultsSection(bool isDesktop) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: Column(
        children: [
          // ── 4 Value Cards ──
          _buildValueCards(isDesktop),
          const SizedBox(height: 20),
          // ── Price Trend Chart ──
          _buildTrendChart(),
          const SizedBox(height: 20),
          // ── Analytics Map ──
          _buildAnalyticsMap(isDesktop),
          const SizedBox(height: 20),
          // ── Key Insights ──
          _buildInsightsCard(),
        ],
      ),
    );
  }

  // ── 4 Value Cards ──────────────────────────────────────────────
  Widget _buildValueCards(bool isDesktop) {
    final cols = isDesktop ? 2 : 2;
    final cards = [
      _ValueCardData('Current Market Value', _formatPrice(_currentMarketValue), Icons.account_balance_rounded, const Color(0xFF10B981), const Color(0xFFD1FAE5)),
      _ValueCardData('Current Asset Value', _formatPrice(_currentAssetValue), Icons.diamond_rounded, const Color(0xFF3B82F6), const Color(0xFFDBEAFE)),
      _ValueCardData('Future Market Value', _formatPrice(_futureMarketValue), Icons.trending_up_rounded, const Color(0xFF8B5CF6), const Color(0xFFEDE9FE)),
      _ValueCardData('Future Asset Value', _formatPrice(_futureAssetValue), Icons.star_rounded, const Color(0xFFF59E0B), const Color(0xFFFEF3C7)),
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: cols,
      crossAxisSpacing: 14,
      mainAxisSpacing: 14,
      childAspectRatio: isDesktop ? 2.4 : 1.8,
      children: cards.map((c) => _buildValueCard(c)).toList(),
    );
  }

  Widget _buildValueCard(_ValueCardData data) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: AppColors.cardShadow,
        border: Border.all(color: data.bgColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: data.bgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(data.icon, size: 20, color: data.color),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: data.bgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  data.label.contains('Future') ? '$_targetYear' : '2026',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: data.color),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '\u20B9 ${data.value}',
            style: AppTypography.headingSmall.copyWith(fontSize: 20, fontWeight: FontWeight.w800, color: data.color),
          ),
          const SizedBox(height: 2),
          Text(
            data.label,
            style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary, fontSize: 11),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ── Price Trend Chart ──────────────────────────────────────────
  Widget _buildTrendChart() {
    return Container(
      padding: const EdgeInsets.all(20),
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
              const Icon(Icons.show_chart_rounded, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Text('Price Trend Projection', style: AppTypography.headingSmall.copyWith(fontSize: 16)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.primaryExtraLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '+${_appreciation.toStringAsFixed(1)}% growth',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('Projected price from 2023 to $_targetYear', style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary)),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: CustomPaint(
              size: const Size(double.infinity, 180),
              painter: _TrendPainter(_currentMarketValue, _futureMarketValue, _targetYear),
            ),
          ),
          const SizedBox(height: 12),
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _legendDot(AppColors.primary, 'Market Value'),
              const SizedBox(width: 20),
              _legendDot(const Color(0xFF3B82F6), 'Asset Value'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: AppTypography.bodySmall.copyWith(fontSize: 11, color: AppColors.textSecondary)),
      ],
    );
  }

  // ── Analytics Map ──────────────────────────────────────────────
  Widget _buildAnalyticsMap(bool isDesktop) {
    return Container(
      padding: const EdgeInsets.all(20),
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
              const Icon(Icons.map_rounded, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Text('Nearby Properties in $_locality', style: AppTypography.headingSmall.copyWith(fontSize: 16)),
            ],
          ),
          const SizedBox(height: 6),
          Text('Properties listed near your selected location', style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary)),
          const SizedBox(height: 16),
          // Mock map with markers
          Container(
            height: 280,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CustomPaint(
                size: const Size(double.infinity, 280),
                painter: _MapPainter(_mapMarkers, _locality),
              ),
            ),
          ),
          const SizedBox(height: 14),
          // Marker list
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: _mapMarkers.map((m) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.location_on, size: 14, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Text('${m['name']}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
                  const SizedBox(width: 4),
                  Text('\u20B9${m['price']}', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary)),
                ],
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }

  // ── Insights Card ──────────────────────────────────────────────
  Widget _buildInsightsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
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
              const Icon(Icons.lightbulb_rounded, size: 20, color: Color(0xFFF59E0B)),
              const SizedBox(width: 8),
              Text('Key Insights', style: AppTypography.headingSmall.copyWith(fontSize: 16)),
            ],
          ),
          const SizedBox(height: 14),
          _insightTile(Icons.trending_up_rounded, AppColors.primary,
            'Property values in $_locality have grown ${_yearlyGrowth}% annually over the last 3 years.'),
          _insightTile(Icons.location_city_rounded, const Color(0xFF3B82F6),
            '$_locality is a high-demand area with excellent IT corridor connectivity and social infrastructure.'),
          _insightTile(Icons.attach_money_rounded, const Color(0xFF8B5CF6),
            'Average price per sq.ft in $_locality: \u20B9${_pricePerSqft.toStringAsFixed(0)}. Premium segment growing fastest.'),
          _insightTile(Icons.lightbulb_outline_rounded, const Color(0xFFF59E0B),
            'Best ROI: Properties under 5 years old with 2-3 BHK configuration in gated communities.'),
          _insightTile(Icons.shield_rounded, const Color(0xFF10B981),
            'RERA-approved projects in this area offer 15-20% better resale value.'),
          const SizedBox(height: 14),
          // Disclaimer
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.warning_amber_rounded, size: 18, color: Color(0xFFF59E0B)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Predictions are AI-estimated based on historical trends and market data. Actual values may vary. Consult a property expert before investing.',
                    style: AppTypography.bodySmall.copyWith(color: AppColors.textPrimary, fontSize: 12, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _insightTile(IconData icon, Color color, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text, style: AppTypography.bodySmall.copyWith(color: AppColors.textPrimary, height: 1.4)),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // MARKET OVERVIEW (always visible)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildMarketOverview(bool isDesktop) {
    final cols = isDesktop ? 4 : 2;
    final stats = [
      _StatData('Avg. Price/sq.ft', '\u20B97,200', '+12%', Icons.square_foot_rounded, AppColors.primary),
      _StatData('Properties Listed', '24,580', '+8%', Icons.home_rounded, const Color(0xFF3B82F6)),
      _StatData('Avg. Days on Market', '42 Days', '-15%', Icons.timer_rounded, const Color(0xFF8B5CF6)),
      _StatData('Rental Yield', '3.8%', '+0.5%', Icons.percent_rounded, const Color(0xFFF59E0B)),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SvgPicture.asset(AppAssets.icAnalytic, width: 22, height: 22, colorFilter: const ColorFilter.mode(AppColors.primary, BlendMode.srcIn)),
            const SizedBox(width: 8),
            Text('Market Overview — $_city', style: AppTypography.headingSmall.copyWith(fontSize: 18)),
          ],
        ),
        const SizedBox(height: 6),
        Text('Current real estate market snapshot', style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary)),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: cols,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: isDesktop ? 2.8 : 1.9,
          children: stats.map((s) => _buildStatCard(s)).toList(),
        ),
        const SizedBox(height: 20),
        // Price comparison by locality
        _buildLocalityComparison(isDesktop),
      ],
    );
  }

  Widget _buildStatCard(_StatData data) {
    final isPositive = data.change.startsWith('+');
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(data.icon, size: 18, color: data.color),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isPositive ? const Color(0xFFD1FAE5) : const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  data.change,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: isPositive ? AppColors.primary : const Color(0xFFEF4444),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(data.value, style: AppTypography.headingSmall.copyWith(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(data.label, style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildLocalityComparison(bool isDesktop) {
    final localities = (_localities[_city] ?? []).take(6).toList();
    final rng = Random(42);
    final prices = localities.map((_) => (5000 + rng.nextInt(6000)).toDouble()).toList();
    final maxPrice = prices.isEmpty ? 1.0 : prices.reduce(max);

    return Container(
      padding: const EdgeInsets.all(20),
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
              const Icon(Icons.compare_arrows_rounded, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Text('Price Comparison — $_city', style: AppTypography.headingSmall.copyWith(fontSize: 16)),
            ],
          ),
          const SizedBox(height: 6),
          Text('Average price per sq.ft across top localities', style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary)),
          const SizedBox(height: 20),
          ...List.generate(localities.length, (i) {
            final ratio = prices[i] / maxPrice;
            final isHighlighted = localities[i] == _locality;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  SizedBox(
                    width: isDesktop ? 120 : 90,
                    child: Text(
                      localities[i],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isHighlighted ? FontWeight.w700 : FontWeight.w500,
                        color: isHighlighted ? AppColors.primary : AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Stack(
                      children: [
                        Container(
                          height: 24,
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        FractionallySizedBox(
                          widthFactor: ratio,
                          child: Container(
                            height: 24,
                            decoration: BoxDecoration(
                              color: isHighlighted ? AppColors.primary : AppColors.primary.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '\u20B9${prices[i].toStringAsFixed(0)}/sqft',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isHighlighted ? AppColors.primary : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // PLACEHOLDER
  // ═══════════════════════════════════════════════════════════════
  Widget _buildPlaceholder() {
    return Container(
      height: 400,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(AppAssets.icAnalytic, width: 64, height: 64, colorFilter: ColorFilter.mode(AppColors.textTertiary.withOpacity(0.3), BlendMode.srcIn)),
            const SizedBox(height: 16),
            Text('Enter details to predict', style: AppTypography.bodyLarge.copyWith(color: AppColors.textTertiary)),
            const SizedBox(height: 4),
            Text('Fill in the form and click Predict Price', style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary)),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // HELPERS
  // ═══════════════════════════════════════════════════════════════
  Widget _buildDropdown(String label, String value, List<String> items, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: items.contains(value) ? value : (items.isNotEmpty ? items.first : null),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: AppTypography.bodyMedium))).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.background,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.border)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.border)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
          dropdownColor: AppColors.surface,
        ),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, String suffix) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: AppTypography.bodyMedium,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.background,
            suffixText: suffix,
            suffixStyle: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.border)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.border)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
      ],
    );
  }

  String _formatPrice(double price) {
    if (price >= 10000000) return '${(price / 10000000).toStringAsFixed(2)} Cr';
    if (price >= 100000) return '${(price / 100000).toStringAsFixed(1)} L';
    return '${(price / 1000).toStringAsFixed(0)}K';
  }
}

// ═══════════════════════════════════════════════════════════════
// DATA MODELS
// ═══════════════════════════════════════════════════════════════
class _ValueCardData {
  final String label, value;
  final IconData icon;
  final Color color, bgColor;
  const _ValueCardData(this.label, this.value, this.icon, this.color, this.bgColor);
}

class _StatData {
  final String label, value, change;
  final IconData icon;
  final Color color;
  const _StatData(this.label, this.value, this.change, this.icon, this.color);
}

// ═══════════════════════════════════════════════════════════════
// TREND CHART PAINTER
// ═══════════════════════════════════════════════════════════════
class _TrendPainter extends CustomPainter {
  final double currentPrice, futurePrice;
  final int targetYear;

  _TrendPainter(this.currentPrice, this.futurePrice, this.targetYear);

  @override
  void paint(Canvas canvas, Size size) {
    final years = targetYear - 2023;
    if (years <= 0) return;

    final chartLeft = 0.0;
    final chartRight = size.width;
    final chartTop = 20.0;
    final chartBottom = size.height - 30;
    final chartHeight = chartBottom - chartTop;

    // Generate points for market value line
    final marketPoints = <Offset>[];
    final assetPoints = <Offset>[];
    final basePrice = currentPrice * 0.6; // estimated 2023 price

    for (int i = 0; i <= years; i++) {
      final x = chartLeft + (i / years) * (chartRight - chartLeft);
      final marketVal = basePrice * pow(1.085, i);
      final assetVal = marketVal * 0.88;
      final maxVal = futurePrice * 1.1;
      final marketY = chartBottom - ((marketVal - basePrice * 0.8) / (maxVal - basePrice * 0.8)) * chartHeight;
      final assetY = chartBottom - ((assetVal - basePrice * 0.8) / (maxVal - basePrice * 0.8)) * chartHeight;
      marketPoints.add(Offset(x, marketY.clamp(chartTop, chartBottom)));
      assetPoints.add(Offset(x, assetY.clamp(chartTop, chartBottom)));
    }

    // Grid lines
    final gridPaint = Paint()..color = AppColors.border.withOpacity(0.5)..strokeWidth = 0.5;
    for (int i = 0; i <= 4; i++) {
      final y = chartTop + (chartHeight / 4) * i;
      canvas.drawLine(Offset(chartLeft, y), Offset(chartRight, y), gridPaint);
    }

    // Fill under market line
    _drawLineFill(canvas, marketPoints, chartBottom, AppColors.primary.withOpacity(0.08));
    // Fill under asset line
    _drawLineFill(canvas, assetPoints, chartBottom, const Color(0xFF3B82F6).withOpacity(0.05));

    // Draw lines
    _drawLine(canvas, marketPoints, AppColors.primary, 2.5);
    _drawLine(canvas, assetPoints, const Color(0xFF3B82F6), 2.0);

    // Dots on market line
    final dotPaint = Paint()..color = AppColors.primary;
    final whitePaint = Paint()..color = Colors.white;
    for (final p in marketPoints) {
      canvas.drawCircle(p, 4, dotPaint);
      canvas.drawCircle(p, 2, whitePaint);
    }

    // Year labels
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    for (int i = 0; i <= years; i += (years > 8 ? 2 : 1)) {
      textPainter.text = TextSpan(
        text: '${2023 + i}',
        style: const TextStyle(fontSize: 9, color: AppColors.textTertiary),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(marketPoints[i].dx - textPainter.width / 2, chartBottom + 8));
    }
  }

  void _drawLine(Canvas canvas, List<Offset> points, Color color, double width) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = width
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(path, paint);
  }

  void _drawLineFill(Canvas canvas, List<Offset> points, double bottom, Color color) {
    final path = Path()..moveTo(points.first.dx, bottom);
    for (final p in points) {
      path.lineTo(p.dx, p.dy);
    }
    path.lineTo(points.last.dx, bottom);
    path.close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ═══════════════════════════════════════════════════════════════
// MAP PAINTER (mock geographic visualization)
// ═══════════════════════════════════════════════════════════════
class _MapPainter extends CustomPainter {
  final List<Map<String, dynamic>> markers;
  final String locality;

  _MapPainter(this.markers, this.locality);

  @override
  void paint(Canvas canvas, Size size) {
    // Background with road grid
    final roadPaint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..strokeWidth = 1.5;

    // Horizontal roads
    for (int i = 1; i <= 5; i++) {
      final y = (size.height / 6) * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), roadPaint);
    }
    // Vertical roads
    for (int i = 1; i <= 7; i++) {
      final x = (size.width / 8) * i;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), roadPaint);
    }

    // Green patches (parks)
    final parkPaint = Paint()..color = const Color(0xFFA5D6A7).withOpacity(0.4);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(size.width * 0.1, size.height * 0.1, 60, 40), const Radius.circular(8)), parkPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(size.width * 0.7, size.height * 0.6, 50, 35), const Radius.circular(8)), parkPaint);

    // Draw markers
    for (final m in markers) {
      final x = (m['lng'] as double) * size.width;
      final y = (m['lat'] as double) * size.height;

      // Shadow
      canvas.drawCircle(Offset(x, y + 2), 14, Paint()..color = Colors.black.withOpacity(0.15));

      // Pin circle
      canvas.drawCircle(Offset(x, y), 14, Paint()..color = AppColors.primary);
      canvas.drawCircle(Offset(x, y), 10, Paint()..color = Colors.white);

      // Inner dot
      canvas.drawCircle(Offset(x, y), 5, Paint()..color = AppColors.primary);
    }

    // Center label
    final textPainter = TextPainter(
      text: TextSpan(
        text: locality,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          backgroundColor: Colors.white,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    final center = Offset(size.width / 2 - textPainter.width / 2, size.height / 2 - textPainter.height / 2);

    // White background for label
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(center.dx - 8, center.dy - 4, textPainter.width + 16, textPainter.height + 8),
        const Radius.circular(6),
      ),
      Paint()..color = Colors.white,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(center.dx - 8, center.dy - 4, textPainter.width + 16, textPainter.height + 8),
        const Radius.circular(6),
      ),
      Paint()
        ..color = AppColors.primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    textPainter.paint(canvas, center);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
