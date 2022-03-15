import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:fluttertoast/fluttertoast.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MAP TEST',
      home: MapSample(),
    );
  }
}

class MapSample extends StatefulWidget {
  const MapSample({ Key? key }) : super(key: key);

  @override
  _MapSampleState createState() => _MapSampleState();
}

class _MapSampleState extends State<MapSample> {
  Completer<GoogleMapController> _controller = Completer();

  List<Marker> _markers = [];
  List<Polyline> _line = [];
  bool tf = true;

  static final CameraPosition _start = CameraPosition(
    target: LatLng(37.5283169, 126.9296254),
    zoom: 14,
  );

  static final CameraPosition _univ = CameraPosition(
    target: LatLng(36.7697899, 126.9317528),
    zoom: 14
    );

  @override
  void initState() {
    _checkPermission();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: _start,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        markers: _markers.toSet(),
        polylines: _line.toSet(),
        onTap: (pos) {
          addMarks(pos);
        },
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.all(8),
        child: Row(
          children: [
            FloatingActionButton.extended(
              onPressed: _goToUniv,
              label: Text('University'),
              icon: Icon(Icons.school), 
            ),
            SizedBox(
              width: 10,
            ),
            FloatingActionButton.extended(
              onPressed: () async {
                if (_markers.length == 2) {
                  var dis = await Geolocator.distanceBetween(
                    _markers[0].position.latitude,
                    _markers[0].position.longitude,
                    _markers[1].position.latitude,
                    _markers[1].position.longitude,
                  );
                  Fluttertoast.showToast(
                    msg: "${dis.toInt()}M",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    backgroundColor: Colors.grey,
                    textColor: Colors.white,
                    fontSize: 16.0
                  );
                }
              },
              label: Text('Distance'),
              icon: Icon(Icons.fmd_good_outlined),
            )
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Future<void> _goToUniv() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_univ));
  }

  addMarks(pos) {
    setState(() {
      if (tf) {
        _line.clear();
        _markers.add(Marker(position: pos, markerId: MarkerId('1')));
        tf = !tf;
      } else {
        _markers.add(Marker(
            markerId: MarkerId('2'),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueBlue)));
        addLine(_markers[0].position, _markers[1].position);
        tf = !tf;
      }
    });
  }

  addLine(LatLng mark1, LatLng mark2) {
    setState(() {
      _line.add(Polyline(
        polylineId: PolylineId('poly'), points: [mark1, mark2], width: 5));
    });
  }

  _checkPermission() async{
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied, we cannot request permissions.');
    }
  }
}