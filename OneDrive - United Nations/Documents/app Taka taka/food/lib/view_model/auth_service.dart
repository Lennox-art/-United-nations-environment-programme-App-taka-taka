import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late final ValueNotifier<User?> userNotifier = ValueNotifier(_auth.currentUser);
  bool get isUserLoggedIn => _auth.currentUser != null;


  AuthService() {
    userNotifier.addListener(() {
    if(userNotifier.value == null) {
        print("No user");
        } else {
        print("Has user");
        }
    });


    _auth.authStateChanges().listen((user) {
      print("Auth updated");
      userNotifier.value = user;
    });

    _auth.userChanges().listen((user) {
      print("User updated");
      userNotifier.value = user;
    });
  }


  MapEntry<String, String>? getNamesFromEmail() {
      var user = userNotifier.value;
      if(user == null) return null;
      var emailNames = user.email!.split("@");
      var allNames = emailNames.first.split(".");
      return MapEntry(allNames.first, allNames.last);
    }

  Future<void> changeProfilePicture(String photoUrl) async {
    var user = userNotifier.value;
    if(user == null) return;
    await user.updatePhotoURL(photoUrl);
  }

  Future<void> changeDisplayName(String displayName) async {
    var user = userNotifier.value;
    if(user == null) return;
    await user.updateDisplayName(displayName);
  }


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
