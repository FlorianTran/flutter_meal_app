import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/entities/category.dart';
import '../../../../core/theme/app_theme.dart';

/// Card widget for category
class CategoryCard extends StatelessWidget {
  final Category category;
  final VoidCallback? onTap;

  const CategoryCard({
    super.key,
    required this.category,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              constraints: const BoxConstraints(minWidth: 140),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(24),
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
              child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Small rounded image
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: category.image != null
                  ? CachedNetworkImage(
                      imageUrl: category.image!,
                      width: 28,
                      height: 28,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        width: 28,
                        height: 28,
                        color: Colors.grey[300],
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                      errorWidget: (context, url, error) => _buildPlaceholderIcon(),
                    )
                  : _buildPlaceholderIcon(),
            ),
            const SizedBox(width: 10),
            // Category name
            Flexible(
              child: Text(
                category.name,
                style: TextStyle(
                  fontFamily: AppTheme.getFontFamily(FontWeight.w500),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textBlack,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderIcon() {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(
        Icons.category,
        size: 16,
        color: Colors.grey[600],
      ),
    );
  }
}

