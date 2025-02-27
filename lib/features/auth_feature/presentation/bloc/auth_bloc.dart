import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/service/auth_service.dart';
import '../../domain/entity/user.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService = AuthService();

  AuthBloc() : super(AuthLoginScreen()) {
    on<ToggleMode>((event, emit) {
      if (state is AuthRegisterScreen) {
        emit(AuthLoginScreen());
      } else if (state is AuthLoginScreen) {
        emit(AuthRegisterScreen());
      }
      else{
        emit(AuthLoginScreen());
      }
    });

    on<AuthRegister>((event, emit) async {
      emit(AuthLoading());
      UserModel? user =
          await _authService.registerWithEmail(event.email, event.password);
      if (user != null) {
        emit(AuthSuccess());
      } else {
        emit(AuthFailure("Registration failed"));
      }
    });

    on<AuthLogin>((event, emit) async {
      emit(AuthLoading());
      UserModel? user =
          await _authService.signInWithEmail(event.email, event.password);
      if (user != null) {
        emit(AuthSuccess());
      } else {
        emit(AuthFailure("Login failed"));
      }
    });
  }
}
