import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'Constants.dart';
import 'package:location_permissions/location_permissions.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GOogleMaps',
      home: Scaffold(
        body: yourApp(),
      ),
    );
  }

  void choiceAction(String value) {
    switch (value) {
      case 'pune':
    }
  }
}

class yourApp extends StatefulWidget {
  @override
  _StatefulState createState() => _StatefulState();
}

class _StatefulState extends State<yourApp> {
  List<Marker> markers = [];
  BitmapDescriptor pinLocationIcon;
  Position currentLocation;
  GoogleMapController googleMapController;
  final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;

  @override
  void initState() {
    super.initState();
    addMarker();
    BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: 2.5),
            'assets/1_qvmBfugDqSF1lmv5fD62aQ.png')
        .then((onValue) {
      pinLocationIcon = onValue;
    });

    getPermission();
    getCurrentLocation();
  }

  static LatLng _center = LatLng(28.7041, 77.1025);

  @override
  Widget build(BuildContext context) {
    print('centre $markers');

    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          PopupMenuButton<String>(
            icon: Icon(
              Icons.home,
            ),
            onSelected: choiceAction,
            itemBuilder: (BuildContext context) {
              return Constants.choices.map(
                (String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice),
                  );
                },
              ).toList();
            },
          ),
        ],
        title: Text('HOme screen'),
      ),
      body: Stack(
        children: <Widget>[
          GoogleMap(
            myLocationEnabled: true,
            onMapCreated: (GoogleMapController mapController) {
              googleMapController = mapController;
            },
            initialCameraPosition: CameraPosition(
              target: _center,
              zoom: 15.0,
            ),
            markers: !(markers.isEmpty) ? markers.toSet() : null,
          ),
          FloatingActionButton(onPressed: () {
            getCity('Pune');
          }),
        ],
      ),
    );
  }

  getCurrentLocation() async {
    currentLocation = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
      setState(() {
        currentLocation = position;
//        final MarkerId markerId = MarkerId('2');
//        final Marker marker = Marker(
//          position: LatLng(currentLocation.latitude, currentLocation.longitude),
//        );
//        markers[markerId] = marker;

        markers.add(
          Marker(
            icon: pinLocationIcon,
            markerId: MarkerId('current_position'),
            infoWindow: InfoWindow(
              title: 'This is current location',
            ),
            position:
                LatLng(currentLocation.latitude, currentLocation.longitude),
          ),
        );
        _center = LatLng(currentLocation.latitude, currentLocation.longitude);
        googleMapController
            .animateCamera(CameraUpdate.newLatLngZoom(_center, 15));
      });
    }).catchError((e) {
      print(e);
    });

    print('centre $_center');
  }

  void getPermission() async {
    PermissionStatus permission =
        await LocationPermissions().checkPermissionStatus();
    print('permission $permission');
    if (permission != null) {
      print('hello');
    }
  }

  void getCity(String city) async {
    currentLocation = await Geolocator()
        .placemarkFromAddress('$city')
        .then((List<Placemark> myList) {
      setState(() {
        Placemark newPlace = myList.first;
        currentLocation = newPlace.position;

        markers.add(Marker(
          markerId: MarkerId('City'),
          position: LatLng(currentLocation.latitude, currentLocation.longitude),
        ));
//        markers[markerId] = marker;

        _center = LatLng(currentLocation.latitude, currentLocation.longitude);
        googleMapController
            .animateCamera(CameraUpdate.newLatLngZoom(_center, 15));
      });
    }).catchError((e) {
      print(e);
    });
  }

  void addMarker() {
    print("Inside add marker method");
    setState(() {
      markers.add((Marker(
          markerId: MarkerId('City'), position: LatLng(28.7041, 77.1025))));
    });
  }

  void choiceAction(String value) {
    switch (value) {
      case Constants.pune:
        getCity('Pune');
        break;
      case Constants.mumbai:
        getCity('Mumbai');
        break;
      case Constants.nashik:
        getCity('Nashik');
        break;
      case Constants.banglore:
        getCity('Banglore');
        break;
      case Constants.satara:
        getCity('Satara');
        break;
    }
  }
}
