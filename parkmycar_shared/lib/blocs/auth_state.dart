part of 'auth_bloc.dart';

enum AuthStateStatus { initial, authenticating, authenticated, unauthenticated }

class AuthState extends Equatable {
  final AuthStateStatus status;
  final Person? user;

  const AuthState._({
    this.status = AuthStateStatus.initial,
    this.user,
  });

  const AuthState.initial() : this._();

  const AuthState.authenticating()
      : this._(status: AuthStateStatus.authenticating, user: null);

  const AuthState.authenticated(Person user)
      : this._(status: AuthStateStatus.authenticated, user: user);

  const AuthState.unauthenticated()
      : this._(status: AuthStateStatus.unauthenticated, user: null);

  @override
  List<Object?> get props => [status, user];
}
