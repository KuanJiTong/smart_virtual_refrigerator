import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/firestore_service.dart';
import '../services/storage_service.dart';

class CreateRecipeViewModel extends ChangeNotifier {
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final styleController = TextEditingController();

  final List<Map<String, dynamic>> ingredients = [];
  final List<TextEditingController> cookingSteps = [];

  final List<String> quantityUnits = [
    'Gram', 'Milliliter', 'Slice', 'Piece', 'Tablespoon', 'Cup', 'Unit'
  ];

  File? pickedImage;
  bool isLoading = false;

  final FirestoreService _firestoreService = FirestoreService();
  final StorageService _storageService = StorageService();

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
      'unit': quantityUnits.first
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

  Future<void> submitRecipe(BuildContext context, GlobalKey<FormState> formKey) async {
    if (!formKey.currentState!.validate()) return;

    isLoading = true;
    notifyListeners();

    try {
      String imageUrl = '';
      if (pickedImage != null) {
        imageUrl = await _storageService.uploadIngredientImage(pickedImage!);
      }

      // 👇 Explicit casting to Map<String, String>
      final List<Map<String, String>> formattedIngredients = ingredients.map((i) => {
        'name': (i['name'] as TextEditingController).text.trim(),
        'quantity': (i['quantity'] as TextEditingController).text.trim(),
        'unit': i['unit'].toString(),
      }).toList();

      final List<String> formattedCookingSteps = cookingSteps.map((c) => c.text.trim()).toList();

      await _firestoreService.addRecipe(
        dishName: nameController.text.trim(),
        description: descriptionController.text.trim(),
        style: styleController.text.trim(),
        ingredients: formattedIngredients,
        cookingSteps: formattedCookingSteps,
        imageUrl: imageUrl,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to submit recipe: $e")),
      );
      print("Error: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

}
