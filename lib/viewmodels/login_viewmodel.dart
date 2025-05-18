import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../services/auth_service.dart';

class LoginViewModel extends ChangeNotifier {
  String email = '';
  String password = '';
  bool isLoading = false;

  void setEmail(String val) {
    email = val;
    notifyListeners();
  }

  void setPassword(String val) {
    password = val;
    notifyListeners();
  }

  Future<void> login() async {
    isLoading = true;
    notifyListeners();

    try {
      await AuthService().signInWithEmail(email, password);
    } on FirebaseAuthException catch (e) {
      isLoading = false;
      notifyListeners();
      throw e.message ?? 'An unknown error occurred';
    } catch (e) {
      isLoading = false;
      notifyListeners();
      throw 'Something went wrong. Please try again.';
    }

    isLoading = false;
    notifyListeners();
  }

  Future<bool> signinWithGoogle() async {
    isLoading = true;
    notifyListeners();

    final userCredential = await AuthService().signInWithGoogle();

    isLoading = false;
    notifyListeners();

    return userCredential != null;
  }

  Future<void> signOut() async {
    isLoading = true;
      notifyListeners();

    try {
      await AuthService().signOut();
    } catch (e) {
      // Optional: handle error or show message
    }

    isLoading = false;
    notifyListeners();
  }
}
