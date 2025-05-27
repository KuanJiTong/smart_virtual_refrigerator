import 'package:flutter/material.dart';

enum ExpiryFilter { all, expiringSoon }
enum QuantityFilter { all, lowStock }
enum SortOrder { nameAZ, expirySoonest, quantityHighToLow }


class FridgeViewModel extends ChangeNotifier {
  String selectedCategory = 'All';
  String searchKeyword = '';
  ExpiryFilter expiryFilter = ExpiryFilter.all;
  QuantityFilter quantityFilter = QuantityFilter.all;
  SortOrder sortOrder = SortOrder.nameAZ;


  final List<Map<String, dynamic>> allIngredients = [
    {
      'category': 'Vegetables',
      'image': 'potatoes.jpg',
      'quantity': '600g',
      'name': 'Potatoes',
      'expiredDate': '2025-05-25',
      'daysLeftToExpire': 4,
    },
    {
      'category': 'Meat',
      'image': 'massimo.jpg',
      'quantity': '12pcs',
      'name': 'Chicken Breast',
      'expiredDate': '2025-05-23',
      'daysLeftToExpire': 2,
    },
    {
      'category': 'Fruit',
      'image': 'bananas.jpg',
      'quantity': '6pcs',
      'name': 'Banana',
      'expiredDate': '2025-05-21',
      'daysLeftToExpire': 0,
    },
  ];

  final List<Map<String, dynamic>> allLeftovers = [
    {
      'image': 'chicken_rice.jpg',
      'title': 'Chicken breast with rice',
      'date': '17/04/25',
      'quantity': 2
    },
    {
      'image': 'sushi.jpg',
      'title': 'Sushi rolls',
      'date': '26/04/25',
      'quantity': 3
    },
    {
      'image': 'sushi.jpg',
      'title': 'Sushi rolls',
      'date': '26/04/25',
      'quantity': 3
    },
    {
      'image': 'sushi.jpg',
      'title': 'Sushi rolls',
      'date': '26/04/25',
      'quantity': 3
    },
    {
      'image': 'sushi.jpg',
      'title': 'Sushi rolls',
      'date': '26/04/25',
      'quantity': 3
    },
  ];

  bool isLoading = false;

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

    // Sorting
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
