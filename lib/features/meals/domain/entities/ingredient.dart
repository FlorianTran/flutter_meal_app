/// Ingredient entity
class Ingredient {
  final String name;
  final String? description;
  final String? image;

  Ingredient({
    required this.name,
    this.description,
    this.image,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Ingredient && other.name == name;
  }

  @override
  int get hashCode => name.hashCode;
}
