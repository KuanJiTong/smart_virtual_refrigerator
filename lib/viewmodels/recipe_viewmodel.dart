import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/recipe.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class RecipeViewModel extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();

  List<Map<String, dynamic>> _ingredients = [];
  List<Recipe> _aiRecommendedRecipes = [];
  bool isLoading = false;

  String _searchQuery = '';
  String _selectedCategory = 'All';

  Set<String> _favouriteRecipeIds = {};

  List<Recipe> get aiRecommendedRecipes => _aiRecommendedRecipes;

  List<Recipe> get filteredRecipes {
    return _aiRecommendedRecipes.where((recipe) {
      final matchesCategory = _selectedCategory == 'All' || recipe.category == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          recipe.dishName.toLowerCase().contains(_searchQuery.toLowerCase());
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

  Future<void> fetchAIRecommendations() async {
    final userId = _authService.userId;
    if (userId == null) {
      print('No userId found');
      return;
    }

    isLoading = true;
    notifyListeners();

    try {
      // Fetch ingredients
      _ingredients = await _firestoreService.fetchIngredients(userId);

      final ingredientsJson = _ingredients.map((ingredient) => {
        "name": ingredient['name'],
      }).toList();

      final uri = Uri.parse('http://192.168.1.3:5000/recommend');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'ingredients': ingredientsJson}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _aiRecommendedRecipes = (data['recommendations'] as List)
            .map((r) => Recipe.fromJson(r))
            .toList();

        await _fetchUserFavourites(userId); // Load user's favourites
      } else {
        print("Failed to get recommendations: ${response.body}");
      }
    } catch (e) {
      print("API Error: $e");
    }

    isLoading = false;
    notifyListeners();
  }

  // Fetch favourited recipe IDs for current user
  Future<void> _fetchUserFavourites(String userId) async {
    _favouriteRecipeIds = await _firestoreService.getFavouriteRecipeIds(userId);
    notifyListeners();
  }

  // Check if a recipe is favourited
  bool isFavourite(String recipeId) {
    return _favouriteRecipeIds.contains(recipeId);
  }

  // Toggle favourite status
  Future<void> toggleFavourite(Recipe recipe) async {
    final userId = _authService.userId;
    if (userId == null) return;

    if (isFavourite(recipe.id)) {
      _favouriteRecipeIds.remove(recipe.id);
      await _firestoreService.removeFromFavourites(userId, recipe.id);
      recipe.numberFavourites -= 1;
    } else {
      _favouriteRecipeIds.add(recipe.id);
      await _firestoreService.addToFavourites(userId, recipe.id);
      recipe.numberFavourites += 1;
    }

    // Update the number of favourites in Firestore
    await _firestoreService.updateRecipeFavouriteCount(recipe.id, recipe.numberFavourites);

    notifyListeners();
  }
}
