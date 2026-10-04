import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/food_item.dart';
import '../../providers/food_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/category_card.dart';
import '../../widgets/food_card.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  String _selectedCategory = 'Breakfast';

  @override
  Widget build(BuildContext context) {
    final foodProvider = Provider.of<FoodProvider>(context);

    // List of active categories (excluding 'All')
    final menuCategories = foodProvider.categories.where((c) => c != 'All').toList();
    if (!menuCategories.contains(_selectedCategory) && menuCategories.isNotEmpty) {
      _selectedCategory = menuCategories.first;
    }

    final List<FoodItem> items = foodProvider.getItemsByCategory(_selectedCategory, customerOnly: false);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Food Categories'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category selector tabs with count
          Container(
            height: 52,
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: menuCategories.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final cat = menuCategories[index];
                final count = foodProvider.getItemsByCategory(cat, customerOnly: false).length;
                return CategoryCard(
                  categoryName: cat,
                  isSelected: _selectedCategory == cat,
                  itemCount: count,
                  onTap: () {
                    setState(() {
                      _selectedCategory = cat;
                    });
                  },
                );
              },
            ),
          ),

          // Header with category title and total count
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$_selectedCategory Menu',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  '${items.length} items available',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Grid of items
          Expanded(
            child: items.isEmpty
                ? Center(
                    child: Text(
                      'No items in $_selectedCategory right now',
                      style: const TextStyle(color: AppTheme.textMuted),
                    ),
                  )
                : LayoutBuilder(
                    builder: (context, constraints) {
                      final screenWidth = constraints.maxWidth;
                      final int crossAxisCount;
                      if (screenWidth >= 950) {
                        crossAxisCount = 4;
                      } else if (screenWidth >= 650) {
                        crossAxisCount = 3;
                      } else {
                        crossAxisCount = 2;
                      }

                      const double crossAxisSpacing = 12.0;
                      const double mainAxisSpacing = 12.0;
                      const double horizontalPadding = 32.0;
                      const double targetCardHeight = 265.0;

                      final double effectiveWidth = screenWidth > 1200 ? 1200 : screenWidth;
                      final double cardWidth = (effectiveWidth - horizontalPadding - (crossAxisCount - 1) * crossAxisSpacing) / crossAxisCount;
                      final double childAspectRatio = cardWidth / targetCardHeight;

                      return Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1200),
                          child: GridView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              childAspectRatio: childAspectRatio,
                              crossAxisSpacing: crossAxisSpacing,
                              mainAxisSpacing: mainAxisSpacing,
                            ),
                            itemCount: items.length,
                            itemBuilder: (context, index) {
                              return FoodCard(food: items[index]);
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
