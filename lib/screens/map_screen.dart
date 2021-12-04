import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:collection';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';

final _firestore = FirebaseFirestore.instance;
final _auth = FirebaseAuth.instance;
CollectionReference groups = _firestore.collection('Groups');
CollectionReference users = _firestore.collection('users');
Map<String, double> latitudes = <String, double>{};
Map<String, double> longitudes = <String, double>{};

class MapScreen extends StatefulWidget {
  static const String id = 'map_screen';
  MapScreen({this.groupName, this.groupId});
  final String? groupName;
  final String? groupId;

  @override
  _MapScreenState createState() => _MapScreenState();
}

@override
class _MapScreenState extends State<MapScreen> {
  List<dynamic>? _userNames = [];
  late GoogleMapController _mapController;
  Set<Marker> _markers = HashSet<Marker>();
  bool mapToggle = false;
  bool usersToggle = false;
  bool resetToggle = false;
  Location location = Location();
  Map<String, dynamic> isSelected = <String, bool>{};
  var currentUser;
  var currentBearing;
  late StreamSubscription groupStream;
  late StreamSubscription userStream;

  void initState() {
    super.initState();

    print(widget.groupId);
    getCurrentLocation();
    getGroupUser();
    locationStream();
    statusStream();
  }

  getCurrentLocation() async {
    var pos = await location.getLocation();
    print(pos);
  }

  Widget userCard(username, latitude, longitude) {
    print(username);
    print(latitude);
    print(longitude);
    return Padding(
      padding: EdgeInsets.only(left: 3.0, top: 10.0),
      child: InkWell(
        onTap: () {
          setState(() {
            currentUser = username;
            currentBearing = 90.0;
            print('ontap');
            zoomInMarker(username, latitude, longitude);
          });
        },
        child: Material(
          elevation: 4.0,
          borderRadius: BorderRadius.circular(5.0),
          child: Container(
              height: 100.0,
              width: 150.0,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0),
                  color: Colors.white),
              child: Center(
                  child: Text(
                username.toString(),
                style: TextStyle(color: Colors.black, fontSize: 20.0),
              ))),
        ),
      ),
    );
  }

  zoomInMarker(username, latitude, longitude) {
    print('in zoomin');
    print(username);
    print(latitude);
    print(longitude);
    _mapController
        .animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
            target: LatLng(latitude, longitude),
            zoom: 17.0,
            bearing: 90.0,
            tilt: 45.0)))
        .then((val) {
      if (_userNames!.contains(username)) {
        _mapController.hideMarkerInfoWindow(MarkerId(username));
      }
    });
  }

  Future<void> getGroupUser() async {
    await groups
        .where('groupName', isEqualTo: widget.groupName)
        .get()
        .then((querySnapshot) => {
              setState(() {
                querySnapshot.docs.forEach((element) {
                  _userNames = element.get('users');
                  print(_userNames);
                });
              })
            });
    return getUserLocations();
  }

  statusStream() {
    userStream = groups.snapshots().listen((querySnapshot) {
      querySnapshot.docs.forEach((element) {
        if (widget.groupName == element.get('groupName')) {
          _userNames = element.get('users');
          isSelected = element.get('Status');
          if (mounted) {
            setState(() {});
          }
        }
      });
    });
  }

  locationStream() {
    groupStream = users.snapshots().listen((querySnapshot) {
      querySnapshot.docs.forEach((document) {
        if (_userNames!.contains(document.get('userName'))) {
          latitudes.update(
              document.get('userName'), (value) => document.get('latitude'),
              ifAbsent: () => document.get('latitude'));
          longitudes.update(
              document.get('userName'), (value) => document.get('longitude'),
              ifAbsent: () => document.get('longitude'));

          if (mounted) {
            setState(() {});
          }
        }
      });
      if (latitudes[currentUser] != null && longitudes[currentUser] != null) {
        zoomInMarker(
            currentUser, latitudes[currentUser], longitudes[currentUser]);
      }
    });
  }

  Future<void> getUserLocations() async {
    int counter = _userNames!.length;
    _userNames!.forEach((element) async {
      print(counter);
      await users.where('userName', isEqualTo: element).get().then((value) => {
            setState(() {
              value.docs.forEach((elements) {
                latitudes.update(element, (value) => elements.get('latitude'),
                    ifAbsent: () => elements.get('latitude'));
                longitudes.update(element, (value) => elements.get('longitude'),
                    ifAbsent: () => elements.get('longitude'));
              });
            })
          });
      print(latitudes[element]);
      print(element);
      counter--;
      print(counter);
      if (counter == 0) {
        setState(() {
          mapToggle = true;
          usersToggle = true;
        });
      }
      print(mapToggle);
    });
  }

  initMarkers(usernames, latitudes, longitudes) {
    _markers.clear();
    setState(() {
      for (var username in usernames) {
        if (isSelected[username] == true) {
          _markers.add(
            Marker(
              markerId: MarkerId(username),
              position: LatLng(latitudes[username], longitudes[username]),
              onTap: () {
                setState(() {
                  currentUser = username;
                });
              },
              infoWindow: InfoWindow(
                title: username,
                snippet: "${latitudes[username]}, ${longitudes[username]}",
              ),
              // icon: _markerIcon
            ),
          );
        }
      }
    });
    return _markers;
  }

  List<Widget> userCardShow(_userNames) {
    List<Widget> userCards = [];
    for (var member in _userNames) {
      if (isSelected[member]) {
        userCards.add(userCard(member, latitudes[member], longitudes[member]));
      }
    }
    return userCards;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Map')),
      body: SingleChildScrollView(
      child: Stack(
        children: <Widget>[
          Container(
              height: MediaQuery.of(context).size.height - 80.0,
              width: double.infinity,
              child: mapToggle
                  ? GoogleMap(
                      onMapCreated: (controller) {
                        _mapController = controller;
                      },
                      initialCameraPosition: CameraPosition(
                        target: LatLng(
                            latitudes[_auth.currentUser!.displayName]!
                                .toDouble(),
                            longitudes[_auth.currentUser!.displayName]!
                                .toDouble()),
                        zoom: 12,
                      ),
                      markers: initMarkers(_userNames, latitudes, longitudes),
                      myLocationEnabled: true,
                      myLocationButtonEnabled: true,
                    zoomControlsEnabled: true,
                        zoomGesturesEnabled: true,
                        scrollGesturesEnabled: true,
                        rotateGesturesEnabled: true,
                        tiltGesturesEnabled: true,
                        gestureRecognizers:
                            <Factory<OneSequenceGestureRecognizer>>[
                          new Factory<OneSequenceGestureRecognizer>(
                            () => new EagerGestureRecognizer(),
                          ),
                        ].toSet()
                    )
                  : Center(
                      child: Text(
                      'Loading.. Please wait..',
                      style: TextStyle(fontSize: 20.0),
                    ))),
          Positioned(
            child: Container(
              height: 125.0,
              width: MediaQuery.of(context).size.width,
              child: usersToggle
                  ? ListView(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.all(8.0),
                      children: userCardShow(_userNames),
                    )
                  : Container(height: 1.0, width: 1.0),
            ),
          ),
        ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
     _mapController.dispose();

    groupStream.cancel();
    userStream.cancel();
  }
}
