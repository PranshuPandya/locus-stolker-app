import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:locus_stalker/screens/map_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'add_member_screen.dart';
import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

final _firestore = FirebaseFirestore.instance;
final _auth = FirebaseAuth.instance;
CollectionReference groups = _firestore.collection('Groups');
User? loggedInUser;

class GroupMemberScreen extends StatefulWidget {
  static const String id = 'group_member_screen';
  GroupMemberScreen({this.groupName});
  final String? groupName;

  @override
  _GroupMemberScreenState createState() => _GroupMemberScreenState();
}

class _GroupMemberScreenState extends State<GroupMemberScreen> {
  String? groupId;

  @override
  void initState() {
    super.initState();
    //getGroupUser();
    getCurrentUser();
    getGroupId();
  }

  void _update() {
    //setState(() {});
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

  void getGroupId() async {
    await groups.where('groupName', isEqualTo: widget.groupName).get().then((querySnapshot) => {
          setState(() {
            querySnapshot.docs.forEach((element) {
              groupId = element.id;
              print(groupId);
            });
          })
        });
  }

  CustomPopupMenuController _controller = CustomPopupMenuController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.groupName}'),
        actions: [
          CustomPopupMenu(
            child: Container(
              child: Icon(Icons.map_sharp),
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
            ),
            menuBuilder: () => ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: Container(
                color: Colors.black12,
                child: IntrinsicWidth(
                  child: GestureDetector(
                    onTap: () {
                      _controller.hideMenu();
                    },
                    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                      ListTile(
                          onTap: () {
                            _controller.hideMenu();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MapScreen(
                                  groupName: widget.groupName,
                                  groupId: groupId,
                                  mapType: MapType.normal,
                                ),
                              ),
                            );
                          },
                          leading: Text("Normal Map")),
                      ListTile(
                        leading: Text("Hybrid Map"),
                        onTap: () {
                          _controller.hideMenu();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MapScreen(
                                groupName: widget.groupName,
                                groupId: groupId,
                                mapType: MapType.hybrid,
                              ),
                            ),
                          );
                        },
                      )
                    ]),
                  ),
                ),
              ),
            ),
            pressType: PressType.singleClick,
            controller: _controller,
          ),
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 20.0),
          //   child: GestureDetector(
          //     onTap: () {
          //       Navigator.push(
          //         context,
          //         MaterialPageRoute(
          //           builder: (context) => MapScreen(groupName: widget.groupName, groupId: groupId),
          //         ),
          //       );
          //     },
          //     child: Icon(
          //       Icons.map_sharp,
          //     ),
          //   ),
          // ),
        ],
      ),
      body: Members(
        groupName: widget.groupName,
        update: _update,
      ),
      bottomNavigationBar: BottomAppBar(
        child: FlatButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (contexta) => AlertDialog(
                backgroundColor: Colors.grey.shade900,
                title: Text('Leave Group'),
                actions: [
                  FlatButton(
                    onPressed: () async {
                      await groups.where('groupName', isEqualTo: widget.groupName).get().then((value) => {
                            value.docs.forEach((element) {
                              List<dynamic> tem = element.get('users');
                              Map<String, dynamic> temp2 = element.get('Status');
                              temp2.remove(loggedInUser!.displayName);
                              tem.remove(loggedInUser!.displayName);
                              groups.doc(element.id).update({'users': tem, 'Status': temp2});
                            })
                          });
                      Navigator.pop(contexta);
                      Navigator.pop(context);
                    },
                    child: Text('Confirm'),
                  )
                ],
              ),
            );
          },
          child: Container(
            height: 60.0,
            child: Center(
              child: Text(
                'Leave Group',
                style: TextStyle(
                  fontSize: 18.0,
                ),
              ),
            ),
          ),
        ),
        color: Colors.black54,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddMemberScreen(
                groupName: widget.groupName,
              ),
            ),
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

class Members extends StatelessWidget {
  Members({this.groupName, required this.update});
  final String? groupName;
  final VoidCallback update;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: groups.where('groupName', isEqualTo: groupName).snapshots(),
      builder: (context, snapshot) {
        List<GroupRectangle> groupRectangles = [];
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.grey,
            ),
          );
        }
        final groupname = snapshot.data!.docs;
        for (var singleGroup in groupname) {
          List<dynamic> temp = singleGroup.get('users');
          Map<String, dynamic> temp2 = singleGroup.get('Status');
          for (var member in temp) {
            final groupRectangle = GroupRectangle(
              memberName: member,
              groupName: groupName,
              update: update,
              isSwitched: temp2[member],
            );
            groupRectangles.add(groupRectangle);
          }
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
  GroupRectangle({required this.memberName, this.groupName, required this.update, required this.isSwitched});
  final String memberName;
  final String? groupName;
  final VoidCallback update;
  final bool? isSwitched;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (memberName != loggedInUser!.displayName) {
          showDialog(
            context: context,
            builder: (contexta) => AlertDialog(
              backgroundColor: Colors.grey.shade900,
              title: Text('Remove Member'),
              actions: [
                FlatButton(
                  onPressed: () async {
                    await groups.where('groupName', isEqualTo: groupName).get().then((value) => {
                          value.docs.forEach((element) {
                            List<dynamic> temp = element.get('users');
                            Map<String, dynamic> temp2 = element.get('Status');
                            temp2.remove(memberName);
                            temp.remove(memberName);
                            groups.doc(element.id).update({'users': temp, 'Status': temp2});
                          })
                        });
                    Navigator.pop(contexta);
                  },
                  child: Text('Remove'),
                ),
              ],
            ),
          );
        }
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
                    '${memberName[0]}'.toUpperCase(),
                    style: TextStyle(
                      fontSize: 20.0,
                    ),
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
                '$memberName',
                style: TextStyle(
                  fontSize: 20.0,
                ),
              ),
            ),
            Spacer(),
            Switch(
              activeColor: memberName == loggedInUser!.displayName
                  ? Colors.tealAccent.shade200
                  : Colors.tealAccent.shade100.withOpacity(0.5),
              inactiveTrackColor: memberName == loggedInUser!.displayName
                  ? Colors.grey.shade600
                  : Colors.grey.shade600.withOpacity(0.5),
              inactiveThumbColor: memberName == loggedInUser!.displayName
                  ? Colors.grey.shade400
                  : Colors.grey.shade400.withOpacity(0.5),
              onChanged: (isSelected) async {
                await groups.where('groupName', isEqualTo: groupName).get().then((value) => {
                      value.docs.forEach((element) {
                        Map<String, dynamic> temp2 = element.get('Status');
                        isSelected = temp2[memberName];
                        if (memberName == loggedInUser!.displayName) {
                          temp2.update(memberName, (value) => !isSelected, ifAbsent: () => !isSelected);
                        }
                        groups.doc(element.id).update({'Status': temp2});
                      })
                    });
              },
              value: isSwitched!,
            ),
          ],
        ),
      ),
    );
  }
}
