import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';

import '../components/rounded_button.dart';
import 'login_screen.dart';
import 'registration_screen.dart';

class WelcomeScreen extends StatefulWidget {
  static const String id = 'welcome_screen';

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Hero(
                  tag: 'logo',
                  child: Image(
                    image: AssetImage('images/icon_image.png'),
                    height: 60.0,
                  ),
                ),
                SizedBox(
                  width: 10.0,
                ),
                Flexible(
                  child: AnimatedTextKit(
                    animatedTexts: [
                      TypewriterAnimatedText(
                        'Locus Stalker',
                        speed: Duration(milliseconds: 80),
                        textStyle: TextStyle(
                          color: Colors.tealAccent.shade100,
                          fontSize: 40.0,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 48.0,
            ),
            RoundedButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  LoginScreen.id,
                );
              },
              colour: Colors.teal.shade400,
              text: 'Log In',
            ),
            RoundedButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  RegistrationScreen.id,
                );
              },
              colour: Colors.teal.shade200,
              text: 'Register',
            ),
          ],
        ),
      ),
    );
  }
}
