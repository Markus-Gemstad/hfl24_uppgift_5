import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:parkmycar_shared/repositories/auth_repository.dart';
import '../models/person.dart';
import '../repositories/person_firebase_repository.dart';

part 'auth_state.dart';
part 'auth_event.dart';

class AuthBloc extends HydratedBloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;
  final PersonFirebaseRepository personRepository;

  AuthBloc({required this.authRepository, required this.personRepository})
      : super(const AuthState.initial()) {
    // on<AuthUserSubscriptionRequested>(
    //     (event, emit) async => await _onUserSubscriptionRequested(event, emit));
    // on<AuthRegister>((event, emit) async => await _onRegister(event, emit));
    // on<AuthFinalizeRegistration>(
    //     (event, emit) async => await _onFinalizeRegistration(event, emit));
    on<AuthLoginRequested>((event, emit) async => await _onLogin(event, emit));
    on<AuthLogoutRequested>(
        (event, emit) async => await _onLogout(event, emit));
  }

  // Future<void> _onUserSubscriptionRequested(event, emit) async {
  //   authRepository.userStream.listen((user) async {
  //     if (user == null) {
  //       emit(const AuthState.unauthenticated());
  //     } else {
  //       Person? person = await personRepository.getByAuthId(user.uid);
  //       if (person == null) {
  //         emit(AuthState.authenticatedNoPerson(user.uid, user.email!));
  //       } else {
  //         emit(AuthState.authenticated(person));
  //       }
  //     }
  //   });
  // }

  // Future<void> _onRegister(AuthRegister event, emit) async {
  //   emit(AuthState.authenticatedPersonPending(event.email, event.password));
  //   await authRepository.register(email: event.email, password: event.password);
  // }

  // Future<void> _onFinalizeRegistration(
  //     AuthFinalizeRegistration event, emit) async {
  //   emit(AuthState.authenticatedNoPerson(event.authId, event.email));
  //   final person = await personRepository
  //       .create(Person('noname', event.authId, event.username));

  //   // this operation does not trigger a change on the auth stream.
  //   emit(AuthState.authenticated(person!));
  // }

  Future<void> _onLogin(AuthLoginRequested event, emit) async {
    emit(const AuthState.authenticating());

    try {
      // Login to firebase authorization
      await authRepository.login(email: event.email, password: event.password);

      // Find user in person repository
      List<Person> all = await personRepository.getAll();
      var filtered = all.where((e) => e.email == event.email);
      if (filtered.isNotEmpty) {
        Person person = filtered.first;
        emit(AuthState.authenticated(person));
      } else {
        await authRepository.logout();
        emit(const AuthState.unauthenticated());
      }
    } catch (e) {
      await authRepository.logout();
      emit(const AuthState.unauthenticated());
    }
  }

  Future<void> _onLogout(AuthLogoutRequested event, emit) async {
    await authRepository.logout();
    // No reason to emit state here because this triggers a change on the
    // authStateChanges stream, the stream handler will emit the appropriate state
    emit(const AuthState.initial());
  }

  @override
  AuthState? fromJson(Map<String, dynamic> json) {
    return switch (AuthStateStatus.values[json['status']]) {
      AuthStateStatus.authenticated =>
        AuthState.authenticated(PersonSerializer().fromJson(json['user'])),
      _ => const AuthState.unauthenticated(),
    };
  }

  @override
  Map<String, dynamic>? toJson(AuthState state) {
    return {
      'status': state.status.index,
      'user': state.person == null
          ? null
          : PersonSerializer().toJson(state.person!),
    };
  }
}
