// import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:locus_stalker/screens/group_screen.dart';
import 'package:locus_stalker/screens/login_screen.dart';
import 'package:locus_stalker/screens/registration_screen.dart';
import 'package:locus_stalker/screens/welcome_screen.dart';

import 'screens/about_screen.dart';
import 'screens/group_member.dart';
import 'screens/map_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/reset_password_screen.dart';
import 'screens/search_screen.dart';
import 'screens/splash_screen.dart';
// import 'components/search_design.dart';

void main() async {
  final binding = WidgetsFlutterBinding.ensureInitialized();
  binding.deferFirstFrame();
  binding.addPostFrameCallback((_) {
    BuildContext context = binding.renderViewElement as BuildContext;
    if (context != null) {
      SplashScreen();
    }
    binding.allowFirstFrame();
  });
  await Firebase.initializeApp();
  runApp(LocusStalker());
}

class LocusStalker extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
        textTheme: TextTheme(
          bodyText1: TextStyle(color: Colors.black54),
        ),
      ),
      home: SplashScreen(),
      //initialRoute: WelcomeScreen.id,
      routes: {
        WelcomeScreen.id: (context) => WelcomeScreen(),
        LoginScreen.id: (context) => LoginScreen(),
        RegistrationScreen.id: (context) => RegistrationScreen(),
        GroupScreen.id: (context) => GroupScreen(),
        MapScreen.id: (context) => MapScreen(),
        ResetPasswordScreen.id: (context) => ResetPasswordScreen(),
        SearchScreen.id: (context) => SearchScreen(),
        GroupMemberScreen.id: (context) => GroupMemberScreen(),
        AboutScreen.id: (context) => AboutScreen(),
        ProfileScreen.id: (context) => ProfileScreen(),
      },
    );
  }
}
