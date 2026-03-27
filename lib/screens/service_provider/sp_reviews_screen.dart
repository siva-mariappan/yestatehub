import 'package:flutter/material.dart';
import '../../config/colors.dart';
import '../../config/typography.dart';
import '../../config/responsive.dart';

class SpReviewsScreen extends StatefulWidget {
  const SpReviewsScreen({super.key});

  @override
  State<SpReviewsScreen> createState() => _SpReviewsScreenState();
}

class _SpReviewsScreenState extends State<SpReviewsScreen> {
  String _filter = 'All';

  final _reviews = [
    {'name': 'Rahul Sharma', 'rating': 5, 'comment': 'Excellent cleaning service! Very thorough and professional work. The kitchen and bathrooms are spotless. Will definitely book again.', 'time': '2 hours ago', 'service': 'Home Cleaning', 'avatar': 'R', 'reply': null},
    {'name': 'Priya Patel', 'rating': 4, 'comment': 'Great painting work. Minor touch-ups needed but overall very satisfied with the result. Colors look amazing!', 'time': '1 day ago', 'service': 'Wall Painting', 'avatar': 'P', 'reply': 'Thank you, Priya! Glad you liked the work. I\'ll come back for the touch-ups this weekend.'},
    {'name': 'Arjun Reddy', 'rating': 5, 'comment': 'Quick and efficient plumbing repair. Fixed the leak in no time. Highly recommended for any plumbing issues!', 'time': '2 days ago', 'service': 'Plumbing', 'avatar': 'A', 'reply': null},
    {'name': 'Meera Joshi', 'rating': 5, 'comment': 'Absolutely amazing deep cleaning. My apartment looks brand new! Very attentive to detail and professional throughout.', 'time': '3 days ago', 'service': 'Deep Cleaning', 'avatar': 'M', 'reply': 'Thank you so much, Meera! It was a pleasure working in your beautiful apartment.'},
    {'name': 'Sneha Gupta', 'rating': 3, 'comment': 'Decent cleaning job. Could have been more thorough in the corners and under the furniture. Time management needs improvement.', 'time': '5 days ago', 'service': 'Home Cleaning', 'avatar': 'S', 'reply': 'Thank you for the feedback, Sneha. I\'ll make sure to pay extra attention to those areas next time.'},
    {'name': 'Vikram Singh', 'rating': 5, 'comment': 'Fixed all the electrical issues in one visit. Very knowledgeable and professional. Fair pricing too!', 'time': '1 week ago', 'service': 'Electrical Repair', 'avatar': 'V', 'reply': null},
    {'name': 'Kavya Nair', 'rating': 4, 'comment': 'Interior painting looks beautiful. Took a bit longer than expected but the quality is top-notch. Happy with the result!', 'time': '1 week ago', 'service': 'Interior Painting', 'avatar': 'K', 'reply': null},
    {'name': 'Amit Verma', 'rating': 5, 'comment': 'Best cleaning service I\'ve ever hired! Extremely professional and left my house smelling amazing. 10/10 recommend!', 'time': '2 weeks ago', 'service': 'Home Cleaning', 'avatar': 'A', 'reply': 'Wow, thank you Amit! That means a lot. Looking forward to serving you again!'},
  ];

  List<Map<String, dynamic>> get _filteredReviews {
    if (_filter == 'All') return _reviews;
    final stars = int.tryParse(_filter[0]) ?? 0;
    return _reviews.where((r) => r['rating'] == stars).toList();
  }

  double get _avgRating {
    if (_reviews.isEmpty) return 0;
    return _reviews.fold<int>(0, (sum, r) => sum + (r['rating'] as int)) / _reviews.length;
  }

