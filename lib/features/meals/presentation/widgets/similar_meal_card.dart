import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/meal.dart';

/// Card widget for displaying a similar meal
class SimilarMealCard extends StatelessWidget {
  final Meal meal;
  final VoidCallback? onTap;
  final int? commonIngredientsCount;
  final int? totalIngredientsCount;

  const SimilarMealCard({
    super.key,
    required this.meal,
    this.onTap,
    this.commonIngredientsCount,
    this.totalIngredientsCount,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Meal image
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: AspectRatio(
                aspectRatio: 1.0,
                child: meal.image != null
                    ? CachedNetworkImage(
                        imageUrl: meal.image!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[200],
                          child:
                              const Center(child: CircularProgressIndicator()),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.restaurant, size: 40),
                        ),
                      )
                    : Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.restaurant, size: 40),
                      ),
              ),
            ),

            // Meal info
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Meal name
                  Text(
                    meal.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 8),

                  // Similarity indicator (if provided)
                  if (commonIngredientsCount != null &&
                      totalIngredientsCount != null)
                    Row(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          size: 14,
                          color: AppTheme.primaryGreen,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$commonIngredientsCount/$totalIngredientsCount ingredients',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    )
                  else if (meal.ingredients.isNotEmpty)
                    Text(
                      '${meal.ingredients.length} ingredients',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                    ),

                  // Category tag (if available)
                  if (meal.category != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        meal.category!,
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppTheme.primaryGreen,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
