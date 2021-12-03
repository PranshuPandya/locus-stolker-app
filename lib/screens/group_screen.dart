import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:locus_stalker/screens/group_member.dart';
import 'package:locus_stalker/screens/login_screen.dart';
import 'package:locus_stalker/screens/reset_password_screen.dart';
import 'package:locus_stalker/screens/search_screen.dart';
import 'package:location/location.dart';
import 'profile_screen.dart';
import 'about_screen.dart';

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
  String? email;
  String? userName;
  String? about;
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
      email = _auth.currentUser!.email;
      userName = _auth.currentUser!.displayName;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              currentAccountPicture: GestureDetector(
                child: CircleAvatar(
                  backgroundColor: Colors.grey.shade800,
                  child: profilePicUrl == null
                      ? Text(
                          userName![0].toUpperCase(),
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
                userName!,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15.0,
                ),
              ),
              accountEmail: Text(email!),
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
                      await users
                          .doc(loggedInUser!.uid)
                          .update({'userName': changedUserName, 'searchKey': changedUserName![0].toUpperCase()});
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
                        userName = changedUserName;
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
                      email = changedEmail;
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
                            )
                            );
                  }
                },
                child: Icon(
                  Icons.edit,
                  color: Colors.white,
                ),
              ),
            ),
            ListTile(
              title: Text(
                'Re-set password',
                style: TextStyle(color: Colors.white),
              ),
              trailing: GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, ResetPasswordScreen.id);
                },
                child: Icon(
                  Icons.edit,
                  color: Colors.white,
                ),
              ),
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
          ],
        ),
      ),
      appBar: AppBar(
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
              padding: EdgeInsets.only(right: 20.0),
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
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, AboutScreen.id);
                  },
                  child: Text("About"),
                ),
              ),
              PopupMenuItem(
                child: GestureDetector(
                  onTap: () {
                    _auth.signOut();
                    Navigator.popUntil(
                        context, ModalRoute.withName(LoginScreen.id));
                  },
                  child: Text("Log Out"),
                ),
              ),
            ],
            shape: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(6.0)),
            ),
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Icon(
                Icons.more_vert,
                color: Colors.white,
              ),
            ),
          ),
        ],
        title: Text(
          'Groups',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black12,
      ),
      body: Groups(userName: userName),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        onPressed: () async {
          await Navigator.pushNamed(
            context,
            SearchScreen.id,
          );
        },
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}

class Groups extends StatelessWidget {
  Groups({this.userName});
  final String? userName;

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
