import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatefulWidget {
  static const String id = 'about_screen';

  @override
  _AboutScreenState createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  @override
  Widget build(BuildContext context) {
    const String linkdinKandoi =
        'https://www.linkedin.com/in/pranshu-kandoi-833a51200/';
    const String githubKandoi = 'https://github.com/pranshu82';
    const String imgKandoi =
        'https://avatars.githubusercontent.com/u/75984856?v=4';

    const String linkdinPandya =
        'https://www.linkedin.com/in/pranshu-pandya-9586b8200';
    const String githubPandya = 'https://github.com/PranshuPandya';
    const String imgPandya =
        'https://avatars.githubusercontent.com/u/72974832?v=4';

    String _aboutThisApp =
        'Locus Stalker is a live location tracker app made for knowing locations of your group of friends in real time.User can easily stalk any of his friend\'s location. User can easily create, leave and manage groups by adding removing members. It gives user the freedom to share his location to the groups of his choice. It uses Firebase for database and uses email authentication or google sign in to register. Users can easily update their userinfo such as username, email and password. It allows user to set profilepic from gallery or camera.';
    return Scaffold(
      backgroundColor: Colors.blueGrey[300],
      appBar: AppBar(
        backgroundColor: Colors.blueGrey[800],
        title: Text('About'),
      ),
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.only(top: 20),
            child: Column(
              children: <Widget>[
                Container(
                  alignment: Alignment.topCenter,
                  child: const Text(
                    "Locus-Stalker app",
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  child: Card(
                    color: Colors.blueGrey[600],
                    elevation: 6,
                    shadowColor: Colors.grey,
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        _aboutThisApp,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                  ),
                ),
                _buildTeamTitle('AUTHOR'),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: <Widget>[
                        _buildProfileImage(imgPandya),
                        Container(
                          margin: const EdgeInsets.only(top: 10),
                          child: Column(
                            children: <Widget>[
                              Text(
                                "Pranshu Pandya",
                                style: TextStyle(fontSize: 20),
                              ),
                              const Padding(padding: EdgeInsets.only(top: 5)),
                              Row(
                                children: <Widget>[
                                  _buildProfileIcon(linkdinPandya,
                                      'https://img.icons8.com/fluent/48/000000/linkedin-circled.png'),
                                  const Padding(
                                      padding: EdgeInsets.only(left: 10)),
                                  _buildProfileIcon(githubPandya,
                                      'https://img.icons8.com/fluent/50/000000/github.png'),
                                ],
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: <Widget>[
                        _buildProfileImage(imgKandoi),
                        Container(
                          margin: const EdgeInsets.only(top: 10),
                          child: Column(
                            children: <Widget>[
                              Text(
                                "Pranshu Kandoi",
                                style: TextStyle(fontSize: 20),
                              ),
                              const Padding(padding: EdgeInsets.only(top: 5)),
                              Row(
                                children: <Widget>[
                                  _buildProfileIcon(linkdinKandoi,
                                      'https://img.icons8.com/fluent/48/000000/linkedin-circled.png'),
                                  const Padding(
                                      padding: EdgeInsets.only(left: 10)),
                                  _buildProfileIcon(githubKandoi,
                                      'https://img.icons8.com/fluent/50/000000/github.png'),
                                ],
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  alignment: Alignment.bottomCenter,
                  padding: EdgeInsets.all(30),
                  child: Text(
                    "Made with ❤ by Open Source",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTeamTitle(String title) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      alignment: Alignment.center,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildProfileImage(String imagePath) {
    return Container(
      width: 120.0,
      height: 120.0,
      decoration: BoxDecoration(
        boxShadow: _buildBoxShadow,
        shape: BoxShape.circle,
      ),
      child: SizedBox(
        width: 100,
        height: 100,
        child: DecoratedBox(
          decoration: BoxDecoration(
            boxShadow: _buildBoxShadow,
            color: Colors.black,
            shape: BoxShape.circle,
            image: DecorationImage(
              image: NetworkImage(imagePath),
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }

  List<BoxShadow> get _buildBoxShadow => [
        BoxShadow(
          offset: const Offset(0.00, 3.00),
          color: const Color(0xff000000).withOpacity(0.16),
          blurRadius: 6,
        ),
      ];
  Widget _buildProfileIcon(String link, String iconUrl) {
    return Container(
      width: 40.0,
      height: 40.0,
      decoration: BoxDecoration(
        boxShadow: _buildBoxShadow,
        shape: BoxShape.circle,
      ),
      child: RawMaterialButton(
        shape: const CircleBorder(),
        elevation: 10,
        onPressed: () async {
          await _launchURL(link);
        },
        child: SizedBox(
          width: 100,
          height: 100,
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: NetworkImage(iconUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'Something went wrong!',
          style: TextStyle(fontSize: 20),
        ),
        backgroundColor: Colors.grey[700],
        behavior: SnackBarBehavior.floating,
      ));
      throw 'Could not launch $url';
    }
  }
}
