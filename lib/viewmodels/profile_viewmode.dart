import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smart_virtual_refrigerator/models/user.dart';

class ProfileViewModel extends ChangeNotifier {
  final nameController = TextEditingController();
  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserModel? _userModel;

  UserModel? get user => _userModel;

  Future<void> loadUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      final name = doc['name'] ?? '';
      final imageUrl = doc['imageUrl'];
      _userModel = UserModel(email: user.email!, name: name, imageUrl: imageUrl);
      nameController.text = name;
      notifyListeners();
    }
  }

  Future<void> updateName() async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update({
        'name': nameController.text.trim(),
      });
      _userModel!.name = nameController.text.trim();
      notifyListeners();
    }
  }


  Future<String?> changePassword() async {
    final user = _auth.currentUser;
    if (user == null) return 'User not logged in';

    if (newPasswordController.text != confirmPasswordController.text) {
      return 'Passwords do not match';
    }
    if (newPasswordController.text.length < 8) {
      return 'Password must be at least 8 characters';
    }

    try {
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: oldPasswordController.text,
      );

      // Reauthenticate user with old password
      await user.reauthenticateWithCredential(credential);

      // Update password to new one
      await user.updatePassword(newPasswordController.text);

      // Clear controllers
      oldPasswordController.clear();
      newPasswordController.clear();
      confirmPasswordController.clear();

      return null; // success
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-credential') {
        return 'Old password is incorrect';
      } else if (e.code == 'user-mismatch') {
        return 'Reauthentication failed: User mismatch';
      } else if (e.code == 'user-not-found') {
        return 'User not found';
      } else {
        return 'Password change failed: ${e.code}';
      }
    } catch (e) {
      return 'An unexpected error occurred: ${e.toString()}';
    }
  }


  Future<void> pickAndUploadProfileImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 75);

    if (picked != null) {
      final user = _auth.currentUser;
      if (user == null) return;

      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_images/${user.uid}.jpg');

      await storageRef.putFile(File(picked.path));
      final url = await storageRef.getDownloadURL();

      await _firestore.collection('users').doc(user.uid).update({
        'imageUrl': url,
      });

      _userModel!.imageUrl = url;
      notifyListeners();
    }
  }


  @override
  void dispose() {
    nameController.dispose();
    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
