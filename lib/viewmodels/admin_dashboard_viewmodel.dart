import 'package:flutter/material.dart';
import 'package:smart_virtual_refrigerator/models/recipe.dart';
import 'package:smart_virtual_refrigerator/services/admin_dashboard_service.dart';

class AdminDashboardViewModel extends ChangeNotifier {
  final AdminDashboardService _adminDashboardService = AdminDashboardService();

  int _totalUsers = 1;
  int _totalRecipes = 0;
  int _totalPendingRecipes = 0;
  bool _loading = false;

  int get totalUsers => _totalUsers;
  int get totalRecipes => _totalRecipes;
  int get totalPendingRecipes => _totalPendingRecipes;
  bool get isLoading => _loading;

  List<Recipe> _pendingRecipes = [];
  List<Recipe> get pendingRecipes => _pendingRecipes;

  Future<void> loadDashboardStats() async {
    _loading = true;
    notifyListeners();

    try {
      _totalUsers = await _adminDashboardService.getTotalUserCount();
      _totalPendingRecipes = await _adminDashboardService.getTotalPendingRecipes();
      _totalRecipes = await _adminDashboardService.getTotalRecipeCount(); 
    } catch (e) {
      // handle errors (e.g. show error toast/snackbar)
      print('Error loading admin stats: $e');
    }

    _loading = false;
    notifyListeners();
  }

  Future<void> fetchPendingRecipes() async {
    try {
      _loading = true;
      _pendingRecipes = await _adminDashboardService.getPendingRecipes();
    } catch (e) {
      print('Error loading pending recipes: $e');
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> approveRecipe(String recipeId) async {
    await AdminDashboardService.approveRecipe(recipeId);
    await fetchPendingRecipes(); 
    await loadDashboardStats();
  }

  Future<void> rejectRecipe(String recipeId, String reason) async {
    await AdminDashboardService.rejectRecipe(recipeId, reason);
    await fetchPendingRecipes(); 
    await loadDashboardStats();
  }

}
