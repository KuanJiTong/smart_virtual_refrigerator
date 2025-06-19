class Grocery {
  final String? id;
  final String name;
  final String quantity;
  final String unit;
  final String source; // 'ingredient', 'leftover', or 'recipe'
  final String? imageUrl;
  final DateTime? expiryDate;
  bool bought;

  Grocery({
    this.id,
    required this.name,
    required this.quantity,
    required this.unit,
    required this.source,
    this.imageUrl,
    this.expiryDate,
    this.bought = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'source': source,
      'imageUrl': imageUrl,
      'expiryDate': expiryDate?.toIso8601String(),
      'bought': bought,
    };
  }

  factory Grocery.fromJson(Map<String, dynamic> json) {
    return Grocery(
      id: json['id'],
      name: json['name'],
      quantity: json['quantity'],
      unit: json['unit'],
      source: json['source'],
      imageUrl: json['imageUrl'],
      expiryDate: json['expiryDate'] != null ? DateTime.parse(json['expiryDate']) : null,
      bought: json['bought'] ?? false,
    );
  }
} 