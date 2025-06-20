import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/firestore_service.dart';
import '../services/storage_service.dart';
import '../models/recipe.dart';

class CreateRecipeViewModel extends ChangeNotifier {
  // Controllers
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final styleController = TextEditingController();
  final List<Map<String, dynamic>> ingredients = [];
  final List<TextEditingController> cookingSteps = [];

  // Edit state
  String selectedCategory = 'Breakfast';
  String recipeId = ''; // <-- Needed for update
  String imageUrl = '';
  File? pickedImage;
  bool isLoading = false;

  final List<String> categories = ['Breakfast', 'Lunch', 'Dinner', 'Dessert'];
  final List<String> quantityUnits = [
    'Gram', 'Milliliter', 'Slice', 'Piece', 'Tablespoon',
    'Cup', 'Teaspoon', 'Stalk', 'Clove', 'Inch', 'Whole', 'Unit'
  ];

  final FirestoreService _firestoreService = FirestoreService();
  final StorageService _storageService = StorageService();

  // Constructor to load data if editing
  CreateRecipeViewModel({Recipe? editRecipe}) {
    if (editRecipe != null) {
      _loadRecipeData(editRecipe);
    }
  }

  void _loadRecipeData(Recipe recipe) {
    recipeId = recipe.id;
    imageUrl = recipe.imageUrl;
    nameController.text = recipe.dishName;
    descriptionController.text = recipe.description;
    styleController.text = recipe.style;
    selectedCategory = recipe.category;

    for (var ing in recipe.ingredients) {
      ingredients.add({
        'name': TextEditingController(text: ing['name']),
        'quantity': TextEditingController(text: ing['quantity']),
        'unit': ing['unit'] ?? quantityUnits.first,
      });
    }

    for (var step in recipe.cookingSteps) {
      cookingSteps.add(TextEditingController(text: step));
    }
  }

  Future<void> pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source);
    if (picked != null) {
      pickedImage = File(picked.path);
      notifyListeners();
    }
  }

  void addIngredient() {
    ingredients.add({
      'name': TextEditingController(),
      'quantity': TextEditingController(),
      'unit': quantityUnits.first,
    });
    notifyListeners();
  }

  void removeIngredient(int index) {
    ingredients.removeAt(index);
    notifyListeners();
  }

  void addCookingStep() {
    cookingSteps.add(TextEditingController());
    notifyListeners();
  }

  void removeCookingStep(int index) {
    cookingSteps.removeAt(index);
    notifyListeners();
  }

Future<bool> submitRecipe(GlobalKey<FormState> formKey) async {
  if (!formKey.currentState!.validate()) return false;

  isLoading = true;
  notifyListeners();

  try {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    // Upload image if changed
    String finalImageUrl = imageUrl;
    if (pickedImage != null) {
      finalImageUrl = await _storageService.uploadIngredientImage(pickedImage!);
    }

    final List<Map<String, String>> formattedIngredients = ingredients.map((i) => {
      'name': (i['name'] as TextEditingController).text.trim(),
      'quantity': (i['quantity'] as TextEditingController).text.trim(),
      'unit': i['unit'].toString(),
    }).toList();

    final List<String> formattedCookingSteps =
        cookingSteps.map((c) => c.text.trim()).toList();

    if (recipeId.isNotEmpty) {
      await _firestoreService.updateRecipe(
        recipeId: recipeId,
        dishName: nameController.text.trim(),
        description: descriptionController.text.trim(),
        style: styleController.text.trim(),
        ingredients: formattedIngredients,
        cookingSteps: formattedCookingSteps,
        imageUrl: finalImageUrl,
        category: selectedCategory,
      );
    } else {
      await _firestoreService.addRecipe(
        dishName: nameController.text.trim(),
        description: descriptionController.text.trim(),
        style: styleController.text.trim(),
        ingredients: formattedIngredients,
        cookingSteps: formattedCookingSteps,
        imageUrl: finalImageUrl,
        category: selectedCategory,
        numberFavourites: 0,
        userId: userId,
        status: 'pending'
      );
    }

    return true;
  } catch (e) {
    debugPrint("🔥 Error submitting recipe: $e");
    return false;
  } finally {
    isLoading = false;
    notifyListeners();
  }
}

}
