// user_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';

class UserViewModel extends ChangeNotifier {
  final Map<String, UserModel> _userMap = {};

  Map<String, UserModel> get userMap => _userMap;

  Future<void> fetchAllUsers() async {
    final snapshot = await FirebaseFirestore.instance.collection('users').get();
    for (var doc in snapshot.docs) {
      final data = doc.data();
      _userMap[doc.id] = UserModel(
        email: data['email'] ?? '',
        name: data['name'] ?? 'Unknown',
        imageUrl: data['imageUrl'],
      );
    }
    notifyListeners();
  }

  String getUserName(String userId) {
    return _userMap[userId]?.name ?? 'Unknown';
  }
}
