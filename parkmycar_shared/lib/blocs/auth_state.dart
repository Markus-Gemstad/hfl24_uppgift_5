part of 'auth_bloc.dart';

enum AuthStateStatus {
  initial,
  authenticating,
  // authenticatedNoPerson,
  // authenticadPersonPending,
  authenticated,
  unauthenticated
}

class AuthState extends Equatable {
  final AuthStateStatus status;
  final Person? person;

  const AuthState._({
    this.status = AuthStateStatus.initial,
    this.person,
  });

  const AuthState.initial() : this._();

  const AuthState.authenticating()
      : this._(status: AuthStateStatus.authenticating, person: null);

  // const AuthState.authenticatedNoPerson(String authId, String email)
  //     : this._(status: AuthStateStatus.authenticatedNoPerson, person: null);

  // const AuthState.authenticatedPersonPending(String authId, String email)
  //     : this._(status: AuthStateStatus.authenticadPersonPending, person: null);

  const AuthState.authenticated(Person person)
      : this._(status: AuthStateStatus.authenticated, person: person);

  const AuthState.unauthenticated()
      : this._(status: AuthStateStatus.unauthenticated, person: null);

  @override
  List<Object?> get props => [status, person];
}
