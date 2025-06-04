import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import '../services/firestore_service.dart';
import '../services/storage_service.dart';

class UpdateIngredientsViewModel extends ChangeNotifier {
  String _name = '';
  String _category = '';
  String _quantity = '0';
  bool _hasExpiry = true;
  DateTime? _expirationDate;
  String _imageUrl = '';

  final FirestoreService _firestoreService = FirestoreService();
  final StorageService _storageService = StorageService();

  void updateName(String name) {
    _name = name;
    notifyListeners();
  }

  void updateCategory(String category) {
    _category = category;
    notifyListeners();
  }

  void updateQuantity(String quantity) {
    _quantity = quantity;
    notifyListeners();
  }

  void toggleExpiry(bool value) {
    _hasExpiry = value;
    notifyListeners();
  }

  void updateExpirationDate(DateTime date) {
    _expirationDate = date;
    notifyListeners();
  }

  void setImage(String url) {
    _imageUrl = url;
    notifyListeners();
  }

  Future<String> uploadPickedImageToFirebase(File pickedImageFile) async {
    if (pickedImageFile == null) return '';

    _imageUrl = await _storageService.uploadIngredientImage(pickedImageFile!);
    notifyListeners();
    return _imageUrl;

  }

  Future<void> updateIngredientInFirebase(String _id) async {
    if (_id == null) {
      throw Exception("Ingredient ID not provided.");
    }

    await _firestoreService.updateIngredient(
      docId: _id,
      name: _name,
      category: _category,
      quantity: _quantity,
      hasExpiry: _hasExpiry,
      expirationDate: _expirationDate,
      imageUrl: _imageUrl,
    );
  }

  Future<void> deleteIngredientFromFirebase(String _id) async {
    if (_id == null) {
      throw Exception("Ingredient ID not provided.");
    }

    await _firestoreService.deleteIngredient(_id);
  }
}
