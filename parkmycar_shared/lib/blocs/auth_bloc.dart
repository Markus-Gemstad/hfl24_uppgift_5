import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import '../models/person.dart';
import '../repositories/person_firebase_repository.dart';

part 'auth_state.dart';
part 'auth_event.dart';

class AuthBloc extends HydratedBloc<AuthEvent, AuthState> {
  final PersonFirebaseRepository repository;

  AuthBloc({required this.repository}) : super(const AuthState.initial()) {
    on<AuthLoginRequested>(
        (event, emit) async => await _handleLogin(event, emit));
    on<AuthLogoutRequested>(
        (event, emit) async => await _handleLogout(event, emit));
  }

  Future<void> _handleLogin(event, emit) async {
    emit(const AuthState.authenticating());
    // TODO Ta bort fördröjning
    await Future.delayed(const Duration(seconds: 1));
    try {
      List<Person> all = await repository.getAll();
      var filtered = all.where((e) => e.email == event.email);
      if (filtered.isNotEmpty) {
        Person user = filtered.first;
        emit(AuthState.authenticated(user));
      } else {
        emit(const AuthState.unauthenticated());
      }
    } catch (e) {
      emit(const AuthState.unauthenticated());
    }
  }

  Future<void> _handleLogout(event, emit) async {
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
      'user':
          state.user == null ? null : PersonSerializer().toJson(state.user!),
    };
  }
}
