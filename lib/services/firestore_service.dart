import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

    await _firestore.collection('fridge').add(ingredientData);
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
