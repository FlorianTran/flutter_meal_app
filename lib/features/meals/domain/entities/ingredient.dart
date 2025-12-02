/// Ingredient entity
class Ingredient {
  final String name;
  final String? description;
  final String? image;
  final String? measurement;

  const Ingredient({
    required this.name,
    this.description,
    this.image,
    this.measurement,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Ingredient &&
        other.name == name &&
        other.measurement == measurement;
  }

  @override
  int get hashCode => Object.hash(name, measurement);
}
