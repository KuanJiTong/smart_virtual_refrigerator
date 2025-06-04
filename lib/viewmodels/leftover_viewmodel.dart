import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:smart_virtual_refrigerator/models/leftover.dart';
import 'package:smart_virtual_refrigerator/services/auth_service.dart';
import 'package:smart_virtual_refrigerator/services/leftover_service.dart';

class LeftoverViewModel extends ChangeNotifier {
  final LeftoverService _leftoverService = LeftoverService();
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  List<Leftover> _leftovers = [];
  List<Leftover> get leftovers => _leftovers;

  Future<String> uploadImage(File imageFile) async {
    final fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final ref = _storage.ref().child('leftover_images/$fileName.jpg');
    await ref.putFile(imageFile);
    return await ref.getDownloadURL();
  }

  bool isLoading = false;

  Future<void> fetchLeftovers() async {
    isLoading = true;
    notifyListeners();

    try {
      _leftovers = await _leftoverService.getAllLeftovers();
    } catch (e) {
      print("Error fetching leftovers: $e");
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> addLeftover(Leftover leftover) async {
    final userId = AuthService().userId;

    if (userId == null) {
      throw 'User is not logged in';
    }

    final dataWithUserId = leftover.toJson()
      ..['userId'] = userId;

    await _db.collection('leftovers').add(dataWithUserId);
    notifyListeners();
  }

  Future<void> updateLeftover(String docId, Leftover leftover) async {
    await _db.collection('leftovers').doc(docId).update(leftover.toJson());
    notifyListeners();
  }

  // Delete leftover by ID
  Future<void> deleteLeftover(String id) async {
    try {
      await _db.collection('leftovers').doc(id).delete();
      notifyListeners();
    } catch (e) {
      throw Exception("Failed to delete leftover: $e");
    }
  }

}
