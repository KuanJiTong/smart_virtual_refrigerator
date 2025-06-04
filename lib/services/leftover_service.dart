import 'dart:io';
import '../models/leftover.dart';

class LeftoverService {
  final List<Leftover> _mockStorage = []; 

  Future<List<Leftover>> getAllLeftovers() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockStorage;
  }
}
