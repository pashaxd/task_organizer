import 'package:flutter/material.dart';

/// Виджет для поля ввода аутентификации.
class AuthField extends StatelessWidget {
  final String hintText;                // Подсказка для текстового поля
  final TextEditingController controller; // Контроллер для управления текстом
  final bool isPassword;                // Флаг, указывающий, является ли поле паролем

  const AuthField({
    super.key,
    required this.hintText,
    required this.controller,
    required this.isPassword,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20), // Паддинг по горизонтали
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15), // Закругленные углы
        color: Colors.greenAccent,                 // Цвет фона
      ),
      child: TextField(
        obscureText: isPassword, // Скрытие текста, если это поле пароля
        decoration: InputDecoration(
          border: InputBorder.none, // Убираем границу
          hintText: hintText,       // Текст подсказки
          hintStyle: const TextStyle(
            fontWeight: FontWeight.w300,
          ),
        ),
        controller: controller,
      ),
    );
  }
}
