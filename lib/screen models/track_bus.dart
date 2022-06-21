import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eznext/services/sharedpreferences_instance.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app_constants/constants.dart';

class BusLocationTracking extends StatefulWidget {
  const BusLocationTracking({Key? key}) : super(key: key);

  @override
  State<BusLocationTracking> createState() => _BusLocationTrackingState();
}

class _BusLocationTrackingState extends State<BusLocationTracking> {
  final String studentId =
      SharedPreferencesInstance.getString("student_id") ?? "";
  bool showLoading = false, showDirections = false;
  double latitude = 28, longitude = 77;
  final Map busData = {};
  get clientservice => null;
  Position userCurrentLocation =
      Position(latitude: 28.7041, longitude: 77.1025);
  final geoLocator = Geolocator();
  final Set<Marker> marker = {};
  final List<LatLng> polylineCoordinates = [];
  StreamSubscription? stream;
  GoogleMapController? mapController;

  @override
  void initState() {
    super.initState();
    getUserLocationPermissionStatus();
    getStudentRoute();
  }

  getUserLocationPermissionStatus() async {
    var status = await geoLocator.checkGeolocationPermissionStatus(
            locationPermission: GeolocationPermission.locationWhenInUse) ==
        GeolocationStatus.granted;
    print('status: $status');
    if (status) return getUserLocation();
    Map permissionStatuses = await PermissionHandler().requestPermissions(
      [
        PermissionGroup.locationWhenInUse,
      ],
    );
    if (permissionStatuses[PermissionGroup.locationWhenInUse] ==
        PermissionStatus.granted) return getUserLocation();
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("please give location permission")));
  }

  getUserLocation() async {
    if (!(await geoLocator.isLocationServiceEnabled())) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please Turn your GPS on")));
    }
    userCurrentLocation = await geoLocator.getCurrentPosition();
    showDirections = true;
  }

  @override
  void dispose() {
    stream?.cancel();
    super.dispose();
  }

  getStudentRoute() async {
    print("came here");
    setState(() => showLoading = true);
    var response = await http.post(
        "https://eznext.eznext.in/api/webservice/gettransportroute",
        headers: {
          'Accept': 'application/json',
          'Client-Service': "smartschool",
          'Auth-Key': authkey,
          'User-ID': SharedPreferencesInstance.getString("id") ?? "",
          'Authorization': SharedPreferencesInstance.getString("token") ?? "",
        },
        body: json.encode({"student_id": studentId}));
    List<dynamic> data = json.decode(response.body);
    log(data.toString());
    for (var i in data) {
      List vehicles = i["vehicles"];
      if (vehicles.length == 0) continue;
      if (vehicles[0]["is_assigned"] != "Yes") continue;
      busData.addAll(i);
      break;
    }
    log(busData.toString());
    startStreamingData();
    setState(() => showLoading = false);
  }

  startStreamingData() async {
    log('busData["id"]: ${busData["id"]}');
    getLiveStatusOfDriver(
        await FirebaseFirestore.instance.doc("eznext/${busData["id"]}").get(),
        true);
    stream = FirebaseFirestore.instance
        .doc("eznext/${busData["id"]}")
        .snapshots()
        .listen(getLiveStatusOfDriver);
  }

  getLiveStatusOfDriver(DocumentSnapshot snapshot,
      [bool centerOnMap = true]) async {
    var data = snapshot.data();
    latitude = data["lat"] ?? 16;
    longitude = data["long"] ?? 77;
    marker.clear();
    marker.add(Marker(
      markerId: MarkerId("bus"),
      position: LatLng(latitude, longitude),
      icon: await BitmapDescriptor.fromAssetImage(
          ImageConfiguration(), "assets/bus.png"),
      infoWindow:
          const InfoWindow(title: "This Location will be used for attendance"),
      visible: true,
    ));
    if (centerOnMap)
      await mapController?.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(latitude, longitude),
          zoom: 20,
        ),
      ));
    setState(() {});
    if (!showDirections) return;
    var result = await PolylinePoints().getRouteBetweenCoordinates(
      "AIzaSyDwfuoSnIKPDe_ANyj5S6JI8hRL2qR_BWg",
      PointLatLng(latitude, longitude),
      PointLatLng(userCurrentLocation.latitude, userCurrentLocation.longitude),
      travelMode: TravelMode.driving,
    );
    log(result.status);
    log(result.errorMessage);
    log(result.points.toString());
    polylineCoordinates.clear();
    if (result.points.isEmpty) {
      setState(() {});
      return;
    }
    List<PointLatLng> points = result.points;
    for (var i in points) {
      polylineCoordinates.add(LatLng(i.latitude, i.longitude));
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition:
                CameraPosition(target: LatLng(latitude, longitude), zoom: 14),
            markers: marker,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            onMapCreated: (_) => mapController = _,
            polylines: polylineCoordinates.isEmpty
                ? null
                : [
                    Polyline(
                        polylineId: PolylineId("id"),
                        color: Colors.red,
                        points: polylineCoordinates)
                  ].toSet(),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () async {
                    Navigator.pop(context);
                  },
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    child: Icon(Icons.arrow_back),
                  ),
                ),
              ),
              Spacer(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () async {
                    launch("tel:${busData["vehicles"][0]["driver_contact"]}");
                    await mapController
                        ?.animateCamera(CameraUpdate.newCameraPosition(
                      CameraPosition(
                        target: LatLng(latitude, longitude),
                        zoom: 14,
                      ),
                    ));
                  },
                  child: Column(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        child: Icon(Icons.phone),
                      ),
                      Container(
                        child: Text("Call"),
                        padding: EdgeInsets.all(2),
                        margin: EdgeInsets.all(2),
                        color: Colors.white,
                      )
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () async {
                    await mapController
                        ?.animateCamera(CameraUpdate.newCameraPosition(
                      CameraPosition(
                        target: LatLng(latitude, longitude),
                        zoom: 14,
                      ),
                    ));
                  },
                  child: CircleAvatar(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black,
                    child: Icon(Icons.bus_alert_rounded),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () async {
                    var position = await Geolocator().getCurrentPosition();
                    await mapController
                        ?.animateCamera(CameraUpdate.newCameraPosition(
                      CameraPosition(
                        target: LatLng(position.latitude, position.longitude),
                        zoom: 14,
                      ),
                    ));
                  },
                  child: CircleAvatar(
                    child: Icon(Icons.my_location),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? mapController;
  double _originLatitude = 26.48424, _originLongitude = 50.04551;
  double _destLatitude = 26.46423, _destLongitude = 50.06358;
  Map<MarkerId, Marker> markers = {};

  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();

  String googleAPiKey = "Please provide your api key";

  _addPolyLine() {
    PolylineId id = PolylineId("poly");
    Polyline polyline = Polyline(
        polylineId: id, color: Colors.red, points: polylineCoordinates);
    polylines[id] = polyline;
    setState(() {});
  }

  _getPolyline() async {
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        googleAPiKey,
        PointLatLng(_originLatitude, _originLongitude),
        PointLatLng(_destLatitude, _destLongitude),
        travelMode: TravelMode.driving,
        wayPoints: [PolylineWayPoint(location: "Sabo, Yaba Lagos Nigeria")]);
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }
    _addPolyLine();
  }

  @override
  void initState() {
    super.initState();

    /// origin marker
    _addMarker(LatLng(_originLatitude, _originLongitude), "origin",
        BitmapDescriptor.defaultMarker);

    /// destination marker
    _addMarker(LatLng(_destLatitude, _destLongitude), "destination",
        BitmapDescriptor.defaultMarkerWithHue(90));
    _getPolyline();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          body: GoogleMap(
        initialCameraPosition: CameraPosition(
            target: LatLng(_originLatitude, _originLongitude), zoom: 15),
        myLocationEnabled: true,
        tiltGesturesEnabled: true,
        compassEnabled: true,
        scrollGesturesEnabled: true,
        zoomGesturesEnabled: true,
        onMapCreated: _onMapCreated,
        markers: Set<Marker>.of(markers.values),
        polylines: Set<Polyline>.of(polylines.values),
      )),
    );
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
}
