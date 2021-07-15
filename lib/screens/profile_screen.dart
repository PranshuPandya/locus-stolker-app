import 'dart:async';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:locus_stalker/constants.dart';

final _firestore = FirebaseFirestore.instance;
CollectionReference users = _firestore.collection('users');
final ImagePicker _picker = ImagePicker();
final _auth = FirebaseAuth.instance;
String? currentUserId = _auth.currentUser!.uid;
String? aboutCurrentUser;

class ProfileScreen extends StatefulWidget {
  static const String id = 'profile_screen';

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  PickedFile? _image;
  var downloadUrl = kDefaultUrl;
  var profilePicUrl;

  _imgFromCamera() async {
    PickedFile? image = await _picker.getImage(source: ImageSource.camera);

    setState(() {
      _image = image;
    });
    if (image != null) {
      updateProfilePic(File(_image!.path));
    }
  }

  _imgFromGallery() async {
    PickedFile? image = await _picker.getImage(source: ImageSource.gallery);

    setState(() {
      _image = image;
    });
    if (image != null) {
      updateProfilePic(File(_image!.path));
    }
  }

  @override
  void initState() {
    super.initState();

    getCurrentUserInfo();
  }

  getCurrentUserInfo() async {
    await users.doc(currentUserId).get().then((value) {
      setState(() {
        aboutCurrentUser = (value.data()! as Map)['About'].toString();
        profilePicUrl = (value.data()! as Map)['photoUrl'].toString();
      });
    });
  }

  Future<String> uploadImage(imgPath) async {
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference ref = storage.ref().child('profilepics/$currentUserId.jpg');
    UploadTask task = ref.putFile(imgPath);
    var downurl = await (await task).ref.getDownloadURL();
    downloadUrl = downurl;
    return downurl.toString();
  }

  Future updateProfilePic(imgPath) async {
    users.doc(currentUserId).update({
      'photoUrl': await uploadImage(imgPath),
    });
    getCurrentUserInfo();
  }

  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: Wrap(
                children: <Widget>[
                  ListTile(
                      leading: Icon(Icons.photo_library),
                      title: Text('Photo Library'),
                      onTap: () {
                        _imgFromGallery();
                        Navigator.of(context).pop();
                      }),
                  ListTile(
                    leading: Icon(Icons.photo_camera),
                    title: Text('Camera'),
                    onTap: () {
                      _imgFromCamera();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      resizeToAvoidBottomInset: false,
      body: ListView(
        children: <Widget>[
          SizedBox(
            height: 32,
          ),
          Center(
            child: GestureDetector(
              onTap: () {
                _showPicker(context);
              },
              child: CircleAvatar(
                radius: 100,
                backgroundColor: Colors.grey[800],
                child: profilePicUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: Image(
                          image: NetworkImage(profilePicUrl),
                          width: 200,
                          height: 200,
                          fit: BoxFit.fill,
                        ),
                      )
                    : Container(
                        decoration: BoxDecoration(
                            color: Colors.grey[800],
                            borderRadius: BorderRadius.circular(100)),
                        width: 200,
                        height: 200,
                      ),
              ),
            ),
          ),
          SizedBox(
            height: 32,
          ),
          Center(
            child: Text(
              _auth.currentUser!.displayName.toString().toUpperCase(),
              style: TextStyle(
                fontFamily: 'Pacifico',
                fontSize: 40.0,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Center(
            child: Text(
              aboutCurrentUser.toString(),
              style: TextStyle(
                fontFamily: 'Source Sans Pro',
                color: Colors.teal.shade100,
                fontSize: 20.0,
                letterSpacing: 2.5,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            height: 20.0,
            width: 150.0,
            child: Divider(
              color: Colors.grey.shade600,
            ),
          ),
          Card(
              margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 25.0),
              child: ListTile(
                leading: Icon(
                  Icons.phone,
                  color: Colors.grey.shade200,
                ),
                title: Text(
                  '+91 0123 456 789',
                  style: TextStyle(
                    color: Colors.grey.shade100,
                    fontFamily: 'Source Sans Pro',
                    fontSize: 20.0,
                  ),
                ),
              )),
          Card(
              margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 25.0),
              child: ListTile(
                leading: Icon(
                  Icons.email,
                  color: Colors.grey.shade200,
                ),
                title: Text(
                  _auth.currentUser!.email.toString(),
                  style: TextStyle(
                      fontSize: 18.0,
                      color: Colors.grey.shade100,
                      fontFamily: 'Source Sans Pro'),
                ),
              ))
        ],
      ),
    );
  }
}
