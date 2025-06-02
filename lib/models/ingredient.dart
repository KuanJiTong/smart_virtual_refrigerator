class Ingredient {
  final String name;
  final String category;
  final String quantity;
  final String image;
  final DateTime expiredDate;
  final int daysLeftToExpire;

  Ingredient({
    required this.name,
    required this.category,
    required this.quantity,
    required this.image,
    required this.expiredDate,
    required this.daysLeftToExpire,
  });

  factory Ingredient.fromMap(Map<String, dynamic> data) {
    return Ingredient(
      name: data['name'] ?? '',
      category: data['category'] ?? '',
      quantity: data['quantity'] ?? '',
      image: data['image'] ?? '',
      expiredDate: DateTime.parse(data['expiredDate']),
      daysLeftToExpire: data['daysLeftToExpire'] ?? 0,
    );
  }
}
