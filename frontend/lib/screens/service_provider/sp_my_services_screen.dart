import 'package:flutter/material.dart';
import '../../config/colors.dart';
import '../../config/typography.dart';
import '../../config/responsive.dart';
import 'sp_add_service_screen.dart';

class SpMyServicesScreen extends StatefulWidget {
  const SpMyServicesScreen({super.key});

  @override
  State<SpMyServicesScreen> createState() => _SpMyServicesScreenState();
}

class _SpMyServicesScreenState extends State<SpMyServicesScreen> {
  final _services = [
    {'name': 'Home Cleaning', 'desc': 'Complete house cleaning including floors, kitchen, bathrooms', 'price': '\u20B91,200 - \u20B93,000', 'rating': '4.9', 'reviews': '86', 'bookings': '120', 'revenue': '\u20B91.4L', 'icon': Icons.cleaning_services_rounded, 'color': AppColors.primary, 'active': true},
    {'name': 'Deep Cleaning', 'desc': 'Thorough deep cleaning with sofa, carpet shampooing', 'price': '\u20B92,500 - \u20B95,500', 'rating': '4.8', 'reviews': '52', 'bookings': '78', 'revenue': '\u20B94.2L', 'icon': Icons.dry_cleaning_rounded, 'color': AppColors.info, 'active': true},
    {'name': 'Interior Painting', 'desc': 'Wall painting, texture work, waterproofing', 'price': '\u20B94,000 - \u20B915,000', 'rating': '4.7', 'reviews': '34', 'bookings': '45', 'revenue': '\u20B96.7L', 'icon': Icons.format_paint_rounded, 'color': const Color(0xFFF59E0B), 'active': true},
    {'name': 'Plumbing Repair', 'desc': 'Pipe fitting, leakage repair, tap installation', 'price': '\u20B9500 - \u20B92,000', 'rating': '4.6', 'reviews': '28', 'bookings': '62', 'revenue': '\u20B91.2L', 'icon': Icons.plumbing_rounded, 'color': const Color(0xFF8B5CF6), 'active': false},
    {'name': 'Electrical Repair', 'desc': 'Wiring, switches, MCB, appliance repair', 'price': '\u20B9600 - \u20B92,500', 'rating': '4.5', 'reviews': '18', 'bookings': '30', 'revenue': '\u20B975K', 'icon': Icons.electrical_services_rounded, 'color': const Color(0xFFEC4899), 'active': false},
  ];

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final active = _services.where((s) => s['active'] == true).length;
    final inactive = _services.length - active;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 28),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('My Services', style: AppTypography.headingMedium),
                        const SizedBox(height: 4),
                        RichText(
                          text: TextSpan(
                            style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary),
                            children: [
                              TextSpan(text: '$active active', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                              const TextSpan(text: '  \u2022  '),
                              TextSpan(text: '$inactive inactive'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF059669)]),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3))],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SpAddServiceScreen())),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          child: Row(
                            children: [
                              const Icon(Icons.add_rounded, size: 18, color: Colors.white),
                              const SizedBox(width: 8),
                              Text('Add Service', style: AppTypography.labelMedium.copyWith(color: Colors.white)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),

              // Service cards
              ..._services.asMap().entries.map((e) => _buildServiceCard(e.value, e.key)),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceCard(Map<String, dynamic> service, int index) {
    final isActive = service['active'] as bool;
    final color = service['color'] as Color;
    final isMobile = Responsive.isMobile(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isActive ? AppColors.border.withOpacity(0.5) : AppColors.border.withOpacity(0.3)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(isActive ? 0.04 : 0.02), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Opacity(
        opacity: isActive ? 1.0 : 0.65,
        child: Column(
          children: [
            // Top row with accent
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.withOpacity(0.04), Colors.transparent],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Service icon
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [color.withOpacity(0.15), color.withOpacity(0.08)]),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: color.withOpacity(0.15)),
                    ),
                    child: Icon(service['icon'] as IconData, size: 28, color: color),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(child: Text(service['name'] as String, style: AppTypography.headingSmall)),
                            // Status toggle
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                              decoration: BoxDecoration(
                                color: isActive ? AppColors.primaryExtraLight : AppColors.divider,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: isActive ? AppColors.primary.withOpacity(0.2) : AppColors.border),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 7,
                                    height: 7,
                                    decoration: BoxDecoration(
                                      color: isActive ? AppColors.primary : AppColors.textTertiary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(isActive ? 'Active' : 'Inactive', style: AppTypography.labelSmall.copyWith(color: isActive ? AppColors.primary : AppColors.textTertiary, fontSize: 11)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(service['desc'] as String, style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary, height: 1.4)),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(service['price'] as String, style: AppTypography.labelMedium.copyWith(color: color)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Stats bar
            Container(
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 14 : 18, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.background.withOpacity(0.5),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
              ),
              child: isMobile
                  ? Column(
                      children: [
                        Row(
                          children: [
                            _buildMiniStat(Icons.star_rounded, service['rating'] as String, '(${service['reviews']})', AppColors.amber),
                            const Spacer(),
                            _buildMiniStat(Icons.calendar_today_rounded, service['bookings'] as String, 'jobs', AppColors.info),
                            const Spacer(),
                            _buildMiniStat(Icons.payments_rounded, service['revenue'] as String, 'earned', AppColors.primary),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(child: _buildCardAction('Edit', Icons.edit_outlined, AppColors.textPrimary)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => service['active'] = !isActive),
                                child: _buildCardAction(
                                  isActive ? 'Pause' : 'Resume',
                                  isActive ? Icons.pause_circle_outline_rounded : Icons.play_circle_outline_rounded,
                                  isActive ? AppColors.amber : AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        _buildMiniStat(Icons.star_rounded, service['rating'] as String, '(${service['reviews']})', AppColors.amber),
                        const SizedBox(width: 18),
                        _buildMiniStat(Icons.calendar_today_rounded, service['bookings'] as String, 'bookings', AppColors.info),
                        const SizedBox(width: 18),
                        _buildMiniStat(Icons.payments_rounded, service['revenue'] as String, 'earned', AppColors.primary),
                        const Spacer(),
                        _buildCardAction('Edit', Icons.edit_outlined, AppColors.textPrimary),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => setState(() => service['active'] = !isActive),
                          child: _buildCardAction(
                            isActive ? 'Pause' : 'Resume',
                            isActive ? Icons.pause_circle_outline_rounded : Icons.play_circle_outline_rounded,
                            isActive ? AppColors.amber : AppColors.primary,
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat(IconData icon, String value, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 5),
        Text(value, style: AppTypography.labelSmall.copyWith(color: AppColors.textPrimary, fontSize: 12)),
        const SizedBox(width: 3),
        Text(label, style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary, fontSize: 10)),
      ],
    );
  }

  Widget _buildCardAction(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(label, style: AppTypography.labelSmall.copyWith(color: color)),
        ],
      ),
    );
  }
}
