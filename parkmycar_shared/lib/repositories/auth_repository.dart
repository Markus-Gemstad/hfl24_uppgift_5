import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  final authService = FirebaseAuth.instance;

  Future<UserCredential> register(
      {required String email, required String password}) async {
    return await authService.createUserWithEmailAndPassword(
        email: email, password: password);
  }

  Future<void> changePassword({required String password}) async {
    return authService.currentUser!.updatePassword(password);
  }

  Future<UserCredential> login(
      {required String email, required String password}) async {
    // as per documentation, this method throws an exception if login fails
    // as per documentaiton, successful login updates authStateChanges stream
    return await authService.signInWithEmailAndPassword(
        email: email, password: password);
  }

  Future<void> logout() async {
    await authService.signOut();
  }

  Stream<User?> get userStream {
    // stream emits when any of the above functions complete
    // emits null when user is signed out, otherwise User
    return authService.authStateChanges();
  }
}
