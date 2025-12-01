import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/entities/meal.dart';
import '../../../../core/theme/app_theme.dart';

/// Card widget for displaying a meal
class MealCard extends StatelessWidget {
  final Meal meal;
  final VoidCallback? onTap;
  final bool isFavorite;
  final VoidCallback? onFavoriteTap;

  const MealCard({
    super.key,
    required this.meal,
    this.onTap,
    this.isFavorite = false,
    this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 32,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Gradient highlight lines (simulating ::before and ::after)
                // Top horizontal gradient line
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.white.withOpacity(0.95),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                ),
                // Left vertical gradient line
                Positioned(
                  top: 0,
                  left: 0,
                  width: 1,
                  bottom: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withOpacity(0.8),
                          Colors.transparent,
                          Colors.white.withOpacity(0.3),
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                ),
                // Main content
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Meal image with favorite button overlay
                    ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(20)),
                      child: AspectRatio(
                        aspectRatio: 4 / 3,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            meal.image != null
                                ? CachedNetworkImage(
                                    imageUrl: meal.image!,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Container(
                                      color: Colors.grey[300],
                                      child: const Center(
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2),
                                      ),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        Container(
                                      color: Colors.grey[300],
                                      child: const Icon(Icons.restaurant,
                                          size: 48),
                                    ),
                                  )
                                : Container(
                                    color: Colors.grey[300],
                                    child:
                                        const Icon(Icons.restaurant, size: 48),
                                  ),
                            // Favorite button in top right
                            Positioned(
                              top: 8,
                              right: 8,
                              child: GestureDetector(
                                onTap: () {
                                  if (onFavoriteTap != null) {
                                    onFavoriteTap!();
                                  }
                                },
                                child: Icon(
                                  isFavorite
                                      ? Icons.star_rounded
                                      : Icons.star_border_rounded,
                                  color: const Color(0xFFFFCC00),
                                  size: 32,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Meal info - Flexible to prevent overflow
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              meal.name,
                              style: TextStyle(
                                fontFamily:
                                    AppTheme.getFontFamily(FontWeight.w600),
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textBlack,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 3),
                            if (meal.category != null || meal.area != null)
                              Row(
                                children: [
                                  if (meal.category != null)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 5,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        meal.category!,
                                        style: TextStyle(
                                          fontFamily: AppTheme.getFontFamily(
                                              FontWeight.w500),
                                          fontSize: 11,
                                          color: AppTheme.textBlack,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  if (meal.category != null &&
                                      meal.area != null)
                                    const SizedBox(width: 5),
                                  if (meal.area != null)
                                    Flexible(
                                      child: Text(
                                        meal.area!,
                                        style: TextStyle(
                                          fontFamily:
                                              AppTheme.getFontFamily(null),
                                          fontSize: 11,
                                          color: AppTheme.textBlack,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                ],
                              ),
                            const SizedBox(height: 3),
                            // Show ingredient count only if ingredients are available
                            // Filter endpoint returns simplified meals without ingredients
                            meal.ingredients.isNotEmpty
                                ? Text(
                                    '${meal.ingredients.length} ingredients',
                                    style: TextStyle(
                                      fontFamily: AppTheme.getFontFamily(null),
                                      fontSize: 12,
                                      color: AppTheme.textBlack,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  )
                                : Text(
                                    'Tap to view details',
                                    style: TextStyle(
                                      fontFamily: AppTheme.getFontFamily(
                                          FontWeight.w300),
                                      fontSize: 12,
                                      color: AppTheme.textBlack,
                                      fontStyle: FontStyle.italic,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
