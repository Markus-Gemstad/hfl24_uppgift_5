part of 'auth_bloc.dart';

abstract class AuthEvent {}

class AuthLoginRequested extends AuthEvent {
  final String email;
  AuthLoginRequested(this.email);
}

class AuthLogoutRequested extends AuthEvent {}
