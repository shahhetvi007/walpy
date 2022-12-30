import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:work_manager_demo/helper/prefs_utils.dart';

class AuthHelper {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  get user => _auth.currentUser;

  Future signUp(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      print(e.code);
      if (e.code == 'email-already-in-use') {
        return 'The email address is already in use by another account.';
      } else if (e.code == 'network-request-failed') {
        return 'No internet connection.';
      }
      return e.toString();
    }
  }

  Future signIn(String email, String password) async {
    print(email);
    print(password);
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "account-exists-with-different-credential":
          return "Account already exists with different credentials.";
        case "email-already-in-use":
          return "Email already used.";
        case "wrong-password":
          return "Wrong email/password combination.";
        case "user-not-found":
          return "No user found with this email.";
        case "user-disabled":
          return "User disabled.";
        case "operation-not-allowed":
          return "Too many requests to log into this account.";
        case "operation-not-allowed":
          return "Server error, please try again later.";
        case "invalid-email":
          return "Email address is invalid.";
        case 'network-request-failed':
          return 'No internet connection.';
        default:
          return "Login failed. Please try again.";
      }
    }
  }

  isAdmin() async {
    final DocumentSnapshot ref =
        await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    bool isAdmin = ref.get('isAdmin');
    await PreferenceUtils.setBool('isAdmin', isAdmin);
  }

  signOut() async {
    PreferenceUtils.clear();
    return await _auth.signOut();
  }
}
