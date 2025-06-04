import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:smart_virtual_refrigerator/models/leftover.dart';
import 'package:smart_virtual_refrigerator/services/auth_service.dart';

class LeftoverViewModel extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;


  Future<String> uploadImage(File imageFile) async {
    final fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final ref = _storage.ref().child('leftover_images/$fileName.jpg');
    await ref.putFile(imageFile);
    return await ref.getDownloadURL();
  }

  Future<void> addLeftover(Leftover leftover) async {
    final userId = AuthService().userId;

    if (userId == null) {
      throw 'User is not logged in';
    }

    final dataWithUserId = leftover.toJson()
      ..['userId'] = userId;

    await _db.collection('leftovers').add(dataWithUserId);
  }

  Future<void> updateLeftover(String docId, Leftover leftover) async {
    await _db.collection('leftovers').doc(docId).update(leftover.toJson());
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
