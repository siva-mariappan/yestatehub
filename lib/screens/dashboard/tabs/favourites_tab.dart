import 'package:flutter/material.dart';
import '../../../data/mock_data.dart';
import '../../../widgets/common/property_card.dart';

/// Favourites Tab — saved/favourite properties
class FavouritesTab extends StatelessWidget {
  const FavouritesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final saved = MockData.featuredProperties.take(4).toList();
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: saved.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, index) => PropertyCard(property: saved[index]),
    );
  }
}
