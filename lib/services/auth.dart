import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';

class LocalUser {
  final String uid;

  LocalUser({required this.uid});
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // create user object based on FirebaseUser
  LocalUser? userFromFirebaseUser(User? user) {
    return user != null ? LocalUser(uid: user.uid) : null;
  }

  Stream<LocalUser?> get user {
    // listen to authentication changes and return local user or null
    return _auth
        .authStateChanges()
        .map((User? user) => userFromFirebaseUser(user));
  }
}
