import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

final _firestore = FirebaseFirestore.instance;
CollectionReference groups = _firestore.collection('Groups');
CollectionReference users = _firestore.collection('users');
User? loggedInUser;
List<dynamic> _userNames = [];
List<String> _selectedUserNames = [];
List<MemberRectangle> memberRectangles = [];

class SearchScreen extends StatefulWidget {
  static const String id = 'search_screen';
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _auth = FirebaseAuth.instance;
  String? groupName;
  String? _username;
  var queryResultSet = [];
  var tempSearchStore = [];

  @override
  void initState() {
    super.initState();

    getCurrentUser();
    _userNames.clear();
    _selectedUserNames.clear();
    _username = loggedInUser!.displayName;
  }
  
  void _update(){
    setState(() {});
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

  initiateSearch(value) {
    if (value.length == 0) {
      setState(() {
        queryResultSet = [];
        tempSearchStore = [];
      });
    }

    bool trig = false;
    if (queryResultSet.length == 0 && value.length == 1) {
      SearchService().searchByName(value).then((QuerySnapshot docs) {
        print('if $queryResultSet ');
        for (int i = 0; i < docs.docs.length; ++i) {
          queryResultSet.add(docs.docs[i].data());
          print('for $queryResultSet');
        }
        queryResultSet.forEach(
              (element) {
            if (element['userName'].startsWith(value) && element['userName'] != _username) {
              setState(() {
                tempSearchStore.add(element);
                print('if else $tempSearchStore');
                trig = true;
              });
            }
          },
        );
      });
    } else {
      print(' else $queryResultSet');
      tempSearchStore = [];
      queryResultSet.forEach((element) {
        if (element['userName'].startsWith(value) && element['userName'] != _username) {
          setState(() {
            tempSearchStore.add(element);
            print('if else $tempSearchStore');
            trig = true;
          });
        }
      });
      print(trig);
      if (!trig) {
        setState(() {
          tempSearchStore = [];
        });
      }
      print(tempSearchStore);
      _userNames = tempSearchStore;
    }
  }

  void _deleteSelected(String label) {
    setState(() {
      _selectedUserNames.remove(label);
    });
  }

  Widget _buildChip(String label, Color color) {
    return Chip(
      labelPadding: EdgeInsets.all(2.0),
      avatar: CircleAvatar(
        backgroundColor: Colors.black,
        child: Text(label[0].toUpperCase()),
      ),
      label: Text(
        label,
        style: TextStyle(
          color: Colors.black,
        ),
      ),
      deleteIcon: Icon(
        Icons.close,
        color: Colors.black,
      ),
      onDeleted: () => _deleteSelected(label),
      backgroundColor: Colors.white,
      elevation: 6.0,
      shadowColor: Colors.grey[60],
      padding: EdgeInsets.all(8.0),
    );
  }

  bool _isLoading = false;
  var _dialogBoxController = TextEditingController();

  List<Widget> wrapChip(){
    return _selectedUserNames
        .map((item) => _buildChip(item, Color(0xFFff6666)))
        .toList()
        .cast<Widget>();
  }
  
  Map<String,bool> addStatus(_selectedUser){
    Map<String,bool> status = <String,bool>{};
    for(var member in _selectedUser){
      status.update(member, (value) => true,ifAbsent: () => true);
    }
    return status;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          decoration: InputDecoration(
            hintText: 'Search Member',
          ),
          onChanged: (value) async {
            initiateSearch(value);
          },
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 20.0),
            child: GestureDetector(
              onTap: () {},
              child: Icon(
                Icons.search,
                size: 26.0,
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Colors.grey,
              ),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                  ),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Wrap(
                        spacing: 6.0,
                        runSpacing: 6.0,
                        children: wrapChip(),
                    ),
                  ),
                ),
                Divider(
                  thickness: 1.0,
                ),
                Expanded(
                    child: ListView(
                      children: _userNames.map((e) => MemberRectangle(memberName: e['userName'],update: () => _update(),)).toList(),
                    )
                    ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        onPressed: () {
          showDialog(
            context: context,
            builder: (contexta) => AlertDialog(
              title: Text('Group Name'),
              content: TextField(
                onChanged: (value) {},
                controller: _dialogBoxController,
                decoration: InputDecoration(hintText: 'here'),
              ),
              actions: [
                ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: Colors.black54,
          ),
                  onPressed: () {
                    if (_selectedUserNames.length != 0 && _dialogBoxController.text != null && _dialogBoxController.text != '') {
                      Navigator.pop(contexta);
                      Navigator.pop(context,_dialogBoxController.text);
                      if(!_selectedUserNames.contains(_username)){
                        _selectedUserNames.add(_username!);
                      }
                      groups.add({
                        'groupName' : _dialogBoxController.text,
                        'users' : _selectedUserNames,
                        'Status' : addStatus(_selectedUserNames),
                      });
                    }
                  },
                  child: Text('Make'),
                  color: Colors.black54,
                ),
              ],
            ),
          );
        },
        child: Icon(
          Icons.check,
          color: Colors.white,
        ),
      ),
    );
  }
}

class WrapSelectedUsers extends StatefulWidget {
  @override
  _WrapSelectedUsersState createState() => _WrapSelectedUsersState();
}

class _WrapSelectedUsersState extends State<WrapSelectedUsers> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class MemberRectangle extends StatefulWidget {
  MemberRectangle({required this.memberName,required this.update});
  final String memberName;
  final VoidCallback update;

  @override
  _MemberRectangleState createState() => _MemberRectangleState();
}

class _MemberRectangleState extends State<MemberRectangle> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.update();
        if (_selectedUserNames.contains(widget.memberName)) {
          setState(() {
            _selectedUserNames.remove(widget.memberName);
          });
        } else {
          setState(() {
            _selectedUserNames.add(widget.memberName);
          });
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
                    '${widget.memberName[0]}'.toUpperCase(),
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
                '${widget.memberName}',
                style: TextStyle(
                  fontSize: 20.0,
                ),
              ),
            ),
            Spacer(),
            _selectedUserNames.contains(widget.memberName)
                ? Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                      padding: EdgeInsets.all(4.0),
                      height: 50.0,
                      width: 50.0,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(55),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.check,
                          size: 30.0,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  )
                : Spacer(),
          ],
        ),
      ),
    );
  }
}

class SearchService {
  searchByName(String searchField) {
    return FirebaseFirestore.instance
        .collection('users')
        .where('searchKey',
            isEqualTo: searchField.substring(0, 1).toUpperCase())
        .get();
  }
}
