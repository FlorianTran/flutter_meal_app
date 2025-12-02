/// Category entity
class Category {
  final String name;
  final String? description;
  final String? image;

  Category({
    required this.name,
    this.description,
    this.image,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Category && other.name == name;
  }

  @override
  int get hashCode => name.hashCode;
}
