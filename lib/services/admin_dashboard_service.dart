import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_virtual_refrigerator/models/recipe.dart';

class AdminDashboardService {
  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');

      final CollectionReference recipesCollection =
      FirebaseFirestore.instance.collection('recipes');

  Future<int> getTotalUserCount() async {
    final users = await usersCollection.get();
    return users.docs.length;
  }

  Future<int> getTotalRecipeCount() async {
    final recipes = await recipesCollection.get();
    return recipes.docs.length;
  }

  Future<int> getRecipesCountByStatus(String status) async {
    final recipes = await recipesCollection
        .where('status', isEqualTo: status)
        .get();
    return recipes.docs.length;
  }

  Future<int> getTotalPendingRecipes() async {
    return getRecipesCountByStatus("pending");
  }

  Future<List<Recipe>> getRecipesByStatus(String status) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('recipes')
          .where('status', isEqualTo: status)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;     
        return Recipe.fromJson(data);
      }).toList();
    } catch (e) {
      print('Error getting recipes by status: $e');
      return [];
    }
  }

  Future<List<Recipe>> getPendingRecipes() async {
    return getRecipesByStatus("pending");
  }

  Future<List<Recipe>> getApprovedRecipes() async {
    return getRecipesByStatus("approved");
  }

  Future<List<Recipe>> getRejectedRecipes() async {
    return getRecipesByStatus("rejected");
  }

  static Future<void> approveRecipe(String recipeId) async {
    await FirebaseFirestore.instance.collection('recipes').doc(recipeId).update({
      'status': 'approved',
      'rejectReason': FieldValue.delete(), // Clear reason if exists
    });
  }

  static Future<void> rejectRecipe(String recipeId, String reason) async {
    await FirebaseFirestore.instance.collection('recipes').doc(recipeId).update({
      'status': 'rejected',
      'rejectReason': reason,
    });
  }
}
