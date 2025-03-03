import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_organizer/features/auth_feature/presentation/page/login_screen.dart';
import 'package:task_organizer/features/auth_feature/presentation/page/register_screen.dart';
import 'package:task_organizer/features/task_feature/presentation/page/task_screen.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

/// Экран аутентификации.
///
/// Этот класс представляет экран, который управляет процессами входа и регистрации,
/// используя BLoC для управления состоянием аутентификации.
class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            // Обработка состояний аутентификации
            if (state is AuthSuccess) {
              // При успешной аутентификации переходим на экран задач
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => TaskScreen()),
              );
            } else if (state is AuthFailure) {
              // При ошибке аутентификации показываем сообщение
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          child: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              // Построение UI в зависимости от состояния
              if (state is AuthLoginScreen) {
                // Если состояние - экран входа, отображаем LoginScreen
                return LoginScreen(
                  toggle: () => context.read<AuthBloc>().add(ToggleMode()), // Переключение на экран регистрации
                );
              } else if (state is AuthRegisterScreen) {
                // Если состояние - экран регистрации, отображаем RegisterScreen
                return RegisterScreen(
                  toggle: () => context.read<AuthBloc>().add(ToggleMode()), // Переключение на экран входа
                );
              } else if (state is AuthFailure) {
                // Если произошла ошибка, также отображаем экран входа
                return LoginScreen(
                  toggle: () => context.read<AuthBloc>().add(ToggleMode()),
                );
              } else {
                // Пока состояние загружается, показываем индикатор загрузки
                return CircularProgressIndicator();
              }
            },
          ),
        ),
      ),
    );
  }
}