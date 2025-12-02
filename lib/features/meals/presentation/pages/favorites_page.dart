import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../notifier/favorites_notifier.dart';
import '../notifier/favorites_state.dart';
import '../widgets/meal_card.dart';
import 'meal_details_page.dart';

/// Page displaying favorite meals
class FavoritesPage extends ConsumerWidget {
  const FavoritesPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute(
      builder: (context) => const FavoritesPage(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(favoritesNotifierProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Favorites'),
        actions: [
          if (state.meals.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Clear all',
              onPressed: () => _showClearDialog(context, ref),
            ),
        ],
      ),
      body: _buildContent(context, ref, state),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    FavoritesState state,
  ) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                'Error: ${state.error}',
                style: TextStyle(
                  fontFamily: AppTheme.getFontFamily(null),
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.read(favoritesNotifierProvider.notifier).loadFavorites();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (state.meals.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.star_border_rounded,
                  size: 64, color: const Color(0xFFFFCC00).withOpacity(0.6)),
              const SizedBox(height: 16),
              Text(
                'No favorite meals yet',
                style: TextStyle(
                  fontFamily: AppTheme.getFontFamily(FontWeight.w500),
                  fontSize: 18,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tap the star icon on any meal to add it to favorites',
                style: TextStyle(
                  fontFamily: AppTheme.getFontFamily(null),
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(favoritesNotifierProvider.notifier).loadFavorites();
      },
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.75,
        ),
        itemCount: state.meals.length,
        itemBuilder: (context, index) {
          final meal = state.meals[index];
          return MealCard(
            meal: meal,
            isFavorite: true,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => MealDetailsPage(mealId: meal.id),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _showClearDialog(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Favorites'),
        content: const Text(
          'Are you sure you want to remove all favorite meals?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(favoritesNotifierProvider.notifier).clearAll();
    }
  }
}
