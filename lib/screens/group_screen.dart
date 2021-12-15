import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:locus_stalker/screens/group_member.dart';
import 'package:locus_stalker/screens/reset_password_screen.dart';
import 'package:locus_stalker/screens/search_screen.dart';

import 'about_screen.dart';
import 'profile_screen.dart';

final _firestore = FirebaseFirestore.instance;
final _auth = FirebaseAuth.instance;
CollectionReference groups = _firestore.collection('Groups');
CollectionReference users = _firestore.collection('users');
User? loggedInUser;

class GroupScreen extends StatefulWidget {
  static const String id = 'group_screen';

  @override
  _GroupScreenState createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
  String email = ' ';
  String userName = ' ';
  String about = ' ';
  String? changedUserName;
  String? changedEmail;
  String? changedAbout;
  String? changedPassword;
  double? latitude;
  double? longitude;
  var profilePicUrl;
  var userNameController = TextEditingController();
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  var aboutController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    userData();
    getLocation();
    getCurrentUserInfo();
  }

  getCurrentUserInfo() async {
    await users.doc(_auth.currentUser!.uid).get().then((value) {
      setState(() {
        profilePicUrl = (value.data()! as Map)['photoUrl'].toString();
      });
    });
  }

  Location location = Location();
  void getLocation() {
    location.onLocationChanged.listen((event) {
      latitude = event.latitude;
      longitude = event.longitude;
      //print("$latitude & $longitude");
      users.doc(_auth.currentUser!.uid).update({
        'latitude': latitude,
        'longitude': longitude,
      });
    });
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
    print(loggedInUser);
  }

  void userData() async {
    try {
      email = _auth.currentUser!.email!;
      userName = _auth.currentUser!.displayName!;
      users.doc(_auth.currentUser!.uid).get().then((value) => {
            setState(() {
              about = value.get('About');
              print(about);
            })
          });
    } catch (e) {
      print(e);
    }
    print(email);
    print(userName);
  }

  CustomPopupMenuController _controller = CustomPopupMenuController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[900],
      drawer: Drawer(
        backgroundColor: Colors.blueGrey[800],
        child: ListView(
          scrollDirection: Axis.vertical,
          children: [
            UserAccountsDrawerHeader(
              currentAccountPicture: GestureDetector(
                child: CircleAvatar(
                  backgroundColor: Colors.blueGrey[800],
                  child: profilePicUrl == null
                      ? Text(
                          userName[0].toUpperCase(),
                          style: TextStyle(
                            fontSize: 40.0,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: Image(
                            image: NetworkImage(profilePicUrl),
                            width: 200,
                            height: 200,
                            fit: BoxFit.fill,
                          ),
                        ),
                ),
                onTap: () async {
                  await Navigator.pushNamed(
                    context,
                    ProfileScreen.id,
                  );
                  getCurrentUserInfo();
                },
              ),
              accountName: Text(
                userName,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15.0,
                ),
              ),
              accountEmail: Text(email),
            ),
            ListTile(
              title: TextField(
                controller: userNameController,
                onChanged: (value) {
                  changedUserName = value;
                },
                decoration: InputDecoration(
                  hintText: "Change username",
                ),
              ),
              trailing: GestureDetector(
                onTap: () async {
                  try {
                    if (changedUserName != null && changedUserName != "") {
                      userNameController.clear();
                      await loggedInUser!.updateDisplayName(changedUserName);
                      await users.doc(loggedInUser!.uid).update({
                        'userName': changedUserName,
                        'searchKey': changedUserName![0].toUpperCase()
                      });
                      await groups
                          .where('users', arrayContains: userName)
                          .get()
                          .then((value) => {
                                value.docs.forEach((element) {
                                  List<dynamic> temporary =
                                      element.get('users');
                                  temporary.remove(userName);
                                  temporary.add(changedUserName);
                                  groups
                                      .doc(element.id)
                                      .update({'users': temporary});
                                })
                              });

                      setState(() {
                        userName = changedUserName!;
                      });
                    }
                  } catch (e) {
                    print(e);
                  }
                },
                child: Icon(
                  Icons.edit,
                  color: Colors.white,
                ),
              ),
            ),
            ListTile(
              title: TextField(
                keyboardType: TextInputType.emailAddress,
                controller: emailController,
                onChanged: (value) {
                  changedEmail = value;
                },
                decoration: InputDecoration(
                  hintText: "change email",
                ),
              ),
              trailing: GestureDetector(
                onTap: () async {
                  try {
                    if (changedEmail != null && changedEmail != "") {
                      emailController.clear();
                      await loggedInUser!.updateEmail(changedEmail!);
                      email = changedEmail!;
                      setState(() {});
                      await users
                          .doc(loggedInUser!.uid)
                          .update({'email': email});
                    }
                  } catch (e) {
                    print(e);
                    showDialog<String>(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                              title: Text('Invalid Email'),
                              content: Text('Email is badly formatted'),
                            ));
                  }
                },
                child: Icon(
                  Icons.edit,
                  color: Colors.white,
                ),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 25.0, vertical: 8),
              child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, ResetPasswordScreen.id);
                  },
                  child: Text('Re-set password')),
            ),
            ListTile(
              title: Text(
                'About',
                style: TextStyle(
                  fontSize: 25.0,
                  color: Colors.white,
                ),
              ),
            ),
            ListTile(
              title: TextField(
                maxLines: 5,
                cursorColor: Colors.black,
                autocorrect: true,
                keyboardType: TextInputType.text,
                onChanged: (value) {
                  changedAbout = value;
                },
                controller: aboutController,
                decoration: InputDecoration(
                  hintText: '$about',
                  hintStyle: TextStyle(
                    color: Colors.white,
                  ),
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                ),
              ),
              trailing: GestureDetector(
                onTap: () async {
                  try {
                    if (changedAbout != null && changedAbout != "") {
                      aboutController.clear();
                      about = changedAbout!;
                      setState(() {});
                      await users
                          .doc(loggedInUser!.uid)
                          .update({'About': about});
                    }
                  } catch (e) {
                    print(e);
                  }
                },
                child: Icon(
                  Icons.edit,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 4.0, horizontal: 10),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, AboutScreen.id);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'App info',
                            style: TextStyle(),
                          ),
                          Icon(Icons.info_outline)
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 4.0, horizontal: 10),
                    child: ElevatedButton(
                      onPressed: () async {
                        await _auth.signOut();
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Log-Out',
                            style: TextStyle(),
                          ),
                          Icon(Icons.logout)
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.blueGrey[800],
        elevation: 15,
        leading: Builder(
          builder: (context) => IconButton(
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
            icon: Icon(
              Icons.account_circle_rounded,
              size: 37.0,
              color: Colors.white,
            ),
          ),
        ),
        actions: <Widget>[
          Padding(
              padding: EdgeInsets.only(right: 30.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    SearchScreen.id,
                  );
                },
                child: Icon(
                  Icons.search,
                  size: 26.0,
                  color: Colors.white,
                ),
              )),
        ],
        title: Text(
          'Groups',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Groups(userName: userName),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        onPressed: () async {
          await Navigator.pushNamed(
            context,
            SearchScreen.id,
          );
        },
        child: Icon(
          Icons.group_add_outlined,
          color: Colors.white,
          size: 40,
          textDirection: TextDirection.rtl,
        ),
      ),
    );
  }
}

