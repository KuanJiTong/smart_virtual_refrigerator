import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart'; // adjust the path as necessary

class IngredientViewModel extends ChangeNotifier {
  String name = '';
  String category = 'Bread';
  String quantity = '';
  DateTime? expirationDate;
  bool hasExpiry = true;
  String imageUrl = '';

  final FirestoreService _firestoreService = FirestoreService();

  void updateName(String value) {
    name = value;
    notifyListeners();
  }

  void updateCategory(String value) {
    category = value;
    notifyListeners();
  }

  void updateQuantity(String value) {
    quantity = value;
    notifyListeners();
  }

  void updateExpirationDate(DateTime date) {
    expirationDate = date;
    notifyListeners();
  }

  void toggleExpiry(bool value) {
    hasExpiry = value;
    notifyListeners();
  }

  void setImage(String url) {
    imageUrl = url;
    notifyListeners();
  }

  Future<void> addIngredientToFirebase() async {
    final userId = AuthService().userId; // Make sure _authService is initialized

    if (userId == null) {
      throw 'User is not logged in';
    }

    await _firestoreService.addIngredient(
      userId: userId,
      name: name,
      category: category,
      quantity: quantity,
      hasExpiry: hasExpiry,
      expirationDate: expirationDate,
      imageUrl: imageUrl,
    );
  }
}
