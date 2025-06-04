class UserModel {
  final String email;
  String name;
  String? imageUrl;

  UserModel({
    required this.email,
    required this.name,
    this.imageUrl,
  });
}