class Groups extends StatelessWidget {
  Groups({required this.userName});
  final String userName;

  @override
  Widget build(BuildContext context) {
    print(userName.toString());
    return StreamBuilder<QuerySnapshot>(
      stream: groups.where('users', arrayContains: userName).snapshots(),
      builder: (context, snapshot) {
        List<GroupRectangle> groupRectangles = [];
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.grey,
            ),
          );
        }
        final groups = snapshot.data!.docs;
        for (var group in groups) {
          final groupName = group['groupName'];
          final groupRectangle = GroupRectangle(groupName: groupName);
          groupRectangles.add(groupRectangle);
        }
        if (groupRectangles.length == 0)
          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                  child: Image.asset(
                    'images/no_members.png',
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                    child: Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      color: Colors.blueGrey[800],
                      elevation: 10,
                      shadowColor: Colors.black,
                      child: Padding(
                        padding: EdgeInsets.all(30),
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: "You don't have any group now, click on ",
                                style: TextStyle(
                                    fontSize: 20, color: Colors.white),
                              ),
                              TextSpan(
                                text: 'add members icon',
                                style: TextStyle(
                                    fontSize: 22,
                                    color: Colors.teal[500],
                                    fontWeight: FontWeight.bold),
                              ),
                              TextSpan(
                                text: ' to search for members.',
                                style: TextStyle(
                                    fontSize: 20, color: Colors.white),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 30,
              )
            ],
          );
        else
          return ListView.builder(
            itemCount: groupRectangles.length,
            itemBuilder: (context, index) {
              return groupRectangles[index];
            },
          );
      },
    );
  }
}

class GroupRectangle extends StatelessWidget {
  GroupRectangle({required this.groupName});
  final String groupName;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => GroupMemberScreen(
                    groupName: groupName,
                  )),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blueGrey,
          border: Border(
            bottom: BorderSide(
              width: 2.0,
              color: Colors.black12,
            ),
          ),
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                padding: EdgeInsets.all(4.0),
                height: 50.0,
                width: 50.0,
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(55),
                ),
                child: Center(
                  child: Text(
                    '${groupName[0]}'.toUpperCase(),
                    style: TextStyle(fontSize: 20.0, color: Colors.white),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: 10.0,
                horizontal: 8.0,
              ),
              child: Text(
                '$groupName',
                style: TextStyle(
                  fontSize: 20.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
