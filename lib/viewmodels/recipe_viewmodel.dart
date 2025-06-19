import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/recipe.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';


class RecipeViewModel extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();
  String _sortOption = 'name'; // default
  String get sortOption => _sortOption;
  final StorageService _storageService = StorageService();
  AuthService get authService => _authService;

  List<Map<String, dynamic>> _ingredients = [];
  bool isLoading = false;

  // ========== AI Recommended Recipes ==========
  List<Recipe> _aiRecommendedRecipes = [];
  String _searchQuery = '';
  String _selectedCategory = 'All';

  List<Recipe> get aiRecommendedRecipes => _aiRecommendedRecipes;

  List<Recipe> get filteredAiRecipes {
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
      _ingredients = await _firestoreService.fetchIngredients(userId);

      final ingredientsJson = _ingredients.map((ingredient) => {
        "name": ingredient['name'],
      }).toList();

      final uri = Uri.parse('http://192.168.1.8:5000/recommend');
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
        await _fetchUserFavourites(userId);
      } else {
        print("Failed to get recommendations: ${response.body}");
      }
    } catch (e) {
      print("API Error: $e");
    }

    isLoading = false;
    notifyListeners();
  }

  // ========== Favourite Logic ==========
  Set<String> _favouriteRecipeIds = {};

  Future<void> _fetchUserFavourites(String userId) async {
    _favouriteRecipeIds = await _firestoreService.getFavouriteRecipeIds(userId);
    notifyListeners();
  }

  bool isFavourite(String recipeId) => _favouriteRecipeIds.contains(recipeId);

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

    await _firestoreService.updateRecipeFavouriteCount(recipe.id, recipe.numberFavourites);
    notifyListeners();
  }

  // ========== Community Recipes ==========
  List<Recipe> _allRecipes = [];
  List<Recipe> _filteredRecipes = [];

  List<Recipe> get allRecipes => _filteredRecipes;
  List<Recipe> get favouriteRecipes =>
      _allRecipes.where((r) => isFavourite(r.id)).toList();

  Future<void> fetchAllRecipesWithFavourites() async {
    final userId = _authService.userId;
    if (userId == null) return;

    _allRecipes = await _firestoreService.fetchAllRecipes();
    _favouriteRecipeIds = await _firestoreService.getFavouriteRecipeIds(userId);
    _applyFilters();
    notifyListeners();
  }

  void filterRecipes(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  
  
  void updateSortOption(String option) {
    _sortOption = option;
    _applyFilters(); // apply sorting after setting new option
    notifyListeners();
  }

  void _applyFilters() {
    _filteredRecipes = _allRecipes.where((recipe) {
      return recipe.dishName.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    if (_sortOption == 'name') {
      _filteredRecipes.sort((a, b) => a.dishName.compareTo(b.dishName));
    } else if (_sortOption == 'favourites') {
      _filteredRecipes.sort((b, a) => a.numberFavourites.compareTo(b.numberFavourites)); // Descending
    }
  }
  List<Recipe> get userRecipes {
    final userId = _authService.userId;
    return _allRecipes.where((recipe) => recipe.userId == userId).toList();
  }

  Future<void> deleteRecipe(String recipeId, String imageUrl) async {
    await _firestoreService.deleteRecipe(recipeId);
    await _storageService.deleteImageByUrl(imageUrl);
    await fetchAllRecipesWithFavourites();
  }

}
