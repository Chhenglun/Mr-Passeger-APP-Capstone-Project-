import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:scholarar/util/app_constants.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  static const LatLng sourceLocation = LatLng(11.5474, 104.9282);
  static const LatLng destination = LatLng(11.544, 104.9112);

  List<LatLng> polyLineCoordinates = [];
  void getPolyPoint() async{
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        AppConstants.google_key_api,
        PointLatLng(sourceLocation.latitude, sourceLocation.longitude),
        PointLatLng(destination.latitude, destination.longitude),
    );
    if(result.points.isNotEmpty){
      result.points.forEach(
          (PointLatLng point) => polyLineCoordinates.add(
            LatLng(point.latitude, point.longitude),
          )
      );
      setState(() {

      });
    }
  }
  @override
  void initState() {
    super.initState();
    getPolyPoint();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
          initialCameraPosition: CameraPosition(
              target: sourceLocation,
              zoom: 14.5,
          ),
        polylines: {
            Polyline(
              polylineId: PolylineId("route"),
              points: polyLineCoordinates,
              color: Colors.black,
              width: 6,
            )
        },
        markers: {
            Marker(
                markerId: MarkerId("souce"),
                position: sourceLocation,
            ),
          Marker(
            markerId: MarkerId("destination"),
            position: destination,
          ),
        },
      ),

    );
  }
}