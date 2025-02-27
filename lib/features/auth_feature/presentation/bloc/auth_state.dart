
import '../../domain/entity/user.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {

}
class AuthLoginScreen extends AuthState {}
class AuthRegisterScreen extends AuthState {}
class AuthFailure extends AuthState {
  final String message;

  AuthFailure(this.message);
}