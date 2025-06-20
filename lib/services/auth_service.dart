import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Sign up with email & password
  Future<UserCredential?> signUpWithEmail(String email, String password) async {
    try {
      UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw e.message ?? 'Signup failed';
    } catch (e) {
      throw 'An unknown error occurred';
    }
  }

  // Sign in with email & password
  Future<UserCredential?> signInWithEmail(String email, String password) async {
    try {
      UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw e.message ?? 'Login failed';
    } catch (e) {
      throw 'An unknown error occurred';
    }
  }

  signInWithGoogle() async {

    final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();

    if(gUser == null) return;

    final GoogleSignInAuthentication gAuth = await gUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: gAuth.accessToken,
      idToken: gAuth.idToken,
    );

    return await _firebaseAuth.signInWithCredential(credential);
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  Future<void> signOut() async {
    await GoogleSignIn().signOut();
    await _firebaseAuth.signOut();
  }

  String? get userId {
    return _firebaseAuth.currentUser?.uid;
  }

  // Future<bool> isCurrentUserAdmin() async {
  //   User? user = _firebaseAuth.currentUser;

  //   if (user != null) {
  //     IdTokenResult tokenResult = await user.getIdTokenResult(true); // Force refresh
  //     final claims = tokenResult.claims;
  //     print("admin");
  //     return claims?['admin'] == true;
  //   }
  //   print("test");
  //   return false;
  // }


  Future<bool> isCurrentUserAdmin() async {
    User? user = _firebaseAuth.currentUser;
    if (user != null) {
      final tokenResult = await user.getIdTokenResult(true);
      final claims = tokenResult.claims;
      final isAdmin = claims?['admin'] == true;

      // ✅ Write to Firestore for backend visibility
      await FirebaseFirestore.instance.collection('admin_check_logs').add({
        'uid': user.uid,
        'email': user.email,
        'isAdmin': isAdmin,
        'timestamp': FieldValue.serverTimestamp(),
      });

      return isAdmin;
    }

    // Log failed check as well
    await FirebaseFirestore.instance.collection('admin_check_logs').add({
      'uid': null,
      'email': null,
      'isAdmin': false,
      'timestamp': FieldValue.serverTimestamp(),
      'error': 'User is null',
    });

    return false;
  }

}