class Leftover {
  final String name;
  final String quantity;
  final String category;
  final String location;
  final DateTime dateStored;
  final DateTime? expiryDate;
  final String? notes;
  final String? imageUrl;

  Leftover({
    required this.name,
    required this.quantity,
    required this.category,
    required this.location,
    required this.dateStored,
    this.expiryDate,
    this.notes,
    this.imageUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity,
      'category': category,
      'location': location,
      'dateStored': dateStored.toIso8601String(),
      'expiryDate': expiryDate?.toIso8601String(),
      'notes': notes,
      'imageUrl': imageUrl,
    };
  }

  factory Leftover.fromJson(Map<String, dynamic> json) {
    return Leftover(
      name: json['name'],
      quantity: json['quantity'],
      category: json['category'],
      location: json['location'],
      dateStored: DateTime.parse(json['dateStored']),
      expiryDate: json['expiryDate'] != null ? DateTime.parse(json['expiryDate']) : null,
      notes: json['notes'],
      imageUrl: json['imageUrl'],
    );
  }
}
