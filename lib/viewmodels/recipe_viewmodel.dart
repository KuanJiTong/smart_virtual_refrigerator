import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/recipe.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class RecipeViewModel extends ChangeNotifier {

  List<Map<String, dynamic>> _ingredients = [];
  List<Recipe> _aiRecommendedRecipes = [];
  bool isLoading = false;

  List<Recipe> get aiRecommendedRecipes => _aiRecommendedRecipes;
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();

  Future<void> fetchAIRecommendations() async {
    final userId = _authService.userId;
    if (userId == null) {
      print('No userId found');
      return;
    }

    isLoading = true;
    notifyListeners();

    try {
      // Fetch ingredients first
      _ingredients = await _firestoreService.fetchIngredients(userId);

      final ingredientsJson = _ingredients.map((ingredient) => {
        "name": ingredient['name'],
        // Add other fields if your backend expects them
      }).toList();

      print("Sending ingredients: $ingredientsJson");

      final uri = Uri.parse('http://192.168.1.10:5000/recommend');
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
      } else {
        print("Failed to get recommendations: ${response.body}");
      }
    } catch (e) {
      print("API Error: $e");
    }

    isLoading = false;
    notifyListeners();
  }

  String _searchQuery = '';
  String _selectedCategory = 'All';

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
}
