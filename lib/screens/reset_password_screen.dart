import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:locus_stalker/constants.dart';

import '../components/rounded_button.dart';

User? loggedInUser;

class ResetPasswordScreen extends StatefulWidget {
  static const String id = 'reset_password_screen';

  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _auth = FirebaseAuth.instance;
  String? newPassword;

  @override
  void initState() {
    super.initState();

    getCurrentUser();
  }

  void getCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[600],
      appBar: AppBar(
        backgroundColor: Colors.blueGrey[800],
        title: Text('Re-set password'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(60.0),
              child: Image.asset('images/reset-password.png'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
            child: TextField(
              keyboardType: TextInputType.emailAddress,
              textAlign: TextAlign.center,
              onChanged: (value) {
                newPassword = value;
              },
              decoration: kTextFieldDecoration
                  .copyWith(hintText: 'Enter new password')
                  .copyWith(
                      hintStyle: TextStyle(
                    color: Colors.white,
                  )),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
            child: RoundedButton(
              colour: Colors.teal,
              text: 'Set password',
              onPressed: () {
                try {
                  loggedInUser!.updatePassword(newPassword!);
                  Navigator.pop(context);
                } catch (e) {
                  print(e);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(
                      'Something went wrong!',
                      style: TextStyle(fontSize: 20),
                    ),
                    backgroundColor: Colors.grey[700],
                    behavior: SnackBarBehavior.floating,
                  ));
                }
              },
            ),
          ),
          SizedBox(
            height: 80,
          )
        ],
      ),
    );
  }
}
