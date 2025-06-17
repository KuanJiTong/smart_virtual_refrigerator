import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/leftover.dart';
import 'auth_service.dart';

class LeftoverService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  Future<List<Leftover>> getAllLeftovers() async {
    final userId = _authService.userId;
    if (userId == null) {
      throw 'User is not logged in';
    }

    try {
      final snapshot = await _db
          .collection('leftovers')
          .where('userId', isEqualTo: userId)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Leftover.fromJson(data);
      }).toList();
    } catch (e) {
      print('Error fetching leftovers: $e');
      return [];
    }
  }
}
