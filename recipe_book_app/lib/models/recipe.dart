class Recipe {
  final String name;
  final String imagePath;
  final List<String> ingredients;
  final String instructions;
  bool isFavorite;

  Recipe({
    required this.name,
    required this.imagePath,
    required this.ingredients,
    required this.instructions,
    this.isFavorite = false,
  });
}
