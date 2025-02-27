abstract class AuthEvent {}

class AuthRegister extends AuthEvent {
  final String email;
  final String password;

  AuthRegister(this.email, this.password);
}

class AuthLogin extends AuthEvent {
  final String email;
  final String password;

  AuthLogin(this.email, this.password);
}
class ToggleMode extends AuthEvent{}

