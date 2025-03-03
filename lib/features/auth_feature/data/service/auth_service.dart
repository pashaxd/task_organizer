import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entity/user.dart';

/// Сервис аутентификации.

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance; // Экземпляр FirebaseAuth для работы с аутентификацией

  /// Регистрация пользователя с помощью электронной почты и пароля.
  ///
  /// Возвращает [UserModel] при успешной регистрации, иначе - null.
  Future<UserModel?> registerWithEmail(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user; // Получаем пользователя из результата

      return UserModel(uid: user!.uid, email: user.email!); // Возвращаем модель пользователя
    } catch (error) {
      print(error); // Выводим ошибку в консоль
      return null; // Возвращаем null в случае ошибки
    }
  }

  /// Вход пользователя с помощью электронной почты и пароля.
  ///
  /// Возвращает [UserModel] при успешном входе, иначе - null.
  Future<UserModel?> signInWithEmail(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user; // Получаем пользователя из результата

      return UserModel(uid: user!.uid, email: user.email!); // Возвращаем модель пользователя
    } catch (error) {
      print(error); // Выводим ошибку в консоль
      return null; // Возвращаем null в случае ошибки
    }
  }
}