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

  Future<UserCredential> signInWithGoogle() async {
    // Future<void> signInWithGoogle() async {
    // Create a new provider
    GoogleAuthProvider googleProvider = GoogleAuthProvider();

    // googleProvider
    //     .addScope('https://www.googleapis.com/auth/contacts.readonly');
    // googleProvider.setCustomParameters({'login_hint': 'user@example.com'});

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithPopup(googleProvider);

    //UserCredential userCredential = await FirebaseAuth.instance.getRedirectResult();

    // Or use signInWithRedirect
    // return await authService.signInWithRedirect(googleProvider);
  }

  Stream<User?> get userStream {
    // stream emits when any of the above functions complete
    // emits null when user is signed out, otherwise User
    return authService.authStateChanges();
  }
}
