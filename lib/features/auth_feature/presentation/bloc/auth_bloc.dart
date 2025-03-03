import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/service/auth_service.dart';
import '../../domain/entity/user.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// BLoC для управления аутентификацией пользователей.
///
/// Этот класс обрабатывает события аутентификации и управляет состоянием
/// приложения в зависимости от действий пользователей (вход, регистрация и переключение режимов).
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService authService; // Сервис для выполнения операций аутентификации

  AuthBloc({required this.authService}) : super(AuthLoginScreen()) {
    // Обработка события переключения между экранами входа и регистрации
    on<ToggleMode>((event, emit) {
      if (state is AuthRegisterScreen) {
        emit(AuthLoginScreen()); // Переход на экран входа
      } else if (state is AuthLoginScreen) {
        emit(AuthRegisterScreen()); // Переход на экран регистрации
      } else {
        emit(AuthLoginScreen()); // По умолчанию показываем экран входа
      }
    });

    // Обработка события регистрации
    on<AuthRegister>((event, emit) async {
      emit(AuthLoading()); // Устанавливаем состояние загрузки
      UserModel? user = await authService.registerWithEmail(event.email, event.password);
      if (user != null) {
        emit(AuthSuccess()); // Успешная регистрация
      } else {
        emit(AuthFailure("Registration failed")); // Ошибка регистрации
      }
    });

    // Обработка события входа
    on<AuthLogin>((event, emit) async {
      emit(AuthLoading()); // Устанавливаем состояние загрузки
      UserModel? user = await authService.signInWithEmail(event.email, event.password);
      if (user != null) {
        emit(AuthSuccess()); // Успешный вход
      } else {
        emit(AuthFailure("Login failed")); // Ошибка входа
      }
    });
  }
}