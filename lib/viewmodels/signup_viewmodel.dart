import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../services/auth_service.dart';

class SignupViewModel extends ChangeNotifier {
  String email = '';
  String password = '';
  String username = '';
  bool isChecked = false;
  bool isLoading = false;

  void setUsername(String val) {
    username = val;
    notifyListeners();
  }

  void setEmail(String val) {
    email = val;
    notifyListeners();
  }

  void setPassword(String val) {
    password = val;
    notifyListeners();
  }

  void setAgreedToTerms(bool? val) {
    if (val != null) {
      isChecked = val;
      notifyListeners();
    }
  }

  Future<void> signup() async {
    isLoading = true;
    notifyListeners();

    try {
      final userCredential = await AuthService().signUpWithEmail(email, password);
      final user = userCredential?.user;

      await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({
        'name': username,
        'email': user.email,
        'imageUrl': null,
      });
    } on FirebaseAuthException catch (e) {
      isLoading = false;
      notifyListeners();
      throw e.message ?? 'An unknown error occurred';
    } catch (e) {
      isLoading = false;
      notifyListeners();
      throw 'Something went wrong. Please try again.';
    }
  }


  Future<bool> signinWithGoogle() async {
    isLoading = true;

    notifyListeners();

    final userCredential = await AuthService().signInWithGoogle();
    final user = userCredential?.user; 
    
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

      if (!userDoc.exists) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'name': user.displayName ?? '',
          'email': user.email,
          'imageUrl': user.photoURL,
        });
      }
    }

    isLoading = false;
    notifyListeners();

    return userCredential != null;
  }
}
