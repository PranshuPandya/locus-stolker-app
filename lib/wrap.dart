import 'package:flutter/material.dart';
import 'package:locus_stalker/services/auth.dart';
import 'package:provider/provider.dart';
import 'screens/welcome_screen.dart';
import 'screens/group_screen.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({Key? key}) : super(key: key);
  static const String id = "Wrap";

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<LocalUser?>(context);

    if (user == null) {
      return WelcomeScreen();
    } else {
      return GroupScreen();
    }
  }
}
