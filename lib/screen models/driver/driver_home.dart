// import 'dart:async';

// import 'package:flutter/material.dart';

// import 'package:geolocator/geolocator.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:permission_handler/permission_handler.dart';

// class DriverMapScreen extends StatefulWidget {
//   const DriverMapScreen({Key? key}) : super(key: key);

//   @override
//   State<DriverMapScreen> createState() => _DriverMapScreenState();
// }

// class _DriverMapScreenState extends State<DriverMapScreen> {
//   // Keeping default longitude and latitude of 30Days Technology Office
//   bool showLoadingSpinnerOnTop = true, showLoadingOverlay = false;
//   double latitude = 28.6894989, longitude = 76.9533923;
//   final Set<Marker> marker = {};
//   GoogleMapController? _googleMapController;
//   StreamSubscription? locationUpdateStream;
//   MapType mapType = MapType.normal;

//   @override
//   void initState() {
//     super.initState();
//     checkGPSStatus();
//   }

//   //-------------------START LOCATION FUNCTIONS---------------------------

//   checkGPSStatus() async {
//     final ph = PermissionHandler();
// final requested = await ph.requestPermissions([
//   PermissionGroup.locationAlways
// ]);

// final alwaysGranted = requested[PermissionGroup.locationAlways] == PermissionStatus.granted;
// final whenInUseGranted = requested[PermissionGroup.locationWhenInUse] == PermissionStatus.granted;
//     var permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         try {
//           ScaffoldMessenger.of(context).clearSnackBars();
//           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//             content: Text(
//               "Location permission is denied",
//               textAlign: TextAlign.center,
//             ),
//             backgroundColor: Colors.red,
//           ));
//         } catch (e) {
//           //
//         }
//         Navigator.pop(context);
//         return;
//       } else if (permission == LocationPermission.deniedForever) {
//         try {
//           ScaffoldMessenger.of(context).clearSnackBars();
//           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//             content: Text(
//               "Goto Settings and give Location Permission",
//               textAlign: TextAlign.center,
//             ),
//             backgroundColor: Colors.red,
//           ));
//         } catch (e) {
//           //
//         }
//         Navigator.pop(context);
//         return;
//       }
//     }
//     var servicestatus = await Geolocator.isLocationServiceEnabled();
//     if (!servicestatus) {
//       try {
//         ScaffoldMessenger.of(context).clearSnackBars();
//         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//           content: Text(
//             "Please Turn On GPS",
//             textAlign: TextAlign.center,
//           ),
//           backgroundColor: Colors.red,
//         ));
//       } catch (e) {
//         //
//       }
//       Navigator.pop(context);
//       return;
//     }
//     getCurrentLocation();
//   }

//   getCurrentLocation() async {
//     while (_googleMapController == null) {/* Wait until map loads */}
//     locationUpdateStream =
//         Geolocator.getPositionStream(desiredAccuracy: LocationAccuracy.high)
//             .listen(updateLocationOnMap);
//     updateLocationOnMap(await Geolocator.getCurrentPosition(
//       desiredAccuracy: LocationAccuracy.high,
//     ));
//   }

//   updateLocationOnMap(Position positon,
//       [bool ignoreLastPosition = false]) async {
//     if (!ignoreLastPosition &&
//         latitude == positon.latitude &&
//         longitude == positon.longitude) return;
//     setState(() {
//       showLoadingSpinnerOnTop = true;
//     });
//     latitude = positon.latitude;
//     longitude = positon.longitude;
//     await _googleMapController?.animateCamera(CameraUpdate.newCameraPosition(
//       CameraPosition(
//         target: LatLng(latitude, longitude),
//         zoom: 18,
//       ),
//     ));
//     setMarkerOnMap();
//   }

//   setMarkerOnMap() => setState(() {
//         marker.clear();
//         marker.add(Marker(
//           markerId: MarkerId("User Location"),
//           infoWindow: const InfoWindow(
//               title: "This Location will be used for attendance"),
//           visible: true,
//           icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
//           position: LatLng(latitude, longitude),
//         ));
//         showLoadingSpinnerOnTop = false;
//       });

//   changeMapType() => setState(() {
//         mapType =
//             mapType == MapType.normal ? MapType.satellite : MapType.normal;
//       });

//   //------------------ END API FUNCTIONS---------------------------

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           Stack(
//             children: [
//               GoogleMap(
//                 // Default Location of 30Days Tech Office
//                 initialCameraPosition: const CameraPosition(
//                   target: LatLng(28.6894989, 76.9533923),
//                   zoom: 18,
//                 ),
//                 mapType: mapType,
//                 markers: marker,
//                 onMapCreated: (controller) => _googleMapController = controller,
//                 mapToolbarEnabled: true,
//                 compassEnabled: true,
//                 myLocationEnabled: true,
//                 myLocationButtonEnabled: false,
//                 zoomControlsEnabled: false,
//               ),
//             ],
//           ),
//           SafeArea(
//             child: SizedBox.expand(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.end,
//                       children: [
//                         MapButton(Icons.arrow_back,
//                             onTap: () => Navigator.pop(context)),
//                         const Spacer(),
//                         if (showLoadingSpinnerOnTop)
//                           Container(
//                             width: 34,
//                             height: 34,
//                             padding: const EdgeInsets.all(4),
//                             margin: const EdgeInsets.all(4),
//                             decoration: const BoxDecoration(
//                                 color: Color(0xff072a99),
//                                 shape: BoxShape.circle),
//                             child: const CircularProgressIndicator(
//                               color: Colors.white,
//                             ),
//                           ),
//                         MapButton(
//                           mapType == MapType.satellite
//                               ? Icons.apartment
//                               : Icons.map,
//                           onTap: changeMapType,
//                         ),
//                         MapButton(
//                           Icons.my_location_sharp,
//                           onTap: () async => updateLocationOnMap(
//                               await Geolocator.getCurrentPosition(
//                                 desiredAccuracy: LocationAccuracy.high,
//                               ),
//                               true),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           if (showLoadingOverlay)
//             const SizedBox.expand(
//               child: Center(
//                 child: CircularProgressIndicator(),
//               ),
//             )
//         ],
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _googleMapController?.dispose();
//     locationUpdateStream?.cancel();
//     super.dispose();
//   }
// }

// class MapButton extends StatelessWidget {
//   const MapButton(this.iconData, {required this.onTap, Key? key})
//       : super(key: key);
//   final IconData iconData;
//   final VoidCallback onTap;
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         margin: const EdgeInsets.all(6),
//         padding: const EdgeInsets.all(4),
//         child: Icon(
//           iconData,
//           size: 30,
//           color: const Color(0xff072a99),
//         ),
//         alignment: Alignment.center,
//         decoration:
//             const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
//       ),
//     );
//   }
// }
