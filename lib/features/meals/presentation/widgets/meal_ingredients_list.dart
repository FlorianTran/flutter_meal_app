import 'package:flutter/material.dart';
import 'package:flutter_meal_app/features/meals/domain/entities/ingredient.dart';
import '../../domain/entities/meal.dart';
import '../../../../core/theme/app_theme.dart';

/// Widget to display meal ingredients with measurements
class MealIngredientsList extends StatelessWidget {
  final Meal meal;
  final List<String>?
      selectedIngredients; // Optional: highlight selected ingredients

  const MealIngredientsList({
    super.key,
    required this.meal,
    this.selectedIngredients,
  });

  @override
  Widget build(BuildContext context) {
    if (meal.ingredients.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ingredients',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...meal.ingredients.map((ingredient) {
          final isSelected =
              selectedIngredients?.contains(ingredient.name) ?? false;
          return _IngredientItem(
            ingredient: ingredient,
            isSelected: isSelected,
          );
        }),
      ],
    );
  }
}

class _IngredientItem extends StatelessWidget {
  final Ingredient ingredient;
  final bool isSelected;

  const _IngredientItem({
    required this.ingredient,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isSelected
            ? AppTheme.primaryGreen.withAlpha((255 * 0.05).round())
            : Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: isSelected
            ? Border.all(color: AppTheme.primaryGreen, width: 1)
            : null,
      ),
      child: Row(
        children: [
          // Bullet point
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.primaryGreen : Colors.grey[600],
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          // Ingredient name
          Expanded(
            child: Text(
              ingredient.name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? AppTheme.primaryGreen : Colors.black87,
              ),
            ),
          ),
          // Measurement
          if (ingredient.measurement != null &&
              ingredient.measurement!.isNotEmpty)
            Text(
              ingredient.measurement!,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
        ],
      ),
    );
  }
}
