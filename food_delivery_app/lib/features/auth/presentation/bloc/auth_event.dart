import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class LoginSubmitted extends AuthEvent {
  final String email;
  final String password;
  const LoginSubmitted({required this.email, required this.password});
  @override
  List<Object?> get props => [email, password];
}

class RegisterSubmitted extends AuthEvent {
  final String name;
  final String email;
  final String password;
  final String role;
  const RegisterSubmitted({
    required this.name,
    required this.email,
    required this.password,
    required this.role,
  });
  @override
  List<Object?> get props => [name, email, password, role];
}

class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}

class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

/// Dev-only — used by RoleSwitcher to force a session without going through login.
class ForceAuthState extends AuthEvent {
  final dynamic state;
  const ForceAuthState(this.state);
  @override
  List<Object?> get props => [state];
}
