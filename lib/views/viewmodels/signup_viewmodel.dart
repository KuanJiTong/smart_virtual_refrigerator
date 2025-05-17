import 'package:flutter/foundation.dart';

class SignupViewModel extends ChangeNotifier {
  String name = '';
  String email = '';
  String password = '';
  bool isChecked = false;
  bool isLoading = false;

  void setName(String val) {
    name = val;
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

    await Future.delayed(Duration(seconds: 2)); // simulate signup delay

    // Here you can add your actual signup logic, e.g. call to backend

    isLoading = false;
    notifyListeners();
  }

  Future<void> signupWithGoogle() async {
    isLoading = true;
    notifyListeners();

    await Future.delayed(Duration(seconds: 2)); // simulate google signup

    // Add your Google signup logic here

    isLoading = false;
    notifyListeners();
  }
}
