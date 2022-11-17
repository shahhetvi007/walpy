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
      if (e.code == 'email-already-in-use') {
        return 'The email address is already in use by another account.';
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
      return e.message;
    }
  }

  isAdmin() async {
    final DocumentSnapshot ref =
        await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    bool isAdmin = ref.get('isAdmin');
    PreferenceUtils.setBool('isAdmin', isAdmin);
  }

  signOut() async {
    return await _auth.signOut();
  }
}
