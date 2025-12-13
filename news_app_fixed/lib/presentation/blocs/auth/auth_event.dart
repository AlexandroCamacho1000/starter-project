part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
}

class GoogleSignInRequested extends AuthEvent {}

class LogoutRequested extends AuthEvent {}

// Eventos internos para manejar cambios de Firebase
class Authenticated extends AuthEvent {
  final String userId;
  
  const Authenticated(this.userId);
  
  @override
  List<Object> get props => [userId];
}

class UnAuthenticated extends AuthEvent {}