  Map<int, int> get _ratingDistribution {
    final dist = <int, int>{5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
    for (var r in _reviews) {
      dist[r['rating'] as int] = (dist[r['rating'] as int] ?? 0) + 1;
    }
    return dist;
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Reviews & Ratings', style: AppTypography.headingMedium),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border.withOpacity(0.5)),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 16 : 28),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Rating overview
                _buildRatingOverview(isMobile),
                const SizedBox(height: 22),

                // Filters
                _buildFilters(),
                const SizedBox(height: 18),

                // Reviews list
                ..._filteredReviews.map((r) => _buildReviewCard(r)),

                if (_filteredReviews.isEmpty) _buildEmptyState(),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRatingOverview(bool isMobile) {
    final dist = _ratingDistribution;
    final total = _reviews.length;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: isMobile
          ? Column(
              children: [
                _buildRatingScore(),
                const SizedBox(height: 20),
                _buildRatingBars(dist, total),
              ],
            )
          : Row(
              children: [
                _buildRatingScore(),
                const SizedBox(width: 40),
                Container(width: 1, height: 120, color: AppColors.border.withOpacity(0.5)),
                const SizedBox(width: 40),
                Expanded(child: _buildRatingBars(dist, total)),
              ],
            ),
    );
  }

  Widget _buildRatingScore() {
    return Column(
      children: [
        Text(
          _avgRating.toStringAsFixed(1),
          style: AppTypography.displayLarge.copyWith(fontSize: 48, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(5, (i) => Padding(
            padding: const EdgeInsets.only(right: 3),
            child: Icon(
              i < _avgRating.round() ? Icons.star_rounded : Icons.star_outline_rounded,
              size: 22,
              color: AppColors.amber,
            ),
          )),
        ),
        const SizedBox(height: 6),
        Text('${_reviews.length} reviews', style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary)),
      ],
    );
  }

  Widget _buildRatingBars(Map<int, int> dist, int total) {
    return Column(
      children: [5, 4, 3, 2, 1].map((stars) {
        final count = dist[stars] ?? 0;
        final pct = total > 0 ? count / total : 0.0;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              SizedBox(
                width: 18,
                child: Text('$stars', style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary, fontSize: 12)),
              ),
              const Icon(Icons.star_rounded, size: 14, color: AppColors.amber),
              const SizedBox(width: 10),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: pct,
                    backgroundColor: AppColors.background,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      stars >= 4 ? AppColors.primary : stars == 3 ? AppColors.amber : AppColors.error,
                    ),
                    minHeight: 8,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 26,
                child: Text('$count', style: AppTypography.labelSmall.copyWith(color: AppColors.textTertiary, fontSize: 11)),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFilters() {
    final filters = ['All', '5 Star', '4 Star', '3 Star', '2 Star', '1 Star'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((f) {
          final isSelected = _filter == f;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _filter = f),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (f != 'All') ...[
                      Icon(Icons.star_rounded, size: 14, color: isSelected ? Colors.white : AppColors.amber),
                      const SizedBox(width: 4),
                    ],
                    Text(
                      f,
                      style: AppTypography.labelSmall.copyWith(
                        color: isSelected ? Colors.white : AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> review) {
    final hasReply = review['reply'] != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.primary.withOpacity(0.8), AppColors.primaryDark],
                        ),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Center(
                        child: Text(review['avatar'] as String, style: AppTypography.labelLarge.copyWith(color: Colors.white)),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(review['name'] as String, style: AppTypography.labelMedium),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              ...List.generate(5, (i) => Padding(
                                padding: const EdgeInsets.only(right: 2),
                                child: Icon(
                                  i < (review['rating'] as int) ? Icons.star_rounded : Icons.star_outline_rounded,
                                  size: 14,
                                  color: i < (review['rating'] as int) ? AppColors.amber : AppColors.border,
                                ),
                              )),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryExtraLight,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(review['service'] as String, style: AppTypography.labelSmall.copyWith(color: AppColors.primary, fontSize: 9)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Text(review['time'] as String, style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary, fontSize: 10)),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '"${review['comment']}"',
                    style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary, height: 1.5, fontStyle: FontStyle.italic),
                  ),
                ),
                if (!hasReply) ...[
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primaryExtraLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.reply_rounded, size: 14, color: AppColors.primary),
                          const SizedBox(width: 6),
                          Text('Reply', style: AppTypography.labelSmall.copyWith(color: AppColors.primary)),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (hasReply) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryExtraLight.withOpacity(0.5),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(18)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: const Icon(Icons.reply_rounded, size: 16, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Your Reply', style: AppTypography.labelSmall.copyWith(color: AppColors.primary)),
                        const SizedBox(height: 4),
                        Text(
                          review['reply'] as String,
                          style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primaryExtraLight,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(Icons.rate_review_rounded, size: 40, color: AppColors.textTertiary),
            ),
            const SizedBox(height: 16),
            Text('No Reviews Found', style: AppTypography.headingSmall.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 4),
            Text('No reviews match this filter', style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary)),
          ],
        ),
      ),
    );
  }
}
