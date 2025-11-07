import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/meal.dart';

part 'favorites_state.freezed.dart';

@freezed
class FavoritesState with _$FavoritesState {
  const factory FavoritesState({
    @Default(false) bool isLoading,
    @Default([]) List<Meal> meals,
    String? error,
  }) = _FavoritesState;
}
