import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eznext/logoutmodel.dart';
import 'package:eznext/services/sharedpreferences_instance.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:app_settings/app_settings.dart';

import '../../app_constants/constants.dart';

class DriverDashboard extends StatefulWidget {
  const DriverDashboard({Key? key}) : super(key: key);

  @override
  State<DriverDashboard> createState() => _DriverDashboardState();
}

class _DriverDashboardState extends State<DriverDashboard> {
  bool trackingLocation = false, showLoading = false;
  final geoLocator = Geolocator();
  StreamSubscription? locationStream;
  Position currentLocation = Position(latitude: 28.7041, longitude: 77.1025);
  GoogleMapController? mapController;
  final List allRoutes = [];
  String routeId = SharedPreferencesInstance.getString("route_id") ?? "",
      routeTitle = SharedPreferencesInstance.getString("route") ?? "";
  bool? locationWhenInUse, locationAlways;
  @override
  void initState() {
    super.initState();
    getAllRoutes();
    getuserconsent();
  }

  getuserconsent() {
    user_consent = SharedPreferencesInstance.instance.getString("user_consent");

    Future.delayed(Duration(seconds: 1), () {
      show_location_consent(context);
    });
  }

  String user_consent = "false";

  show_location_consent(BuildContext context) {
    user_consent = SharedPreferencesInstance.instance.getString("user_consent");

    AlertDialog alert = AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 15),
      title: const Text(
        "Attention",
        style: TextStyle(
            color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 20),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("By continuing to the app, you agree that: ",
              style: TextStyle(
                fontSize: 18,
              )),
          const SizedBox(height: 10),
          RichText(
              textAlign: TextAlign.justify,
              text: const TextSpan(
                  style: TextStyle(fontSize: 18, color: Colors.black),
                  children: [
                    TextSpan(
                        text: "This app collects location data to enable the "),
                    TextSpan(
                        text: '"Bus Tracking Feature" ',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(
                        text: "even when the app is closed or not in use. "),
                    TextSpan(
                        text: "The app tracks your location ",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: "while"),
                    TextSpan(
                      text: " you are on your way to ",
                    ),
                    TextSpan(
                        text: "Pick up or Drop off",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(
                      text: " the students. ",
                    ),
                    TextSpan(
                      text: "To start the location tracking, Click on the ",
                      // style: TextStyle(fontWeight: FontWeight.bold
                      // )
                    ),
                    TextSpan(
                        text: "START ",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.green)),
                    TextSpan(text: "button "),
                    TextSpan(
                      text: " and to stop the location tracking, Click on the ",
                      // style: TextStyle(fontWeight: FontWeight.bold)
                    ),
                    TextSpan(
                        text: " STOP ",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.red)),
                    TextSpan(
                        text: " button or ",
                        // style: TextStyle(fontWeight: FontWeight.bold)
                        ),
                    TextSpan(
                        text: "LOGOUT ",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.blue)),
                    TextSpan(text: "from the app."),
                  ])),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text("Cancel"),
          style: ButtonStyle(
              foregroundColor: MaterialStateProperty.all(Colors.red)),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            user_consent = "true";
            getLocationPermissionStatus();
          },
          child: const Text("Agree & Continue"),
          style: ButtonStyle(
              foregroundColor: MaterialStateProperty.all(Colors.blue)),
        ),
      ],
    );

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  getLocationPermissionStatus() async {
    locationWhenInUse = await geoLocator.checkGeolocationPermissionStatus(
            locationPermission: GeolocationPermission.locationWhenInUse) ==
        GeolocationStatus.granted;
    locationAlways = await geoLocator.checkGeolocationPermissionStatus(
            locationPermission: GeolocationPermission.locationAlways) ==
        GeolocationStatus.granted;
    if (!(locationAlways!)) return askForPermissions();
  }

  askForPermissions() async {
    var permissions1 = await PermissionHandler().requestPermissions([
      PermissionGroup.locationAlways,
      PermissionGroup.locationWhenInUse,
    ]);

    if (permissions1[PermissionGroup.locationAlways] !=
        PermissionStatus.granted) {
      showBackgroundlocationErrorDialog();
    }
  }

  showBackgroundlocationErrorDialog() async {
    await showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: Text("Cannot track background location"),
              content: RichText(
                  text: TextSpan(
                      style: TextStyle(color: Colors.black),
                      text:
                          "To enable background location tracking, goto settings and set location permission to ",
                      children: [
                    TextSpan(
                        text: "allow all the time",
                        style: TextStyle(fontWeight: FontWeight.bold))
                  ])),
              actions: [
                TextButton(
                  onPressed: Navigator.of(context).pop,
                  child: Text("Cancel"),
                  style: ButtonStyle(
                      foregroundColor: MaterialStateProperty.all(Colors.red)),
                ),
                TextButton(
                  onPressed: () async {
                    await AppSettings.openAppSettings();
                    Navigator.pop(context);
                  },
                  child: Text("Open Settings"),
                ),
              ],
            ));
  }

  Future<bool> backgroundServices() async => await FlutterBackground.initialize(
        androidConfig: FlutterBackgroundAndroidConfig(
          notificationTitle: "Location is being tracked",
          notificationImportance: AndroidNotificationImportance.Max,
          notificationText: "Keep Your GPS Enabled",
        ),
      );

  getAllRoutes() async {
    var response = await http.post(
        "https://eznext.eznext.in/api/webservice/getDriverRouteList",
        headers: {
          'Accept': 'application/json',
          'Client-Service': clientservice,
          'Auth-Key': authkey,
          'User-ID': SharedPreferencesInstance.getString("id") ?? "",
          'Authorization': SharedPreferencesInstance.getString("token") ?? "",
        });
    allRoutes.addAll(json.decode(response.body));
  }

  startlocationTracking() async {
    setState(() {
      showLoading = true;
    });
    bool value = await backgroundServices();
    if (value)
      print(
          'FlutterBackground.enableBackgroundExecution(): ${await FlutterBackground.enableBackgroundExecution()}');
    setState(() {
      showLoading = false;
    });
    var position = await geoLocator.getCurrentPosition();
    currentLocation = position;
    await FirebaseFirestore.instance.doc("eznext/$routeId").set({
      "lat": position.latitude,
      "long": position.longitude,
      "route title": routeTitle
    });
    locationStream =
        geoLocator.getPositionStream().listen(updateLocationOnFirebase);
    log("Done");
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        content: Text("Your location is being tracked")));
  }

  stopLocationTracking() async {
    setState(() {});
    await FlutterBackground.disableBackgroundExecution();
    await locationStream?.cancel();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        content: Text("Your location tracking is stopped")));
  }

  updateLocationOnFirebase(Position position) async {
    setState(() {
      currentLocation = position;
    });
    if (!trackingLocation) return;
    mapController?.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        target: LatLng(currentLocation.latitude, currentLocation.longitude),
        zoom: 14,
      ),
    ));
    await FirebaseFirestore.instance.doc("eznext/$routeId").update({
      "lat": position.latitude,
      "long": position.longitude,
    });
  }

  @override
  void dispose() {
    locationStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (trackingLocation)
          GoogleMap(
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            onMapCreated: (_) => mapController = _,
            initialCameraPosition: CameraPosition(
              target:
                  LatLng(currentLocation.latitude, currentLocation.longitude),
              zoom: 14,
            ),
          ),
        Scaffold(
          backgroundColor: Colors.white38,
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(



                                              color: Colors.white.withOpacity(0.8),
                                              borderRadius: BorderRadius.circular(10)

                      ),
                      padding: EdgeInsets.all(10),
                      margin: EdgeInsets.all(10),
                      child: Column(
                        children: [
                          Text(
                            "Your Current Route",
                            style: TextStyle(
                                fontWeight: FontWeight.w300, fontSize: 17),
                          ),
                          SizedBox(height: 10),
                          Text(
                            routeTitle,
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          FlatButton(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            textColor: Colors.white,
                            color: Colors.blue,
                              onPressed: trackingLocation
                                  ? null
                                  : () async {
                                      if (trackingLocation) return;
                                      List data = await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => ChangeRouteScreen(
                                                allRoutes,
                                                routeId,
                                              ),
                                            ),
                                          ) ??
                                          [];
                                      if (data.isEmpty) return;
                                      routeTitle = data[0];
                                      routeId = data[1];
                                      setState(() {});
                                      locationStream?.cancel();
                                    },
                              child: Text("Change Route")),
                          Divider(),
                          showLoading
                              ? CircularProgressIndicator()
                              : InkWell(
                                  onTap: () async {
                                    ScaffoldMessenger.of(context)
                                        .clearSnackBars();
                                    trackingLocation = !trackingLocation;
                                    if (!trackingLocation)
                                      return stopLocationTracking();
                                    if (!(await geoLocator
                                        .isLocationServiceEnabled())) {
                                      setState(() {
                                        trackingLocation = false;
                                      });
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                        content: Text(
                                          "Turn on GPS",
                                          textAlign: TextAlign.center,
                                        ),
                                        backgroundColor: Colors.red,
                                      ));
                                      return;
                                    }
                                    startlocationTracking();
                                  },
                                  child: Container(
                                    height:
                                        MediaQuery.of(context).size.width * 0.2,
                                    width:
                                        MediaQuery.of(context).size.width * 0.2,
                                    alignment: Alignment.center,
                                    child: Text(
                                      trackingLocation ? "STOP" : "START",
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                    decoration: BoxDecoration(
                                      color: trackingLocation
                                          ? Colors.red
                                          : Colors.green,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                          if (trackingLocation)
                            Column(
                              children: [
                                const SizedBox(height: 10),
                                const Text(
                                  "Current Location:",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  "${currentLocation.latitude}°\n${currentLocation.longitude}°",
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              FlatButton(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)
                ),
                
                  onPressed: () async {
                    logOut(context);
                  },
                  child: Text(
                    "Logout",
                    style: TextStyle(color: Colors.red),
                  )
                  ),
            ],
          ),
        ),
      ],
    );
  }
}

class ChangeRouteScreen extends StatelessWidget {
  const ChangeRouteScreen(this.allRoutes, this.currentSelectedId, {Key? key})
      : super(key: key);
  final List allRoutes;
  final String currentSelectedId;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        children: allRoutes.map<Widget>((element) {
          return Card(
            child: ListTile(
              leading: Icon(Icons.directions),
              title: Text(element["route_title"]),
              subtitle: Text("id: " + element["id"]),
              trailing: element["id"] == currentSelectedId
                  ? Icon(
                      Icons.done,
                      color: Colors.green,
                    )
                  : null,
              onTap: () => Navigator.pop(
                  context, [element["route_title"], element["id"]]),
            ),
          );
        }).toList(),
      ),
    );
  }
}
