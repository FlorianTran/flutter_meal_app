import 'package:flutter/material.dart';
import '../../domain/entities/category.dart';
import 'category_card.dart';

/// Horizontal scrollable list of category cards
class CategoryList extends StatelessWidget {
  final List<Category> categories;
  final Function(Category)? onCategoryTap;

  const CategoryList({
    super.key,
    required this.categories,
    this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return CategoryCard(
            category: category,
            onTap: onCategoryTap != null
                ? () => onCategoryTap!(category)
                : null,
          );
        },
      ),
    );
  }
}

