abstract class AuthEvent {}

class AuthRegister extends AuthEvent {
  final String email;
  final String password;

  AuthRegister({required this.email, required this.password});
}

class AuthLogin extends AuthEvent {
  final String email;
  final String password;

  AuthLogin({required this.email, required this.password});
}
class ToggleMode extends AuthEvent{}

