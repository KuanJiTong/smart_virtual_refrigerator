import 'package:flutter/material.dart';

class FridgeViewModel extends ChangeNotifier {
  String selectedCategory = 'All';

  final List<Map<String, dynamic>> allIngredients = [
    {'category': 'Vegetables', 'image': 'potatoes.jpg', 'quantity': '600g'},
    {'category': 'Meat', 'image': 'massimo.jpg', 'quantity': '12pcs'},
    {'category': 'Meat', 'image': 'massimo.jpg', 'quantity': '12pcs'},
    {'category': 'Meat', 'image': 'massimo.jpg', 'quantity': '12pcs'},
    {'category': 'Meat', 'image': 'massimo.jpg', 'quantity': '12pcs'},
    {'category': 'Meat', 'image': 'massimo.jpg', 'quantity': '12pcs'},
    {'category': 'Fruit', 'image': 'massimo.jpg', 'quantity': '12pcs'},
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
    if (selectedCategory == 'All') {
      return allIngredients;
    } else {
      return allIngredients
          .where((item) => item['category'] == selectedCategory)
          .toList();
    }
  }

  void setCategory(String category) {
    selectedCategory = category;
    notifyListeners();
  }

  void setLoading(bool loading) {
    isLoading = loading;
    notifyListeners();
  }
}
