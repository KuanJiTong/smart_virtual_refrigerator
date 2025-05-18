import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class ForgotPasswordViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  Future<void> sendResetEmail(String email) async {
    if (email.isEmpty) throw Exception('Email cannot be empty');
    await _authService.sendPasswordResetEmail(email);
  }
}
