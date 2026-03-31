import 'package:flutter/material.dart';
import '../../config/colors.dart';
import '../../config/typography.dart';
import '../../config/responsive.dart';
import '../../data/mock_data.dart';
import '../../services/property_store.dart';
import '../../widgets/common/property_card.dart';

class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final hPad = Responsive.value<double>(context, mobile: 20, tablet: 24, desktop: 40);
    final topPad = isMobile ? MediaQuery.of(context).padding.top + 16 : 24.0;
    final gridCols = Responsive.value<int>(context, mobile: 1, tablet: 2, desktop: 4);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1280),
              child: Padding(
                padding: EdgeInsets.fromLTRB(hPad, topPad, hPad, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Saved Properties', style: AppTypography.displaySmall),
                    const SizedBox(height: 4),
                    Text(
                      '${PropertyStore.instance.properties.length} properties saved',
                      style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        // Mobile: list, Tablet/Desktop: grid
        if (isMobile)
          SliverPadding(
            padding: EdgeInsets.all(hPad),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: PropertyCard(
                      property: PropertyStore.instance.properties[index],
                      onTap: () {},
                    ),
                  );
                },
                childCount: PropertyStore.instance.properties.length.clamp(0, 3),
              ),
            ),
          )
        else
          SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1280),
                child: Padding(
                  padding: EdgeInsets.all(hPad),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: gridCols,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                      childAspectRatio: gridCols == 1 ? 0.85 : gridCols == 2 ? 0.68 : 0.72,
                    ),
                    itemCount: PropertyStore.instance.properties.length.clamp(0, 12),
                    itemBuilder: (context, index) {
                      return PropertyCard(
                        property: PropertyStore.instance.properties[index],
                        onTap: () {},
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
