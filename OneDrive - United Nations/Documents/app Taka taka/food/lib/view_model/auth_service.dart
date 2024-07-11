import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool get isUserLoggedIn => _auth.currentUser != null;
  User? get user => _auth.currentUser;


  Future<void> logout() async => _auth.signOut();

  // Sign in with email and password
  Future<User?> signInWithEmailPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return result.user;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  //Create account with email and password
  Future<User?> createAccount(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return result.user;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
  // send forgot password link
   resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
   }


  // Sign out
  Future<bool> signOut() async {
    try {
       await _auth.signOut();
       return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }
}
