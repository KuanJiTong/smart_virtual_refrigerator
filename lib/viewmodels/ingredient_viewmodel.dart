import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/ingredient.dart';

class IngredientViewModel extends ChangeNotifier {
  final List<Ingredient> _ingredients = [];

  List<Ingredient> get ingredients => _ingredients;

 List<Ingredient> get expiringSoonIngredients {
    final now = DateTime.now();
    return _ingredients
        .where((i) =>
    i.expiredDate.isAfter(now) &&
        i.expiredDate.difference(now).inDays <= 5)
        .toList()
      ..sort((a, b) => a.expiredDate.compareTo(b.expiredDate));
  }


  Future<void> fetchIngredients(String userId) async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('ingredients')
          .where('userId', isEqualTo: userId)
          .get();

      _ingredients.clear();
      for (var doc in snapshot.docs) {
        _ingredients.add(Ingredient.fromMap(doc.data() as Map<String, dynamic>));
      }

      notifyListeners();
    } catch (e) {
      print("Error fetching ingredients: $e");
    }
  }
}
