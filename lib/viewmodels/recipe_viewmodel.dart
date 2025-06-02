import 'package:flutter/material.dart';
import '../models/recipe.dart';

class RecipeViewModel extends ChangeNotifier {
  final List<Recipe> _allRecipes = [
   Recipe(
      title: "Cheese Omelette",
      ingredients: ["eggs", "cheese"],
      category: "Breakfast",
      imageUrl: "https://www.emborg.com/app/uploads/2023/07/1200x900px_Easy_Cheese_Omelette.png", 
    ),
    Recipe(
      title: "Pasta",
      ingredients: ["pasta", "cheese", "tomato"],
      category: "Lunch",
      imageUrl: "https://cdn.jwplayer.com/v2/media/87SkVc26/thumbnails/68gtqAmf.jpg",
    ),
  ];

  String _searchQuery = '';
  String _selectedCategory = 'All';

  List<Recipe> get filteredRecipes {
    return _allRecipes.where((recipe) {
      final matchesCategory = _selectedCategory == 'All' || recipe.category == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          recipe.title.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  List<String> get categories => ['All', 'Breakfast', 'Lunch', 'Dinner'];

  String get selectedCategory => _selectedCategory;

  void updateSearch(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void updateCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }
}
