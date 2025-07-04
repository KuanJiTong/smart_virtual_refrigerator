import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../models/recipe.dart';
import 'dart:async'; 

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> fetchIngredients(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('ingredients')
          .where('userId', isEqualTo: userId)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Error fetching ingredients: $e');
      return [];
    }
  }
  Future<void> addRecipe({
    required String dishName,
    required String description,
    required String style,
    required String category,
    required int numberFavourites,
    required List<Map<String, String>> ingredients,
    required List<String> cookingSteps,
    required String imageUrl,
    required String userId,
    required String status
  }) async {
    final Map<String, dynamic> recipeData = {
      'dish_name': dishName,
      'description': description,
      'style': style,
      'ingredients': ingredients,
      'cooking_steps': cookingSteps,
      'category': category,
      'number_favourites': numberFavourites,
      'image_url': imageUrl,
      'userId': userId,
      'status': status
    };

    await _firestore.collection('recipes').add(recipeData);
  }


  Future<void> addIngredient({
    required String userId,
    required String name,
    required String category,
    required String quantity,
    required String quantityUnit,
    required String storageLocation,
    required bool hasExpiry,
    DateTime? expirationDate,
    required String imageUrl,
  }) async {
    final String formattedDate = hasExpiry && expirationDate != null
        ? DateFormat('yyyy-MM-dd').format(expirationDate)
        : '';

    final Map<String, dynamic> ingredientData = {
      'userId': userId,
      'category': category,
      'image': imageUrl,
      'quantity': quantity,
      'quantityUnit': quantityUnit,
      'storageLocation': storageLocation,
      'name': name,
      'expiredDate': formattedDate,
    };

    await _firestore.collection('ingredients').add(ingredientData);
  }

  Future<void> deleteIngredient(String docId) async {
    try {
      await _firestore.collection('ingredients').doc(docId).delete();
    } catch (e) {
      print('Error deleting ingredient: $e');
      rethrow;
    }
  }

  Future<void> updateIngredient({
    required String docId,
    required String name,
    required String category,
    required String quantity,
    required String quantityUnit,
    required String storageLocation,
    required bool hasExpiry,
    DateTime? expirationDate,
    required String imageUrl,
  }) async {
    final String formattedDate = hasExpiry && expirationDate != null
        ? DateFormat('yyyy-MM-dd').format(expirationDate)
        : '';

    final docRef = FirebaseFirestore.instance.collection('ingredients').doc(docId);

    final Map<String, dynamic> updatedData = {
      'category': category,
      'image': imageUrl,
      'quantity': quantity,
      'quantityUnit': quantityUnit,
      'storageLocation': storageLocation,
      'name': name,
      'expiredDate': formattedDate,
    };
    await docRef.update(updatedData);
  }
  Future<List<Map<String, dynamic>>> fetchLeftovers(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('leftovers')
          .where('userId', isEqualTo: userId)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;

        // Add daysLeftToExpire for sorting/filtering
        if (data['expiryDate'] != null) {
          final expiry = DateTime.parse(data['expiryDate']);
          data['daysLeftToExpire'] = expiry.difference(DateTime.now()).inDays;
        } else {
          data['daysLeftToExpire'] = 999; // default large value
        }

        return data;
      }).toList();
    } catch (e) {
      print('Error fetching leftovers: $e');
      return [];
    }
  }

  Future<Set<String>> getFavouriteRecipeIds(String userId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('favourites')
        .get();

    return snapshot.docs.map((doc) => doc.id).toSet();
  }

  Future<void> addToFavourites(String userId, String recipeId) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('favourites')
        .doc(recipeId)
        .set({});
  }

  Future<void> removeFromFavourites(String userId, String recipeId) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('favourites')
        .doc(recipeId)
        .delete();
  }

  Future<void> updateRecipeFavouriteCount(String recipeId, int count) async {
    await FirebaseFirestore.instance
        .collection('recipes')
        .doc(recipeId)
        .update({'number_favourites': count});
  }

  Future<List<Recipe>> fetchAllRecipes() async {
    final snapshot = await FirebaseFirestore.instance.collection('recipes').get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id; // Manually add the document ID into the map
      return Recipe.fromJson(data);
    }).toList();
  }

    Future<void> addGrocery({
    required String userId,
    required Map<String, dynamic> groceryData,
  }) async {
    groceryData['userId'] = userId;
    await _firestore.collection('groceries').add(groceryData);
  }

  Future<void> deleteGrocery(String docId) async {
    try {
      await _firestore.collection('groceries').doc(docId).delete();
    } catch (e) {
      print('Error deleting grocery: $e');
      rethrow;
    }
  }

  Future<void> updateGrocery({
    required String docId,
    required Map<String, dynamic> groceryData,
  }) async {
    await _firestore.collection('groceries').doc(docId).update(groceryData);
  }

  Future<List<Map<String, dynamic>>> fetchGroceries(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('groceries')
          .where('userId', isEqualTo: userId)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Error fetching groceries: $e');
      return [];
    }
  }

  Future<void> deleteRecipe(String recipeId) async {
    await _firestore.collection('recipes').doc(recipeId).delete();
  }

  Future<void> updateRecipe({
    required String recipeId,
    required String dishName,
    required String description,
    required String style,
    required List<Map<String, String>> ingredients,
    required List<String> cookingSteps,
    required String imageUrl,
    required String category,
  }) async {
    await _firestore.collection('recipes').doc(recipeId).update({
      'dish_name': dishName,
      'description': description,
      'style': style,
      'ingredients': ingredients,
      'cooking_steps': cookingSteps,
      'image_url': imageUrl,
      'category': category,
    });
  }

Future<Recipe?> getRecipeById(String recipeId) async {
  if (recipeId.isEmpty) {
    print("❌ recipeId is empty!");
    return null;
  }

  try {
    final doc = await FirebaseFirestore.instance
        .collection('recipes')
        .doc(recipeId)
        .get()
        .timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            throw TimeoutException("Firestore request timed out.");
          },
        );

    if (doc.exists) {
      print("✅ Recipe found: ${doc.id}");
      return Recipe.fromFirestore(doc.data()!, doc.id);
    } else {
      print("❌ Recipe not found with ID: $recipeId");
    }
  } catch (e) {
    print("🔥 Error fetching recipe: $e");
  }

  return null;
}

}



