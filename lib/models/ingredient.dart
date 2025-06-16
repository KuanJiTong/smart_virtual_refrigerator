class Ingredient {
  final String name;
  final String category;
  final String quantity;
  final String quantityUnit;
  final String storageLocation;
  final String userId;
  final String image;
  final DateTime expiredDate;

  Ingredient({
    required this.name,
    required this.category,
    required this.quantity,
    required this.quantityUnit,
    required this.storageLocation,
    required this.userId,
    required this.image,
    required this.expiredDate,
  });

  factory Ingredient.fromMap(Map<String, dynamic> data) {
    return Ingredient(
      name: data['name'] ?? '',
      category: data['category'] ?? '',
      quantity: data['quantity'] ?? '',
      quantityUnit: data['quantityUnit'] ?? '',
      storageLocation: data['storageLocation'] ?? '',
      userId: data['userId'] ?? '',
      image: data['image'] ?? '',
      expiredDate: DateTime.parse(data['expiredDate']),
    );
  }
}
