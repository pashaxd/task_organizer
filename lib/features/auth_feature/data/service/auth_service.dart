import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entity/user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<UserModel?> registerWithEmail(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;

      return UserModel(uid: user!.uid, email: user.email!);
    } catch (error) {
      print(error);
      return null;
    }
  }

  Future<UserModel?> signInWithEmail(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;

      return UserModel(uid: user!.uid, email: user.email!);
    } catch (error) {
      print(error);
      return null;
    }
  }
}
