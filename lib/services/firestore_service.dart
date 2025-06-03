import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

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

  Future<void> addIngredient({
    required String userId,
    required String name,
    required String category,
    required String quantity,
    required bool hasExpiry,
    DateTime? expirationDate,
    required String imageUrl,
  }) async {
    final String quantityWithUnit = _formatQuantity(quantity, _getUnit(category));
    final String formattedDate = hasExpiry && expirationDate != null
        ? DateFormat('yyyy-MM-dd').format(expirationDate)
        : '';
    final int daysLeft = hasExpiry && expirationDate != null
        ? expirationDate.difference(DateTime.now()).inDays
        : 0;

    final Map<String, dynamic> ingredientData = {
      'userId': userId,
      'category': category,
      'image': imageUrl,
      'quantity': quantityWithUnit,
      'name': name,
      'expiredDate': formattedDate,
      'daysLeftToExpire': daysLeft,
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
    required bool hasExpiry,
    DateTime? expirationDate,
    required String imageUrl,
  }) async {
    final String quantityWithUnit = _formatQuantity(quantity, _getUnit(category));
    final String formattedDate = hasExpiry && expirationDate != null
        ? DateFormat('yyyy-MM-dd').format(expirationDate)
        : '';
    final int daysLeft = hasExpiry && expirationDate != null
        ? expirationDate.difference(DateTime.now()).inDays
        : 0;

    final docRef = FirebaseFirestore.instance.collection('ingredients').doc(docId);

    final Map<String, dynamic> updatedData = {
      'category': category,
      'image': imageUrl,
      'quantity': quantityWithUnit,
      'name': name,
      'expiredDate': formattedDate,
      'daysLeftToExpire': daysLeft,
    };
    await docRef.update(updatedData);
  }

  String _getUnit(String category) {
    final Map<String, String> unitMapping = {
      'Bread': 'Slice',
      'Meat': 'Gram',
      'Vegetable': 'Gram',
      'Fruit': 'Piece',
      'Dairy': 'Milliliter',
      'Beverage': 'Milliliter',
      'Spice': 'Tablespoon',
      'Grain': 'Gram',
      'Condiment': 'Tablespoon',
    };
    return unitMapping[category] ?? 'Unit';
  }

  String _formatQuantity(String qty, String unit) {
    final unitSuffix = switch (unit.toLowerCase()) {
      'gram' => 'g',
      'milliliter' => 'ml',
      'piece' => 'pcs',
      'slice' => 'pcs',
      'tablespoon' => 'tbsp',
      _ => unit
    };
    return "$qty$unitSuffix";
  }
}
