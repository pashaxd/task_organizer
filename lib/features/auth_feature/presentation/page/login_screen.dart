import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/auth_field.dart';

/// Экран входа пользователей.
///
/// Этот класс представляет экран, на котором пользователи могут
/// войти в свою учетную запись, введя свой адрес электронной почты и пароль.
class LoginScreen extends StatelessWidget {
  final Function toggle; // Функция для переключения на экран регистрации

  const LoginScreen({super.key, required this.toggle});

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();    // Контроллер для email
    final passwordController = TextEditingController(); // Контроллер для пароля

    return Column(
      spacing: 40,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Welcome',
          style: TextStyle(fontSize: 50), // Заголовок приветствия
        ),
        Container(
          height: MediaQuery.of(context).size.height * 0.4, // Высота контейнера
          width: MediaQuery.of(context).size.width * 0.8, // Ширина контейнера
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30), // Закругленные углы
            color: Colors.teal, // Цвет фона
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 30, left: 20, right: 20),
            child: Column(
              children: [
                Text(
                  'Login',
                  style: TextStyle(fontSize: 30), // Заголовок для входа
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.03, // Отступ между элементами
                ),
                AuthField(
                  hintText: 'Email', // Подсказка для поля email
                  controller: emailController,
                  isPassword: false,
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.05,
                ),
                AuthField(
                  hintText: 'Password', // Подсказка для поля пароля
                  controller: passwordController,
                  isPassword: true,
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.05,
                ),
                TextButton(
                  onPressed: () {
                    toggle(); // Переключаем на экран регистрации
                  },
                  child: Text(
                    'Dont have an account?',
                    style: TextStyle(fontSize: 15, color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(
          height: MediaQuery.of(context).size.height * 0.05,
          width: MediaQuery.of(context).size.width * 0.8,
          child: ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.greenAccent), // Цвет кнопки
            ),
            onPressed: () {
              // Отправка события входа в BLoC
              context.read<AuthBloc>().add(
                AuthLogin(
                  email: emailController.text, // Получаем email
                  password: passwordController.text, // Получаем пароль
                ),
              );
            },
            child: Text('Let\'s go'),
          ),
        ),
      ],
    );
  }
}