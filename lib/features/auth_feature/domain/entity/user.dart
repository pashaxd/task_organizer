/// Модель пользователя.

class UserModel {
  final String uid;    // Уникальный идентификатор пользователя
  final String email;  // Адрес электронной почты пользователя

  UserModel({
    required this.email,
    required this.uid,
  });
}