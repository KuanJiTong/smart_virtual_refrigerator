import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';

enum ExpiryFilter { all, expiringSoon }
enum QuantityFilter { all, lowStock }
enum SortOrder { nameAZ, expirySoonest, quantityHighToLow }

class FridgeViewModel extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();

  String selectedCategory = 'All';
  String searchKeyword = '';
  ExpiryFilter expiryFilter = ExpiryFilter.all;
  QuantityFilter quantityFilter = QuantityFilter.all;
  SortOrder sortOrder = SortOrder.nameAZ;

  List<Map<String, dynamic>> allIngredients = [];
  List<Map<String, dynamic>> allLeftovers = [];
  
  bool isLoading = false;

  Future<void> loadIngredients() async {
    final userId = _authService.userId;
    if (userId == null) {
      print('No userId found');
      return;
    }

    isLoading = true;
    notifyListeners();

    try {
      allIngredients = await _firestoreService.fetchIngredients(userId);
      print('Fetched ingredients: $allIngredients');
    } catch (e) {
      print('Error loading ingredients: $e');
      allIngredients = [];
    }

    isLoading = false;
    notifyListeners();
  }

  List<Map<String, dynamic>> get filteredIngredients {
    List<Map<String, dynamic>> filtered = allIngredients.where((item) {
      final matchesCategory = selectedCategory == 'All' || item['category'] == selectedCategory;
      final matchesSearch = item['name'].toString().toLowerCase().contains(searchKeyword.toLowerCase());
      final matchesExpiry = expiryFilter == ExpiryFilter.all ||
          (expiryFilter == ExpiryFilter.expiringSoon && item['daysLeftToExpire'] <= 2);
      final matchesQuantity = quantityFilter == QuantityFilter.all ||
          (quantityFilter == QuantityFilter.lowStock && _isLowStock(item['quantity']));

      return matchesCategory && matchesSearch && matchesExpiry && matchesQuantity;
    }).toList();

    switch (sortOrder) {
      case SortOrder.nameAZ:
        filtered.sort((a, b) => a['name'].compareTo(b['name']));
        break;
      case SortOrder.expirySoonest:
        filtered.sort((a, b) => a['daysLeftToExpire'].compareTo(b['daysLeftToExpire']));
        break;
      case SortOrder.quantityHighToLow:
        filtered.sort((a, b) => _extractQuantity(b['quantity']).compareTo(_extractQuantity(a['quantity'])));
        break;
    }

    return filtered;
  }

  bool _isLowStock(String quantity) {
    final number = _extractQuantity(quantity);
    return number <= 5;
  }

  int _extractQuantity(String quantity) {
    final digits = RegExp(r'\d+').stringMatch(quantity);
    return int.tryParse(digits ?? '0') ?? 0;
  }

  void setCategory(String category) {
    selectedCategory = category;
    notifyListeners();
  }

  void setSearchKeyword(String keyword) {
    searchKeyword = keyword;
    notifyListeners();
  }

  void setExpiryFilter(ExpiryFilter filter) {
    expiryFilter = filter;
    notifyListeners();
  }

  void setQuantityFilter(QuantityFilter filter) {
    quantityFilter = filter;
    notifyListeners();
  }

  void setSortOrder(SortOrder order) {
    sortOrder = order;
    notifyListeners();
  }

  void clearFilters() {
    selectedCategory = 'All';
    expiryFilter = ExpiryFilter.all;
    quantityFilter = QuantityFilter.all;
    sortOrder = SortOrder.nameAZ;
    searchKeyword = '';
    notifyListeners();
  }

  void setLoading(bool loading) {
    isLoading = loading;
    notifyListeners();
  }
}
