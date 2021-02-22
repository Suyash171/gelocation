import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
 // @override
 // _MyAppState createState() => _MyAppState();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Polyline example',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: MapScreen(),
    );
  }
}

class MapScreen extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MapScreen> {
  GoogleMapController mapController;
  BitmapDescriptor pinLocationIcon;
  Position position;
  Widget child;
  Map<MarkerId, Marker> markers = {};
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();

  String googleAPiKey = "AIzaSyCZ_CovFtTiyoUEGMc3azxp-IXG5Sjn7Ro";
  double _originLatitude = 6.5212402, _originLongitude = 3.3679965;
  double _destLatitude = 6.849660, _destLongitude = 3.648190;

  @override
  void initState() {
    //setCustomMapPin();
    //child = RippleIndicator("Getting Loading");
    ////getCurrentLocation();
    super.initState();
    /// origin marker
    _addMarker(LatLng(_originLatitude, _originLongitude), "origin",
        BitmapDescriptor.defaultMarker);
    /// destination marker
    _addMarker(LatLng(_destLatitude, _destLongitude), "destination",
        BitmapDescriptor.defaultMarker);
    _getPolyline();
  }

  void _onMapCreated(GoogleMapController controller) async {
    mapController = controller;
  }

  _addMarker(LatLng position, String id, BitmapDescriptor descriptor) {
    MarkerId markerId = MarkerId(id);
    Marker marker =
    Marker(markerId: markerId, icon: descriptor, position: position);
    markers[markerId] = marker;
  }

  _addPolyLine() {
    PolylineId id = PolylineId("poly");
    Polyline polyline = Polyline(
        polylineId: id, color: Colors.red, points: polylineCoordinates);
    polylines[id] = polyline;
    setState(() {

    });
  }

  _getPolyline() async {
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(googleAPiKey,
        PointLatLng(_originLatitude, _originLongitude),
        PointLatLng(_destLatitude, _destLongitude),
        travelMode: TravelMode.driving,
        wayPoints: [PolylineWayPoint(location: "Test")]
    );

    //if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    //}

    _addPolyLine();
  }

  void getCurrentLocation() async{
    Position res = await Geolocator.getCurrentPosition();
    setState(() {
        position = res;
        child = mapWidget();
    });
  }

  void setCustomMapPin() async {
    pinLocationIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5),
        'images/destination_map_marker.png');
  }

  @override
  Widget build(BuildContext context) {
    // these are the minimum required values to set
    // the camera position
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Maps Sample App'),
          backgroundColor: Colors.green[700],
        ),
        //body: child
        body: GoogleMap(
          initialCameraPosition: CameraPosition(target: LatLng(_originLatitude, _originLongitude), zoom: 12),
          myLocationEnabled: true,
          tiltGesturesEnabled: true,
          compassEnabled: true,
          scrollGesturesEnabled: true,
          zoomGesturesEnabled: true,
          onMapCreated: _onMapCreated,
          markers: Set<Marker>.of(markers.values),
          polylines: Set<Polyline>.of(polylines.values),
        )
      ),
    );
  }

  Widget mapWidget(){
    return GoogleMap(
        mapType: MapType.normal,
        markers: createMarker(),
        initialCameraPosition: CameraPosition(target: LatLng(position.latitude,position.longitude),zoom: 20.0),
        onMapCreated: (GoogleMapController controller){
          mapController = controller;
        },
    );
  }

  Set<Marker> createMarker(){
    return <Marker>[
      Marker(
        markerId: MarkerId("work"),
        position: LatLng(position.latitude,position.longitude),
        icon: BitmapDescriptor.defaultMarker,
        infoWindow: InfoWindow(title: "Work",),
      )
    ].toSet();
  }
}




