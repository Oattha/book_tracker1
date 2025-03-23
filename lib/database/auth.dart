import 'package:firebase_auth/firebase_auth.dart';

class UserAuthentication {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _succuss = false;

  Future<bool> signInWithEmailAndPassword(
    String email, String password) async {
    try {
      final User? user = (await _auth.signInWithEmailAndPassword(
        email: email, password: password))
        .user;
      if (user != null) {
        _succuss = true;
      }
    } on FirebaseAuthException catch (e) {
      _succuss = false;
    }
    return _succuss;
  }
}