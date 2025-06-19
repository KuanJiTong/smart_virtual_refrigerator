class Recipe {
  final String id; // <-- Added ID field
  final String dishName;
  final String style;
  final String imageUrl;
  final String description;
  final String category;
  int numberFavourites; // <-- Made mutable
  final String userId;
  final List<Map<String, dynamic>> ingredients;
  final List<dynamic> cookingSteps;

  Recipe({
    required this.id, // <-- Added to constructor
    required this.dishName,
    required this.style,
    required this.imageUrl,
    required this.description,
    required this.category,
    required this.numberFavourites,
    required this.userId,
    required this.ingredients,
    required this.cookingSteps,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'] ?? '', // <-- Parse the ID
      dishName: json['dish_name'] ?? '',
      style: json['style'] ?? '',
      imageUrl: json['image_url'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      numberFavourites: json['number_favourites'] ?? 0,
      userId: json['userId'] ?? '',
      ingredients: (json['ingredients'] as List<dynamic>)
          .map((item) => item as Map<String, dynamic>)
          .toList(),
      cookingSteps: json['cooking_steps'] ?? [],
    );
  }

  factory Recipe.fromFirestore(Map<String, dynamic> data, String id) {
  return Recipe(
    id: id,
    dishName: data['dish_name'] ?? '',
    description: data['description'] ?? '',
    style: data['style'] ?? '',
    category: data['category'] ?? '',
    imageUrl: data['image_url'] ?? '',
    userId: data['userId'] ?? '',
    ingredients: List<Map<String, dynamic>>.from(data['ingredients'] ?? []),
    cookingSteps: List<String>.from(data['cooking_steps']?.cast<String>() ?? []),
    numberFavourites: data['number_favourites'] ?? 0,
  );
}



}
