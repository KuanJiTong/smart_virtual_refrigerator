import 'package:flutter/material.dart';
import '../models/grocery.dart';
import '../models/ingredient.dart';
import '../models/leftover.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';

class GroceryListViewModel extends ChangeNotifier {
  final List<Grocery> _groceryList = [];
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();

  List<Grocery> get groceryList => List.unmodifiable(_groceryList);

   Future<void> addItem(Grocery item) async {
    _groceryList.add(item);
    notifyListeners();
    final userId = _authService.userId;
    if (userId != null) {
      await _firestoreService.addGrocery(userId: userId, groceryData: item.toJson());
    }
  }

  Future<void> addItems(List<Grocery> items) async {
    _groceryList.addAll(items);
    notifyListeners();
    final userId = _authService.userId;
    if (userId != null) {
      for (final item in items) {
        await _firestoreService.addGrocery(userId: userId, groceryData: item.toJson());
      }
    }
  }

  Future<void> removeItem(Grocery item) async {
    _groceryList.remove(item);
    notifyListeners();
    if (item.id != null) {
      await _firestoreService.deleteGrocery(item.id!);
    }
  }

  Future<void> clearList() async {
    final userId = _authService.userId;
    if (userId != null) {
      final groceries = await _firestoreService.fetchGroceries(userId);
      for (final grocery in groceries) {
        if (grocery['id'] != null) {
          await _firestoreService.deleteGrocery(grocery['id']);
        }
      }
    }
    _groceryList.clear();
    notifyListeners();
  }

  // Add items from expiring ingredients
  void addExpiringIngredients(List<Ingredient> ingredients) {
    for (final ingredient in ingredients) {
      final item = Grocery(
        name: ingredient.name,
        quantity: ingredient.quantity,
        unit: ingredient.quantityUnit,
        source: 'ingredient',
        imageUrl: ingredient.image,
        expiryDate: ingredient.expiredDate,
      );
      if (!_groceryList.any((g) => g.name == item.name && g.source == 'ingredient')) {
        _groceryList.add(item);
      }
    }
    notifyListeners();
  }

  // Add items from expiring leftovers
  void addExpiringLeftovers(List<Leftover> leftovers) {
    for (final leftover in leftovers) {
      final item = Grocery(
        name: leftover.name,
        quantity: leftover.quantity.toString(),
        unit: '',
        source: 'leftover',
        imageUrl: leftover.imageUrl,
        expiryDate: leftover.expiryDate,
      );
      if (!_groceryList.any((g) => g.name == item.name && g.source == 'leftover')) {
        _groceryList.add(item);
      }
    }
    notifyListeners();
  }

  // Add missing ingredients for a recipe (AI/bookmarked)
  void addRecipeIngredients(List<Map<String, dynamic>> ingredients) {
    for (final ingredient in ingredients) {
      final item = Grocery(
        name: ingredient['name'] ?? '',
        quantity: ingredient['quantity']?.toString() ?? '1',
        unit: ingredient['unit'] ?? '',
        source: 'recipe',
        imageUrl: null,
        expiryDate: null,
      );
      if (!_groceryList.any((g) => g.name == item.name && g.source == 'recipe')) {
        _groceryList.add(item);
      }
    }
    notifyListeners();
  }

   void addExpiringIngredient(Ingredient ingredient) {
    final item = Grocery(
      name: ingredient.name,
      quantity: ingredient.quantity,
      unit: ingredient.quantityUnit,
      source: 'ingredient',
      imageUrl: ingredient.image,
      expiryDate: ingredient.expiredDate,
    );
    if (!_groceryList.any((g) => g.name == item.name && g.source == 'ingredient')) {
      _groceryList.add(item);
      notifyListeners();
    }
  }

  void addExpiringLeftover(Leftover leftover) {
    final item = Grocery(
      name: leftover.name,
      quantity: leftover.quantity.toString(),
      unit: '',
      source: 'leftover',
      imageUrl: leftover.imageUrl,
      expiryDate: leftover.expiryDate,
    );
    if (!_groceryList.any((g) => g.name == item.name && g.source == 'leftover')) {
      _groceryList.add(item);
      notifyListeners();
    }
  }

  Future<void> toggleBought(Grocery item) async {
    final index = _groceryList.indexOf(item);
    if (index != -1) {
      _groceryList[index].bought = !_groceryList[index].bought;
      notifyListeners();
    }
  }

  Future<void> fetchGroceries() async {
    final userId = _authService.userId;
    if (userId != null) {
      final groceriesData = await _firestoreService.fetchGroceries(userId);
      _groceryList.clear();
      for (final data in groceriesData) {
        _groceryList.add(Grocery.fromJson(data));
      }
      notifyListeners();
    }
  }
} 