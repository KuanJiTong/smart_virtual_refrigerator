// In expiring_notification.dart
class ExpiringNotification {
  final String title;
  final String message;
  final String image;
  final DateTime expiryDate;

  ExpiringNotification({
    required this.title,
    required this.message,
    required this.image,
    required this.expiryDate,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'message': message,
    'image': image,
    'expiryDate': expiryDate.toIso8601String(),
  };

  factory ExpiringNotification.fromJson(Map<String, dynamic> json) {
    return ExpiringNotification(
      title: json['title'],
      message: json['message'],
      image: json['image'],
      expiryDate: DateTime.parse(json['expiryDate']),
    );
  }
}
