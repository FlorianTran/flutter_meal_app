import '../../../../core/error/failures.dart';
import '../entities/meal.dart';
import '../repositories/meals_repository.dart';

/// Use case to get similar meals based on category, area, and ingredient overlap
/// Similarity is calculated by:
/// 1. Same category (high priority)
/// 2. Same area (medium priority)
/// 3. Ingredient overlap percentage (high priority)
/// 4. Similar name/keywords (low priority)
class GetSimilarMeals {
  final MealsRepository repository;

  GetSimilarMeals(this.repository);

  Future<({Failure? failure, List<Meal>? meals})> call(Meal meal,
      {int limit = 12}) async {
    if (meal.id.isEmpty) {
      return (
        failure: const GeneralFailure('Meal ID cannot be empty'),
        meals: null,
      );
    }

    final similarMeals = <Meal>[];
    final candidateMeals = <Meal>[];

    // 1. Fetch meals from same category
    if (meal.category != null && meal.category!.isNotEmpty) {
      final categoryResult =
          await repository.getMealsByCategory(meal.category!);
      if (categoryResult.failure == null && categoryResult.meals != null) {
        candidateMeals.addAll(categoryResult.meals!);
      }
    }

    // 2. Fetch meals from same area
    if (meal.area != null && meal.area!.isNotEmpty) {
      final areaResult = await repository.getMealsByArea(meal.area!);
      if (areaResult.failure == null && areaResult.meals != null) {
        candidateMeals.addAll(areaResult.meals!);
      }
    }

    // Remove the current meal and duplicates
    final uniqueCandidates = <String, Meal>{};
    for (final candidate in candidateMeals) {
      if (candidate.id != meal.id) {
        uniqueCandidates[candidate.id] = candidate;
      }
    }

    // 3. Calculate similarity scores for each candidate
    final scoredMeals = <({Meal meal, double score})>[];
    final mealIngredientNames = meal.ingredients
        .map((ing) => ing.name.toLowerCase().trim())
        .where((name) => name.isNotEmpty)
        .toSet();

    for (final candidate in uniqueCandidates.values) {
      double score = 0.0;

      // Category match (weight: 2.0)
      if (candidate.category != null &&
          candidate.category!.toLowerCase() == meal.category?.toLowerCase()) {
        score += 2.0;
      }

      // Area match (weight: 1.5)
      if (candidate.area != null &&
          candidate.area!.toLowerCase() == meal.area?.toLowerCase()) {
        score += 1.5;
      }

      // Ingredient overlap (weight: 3.0 per ingredient)
      if (candidate.ingredients.isNotEmpty && mealIngredientNames.isNotEmpty) {
        final candidateIngredientNames = candidate.ingredients
            .map((ing) => ing.name.toLowerCase().trim())
            .where((name) => name.isNotEmpty)
            .toSet();

        final commonIngredients =
            mealIngredientNames.intersection(candidateIngredientNames);
        final totalIngredients =
            mealIngredientNames.union(candidateIngredientNames).length;

        if (totalIngredients > 0) {
          final overlapPercentage = commonIngredients.length / totalIngredients;
          score += overlapPercentage * 3.0 * commonIngredients.length;
        }
      }

      // Name similarity (weight: 0.5)
      final mealNameWords = meal.name.toLowerCase().split(RegExp(r'\s+'));
      final candidateNameWords =
          candidate.name.toLowerCase().split(RegExp(r'\s+'));
      final commonWords =
          mealNameWords.toSet().intersection(candidateNameWords.toSet());
      if (commonWords.isNotEmpty && mealNameWords.isNotEmpty) {
        final nameSimilarity = commonWords.length / mealNameWords.length;
        score += nameSimilarity * 0.5;
      }

      scoredMeals.add((meal: candidate, score: score));
    }

    // 4. Sort by score (descending) and take top results
    scoredMeals.sort((a, b) => b.score.compareTo(a.score));
    similarMeals.addAll(
      scoredMeals.take(limit).map((scored) => scored.meal),
    );

    return (failure: null, meals: similarMeals);
  }
}
