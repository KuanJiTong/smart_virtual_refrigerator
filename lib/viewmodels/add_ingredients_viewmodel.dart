import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

import '../services/storage_service.dart';

class AddIngredientViewModel extends ChangeNotifier {
  String name = '';
  String category = 'Bread';
  String quantity = '';
  String quantityUnit = '';
  String storageLocation = '';
  DateTime? expirationDate;
  bool hasExpiry = true;
  String imageUrl = '';

  final FirestoreService _firestoreService = FirestoreService();
  final StorageService _storageService = StorageService();

  Future<String> uploadPickedImageToFirebase(File pickedImageFile) async {
    if (pickedImageFile == null) return '';

    imageUrl = await _storageService.uploadIngredientImage(pickedImageFile!);
    notifyListeners();
    return imageUrl;

  }

  void updateName(String value) {
    name = value;
    notifyListeners();
  }

  void updateStorageLocation(String value) {
    storageLocation = value;
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

  void updateQuantityUnit(String value) {
    quantityUnit = value;
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
      quantityUnit: quantityUnit,
      storageLocation: storageLocation,
      hasExpiry: hasExpiry,
      expirationDate: expirationDate,
      imageUrl: imageUrl,
    );
  }
}
