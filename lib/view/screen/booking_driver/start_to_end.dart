// import 'dart:async';
// import 'dart:math';
// import 'dart:ui' as ui;
// import 'dart:ui';
// import 'dart:typed_data';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:get/get_core/src/get_main.dart';
// import 'package:image/image.dart' as img;
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_paypal_payment/flutter_paypal_payment.dart';
// import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
// import 'package:flutter_polyline_points/flutter_polyline_points.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:scholarar/util/app_constants.dart';
// import 'package:scholarar/util/next_screen.dart';
// import 'package:scholarar/view/app/app_screen.dart';
// import 'package:scholarar/view/screen/booking/message.dart';
// import 'package:scholarar/view/screen/booking/profile_screen.dart';
// import 'package:scholarar/view/screen/home/booking_driver.dart';
// import 'package:url_launcher/url_launcher.dart';

// class BookingScreen extends StatefulWidget {
//   const BookingScreen({super.key});

//   @override
//   State<BookingScreen> createState() => _BookingScreenState();
// }

// class _BookingScreenState extends State<BookingScreen> {
//   final Completer<GoogleMapController> _controller = Completer();
//   bool toSelected = false;
//   static const LatLng destination = LatLng(11.544, 104.8112);
//   List<LatLng> polyLineCoordinates = [];
//   LatLng currentPosition = destination;
//   LatLng driverPosition = LatLng(11.570, 104.875);
//   StreamSubscription<Position>? positionStreamSubscription;
//   String url = "https://toppng.com/uploads/preview/user-account-management-logo-user-icon-11562867145a56rus2zwu.png";
//   Timer? driverTimer;
//   Uri dialnumber = Uri(scheme: 'tel', path: '012345678');
//   BitmapDescriptor CurrentIcon = BitmapDescriptor.defaultMarker;
//   BitmapDescriptor DestinationIcon = BitmapDescriptor.defaultMarker;

//   Set<Marker> _markers() {
//     return <Marker>[
//       Marker(
//         markerId: MarkerId('current_location'),
//         position: currentPosition,
//         icon: CurrentIcon!,
//       ),
//       Marker(
//         markerId: MarkerId('current_location'),
//         position: destination,
//         icon: DestinationIcon!,
//       ),
//     ].toSet();
//   }
//   void setCurrentIcon() async {
//     final ByteData byteData = await rootBundle.load('assets/icons/user_icon.jpg');
//     final img.Image? image = img.decodeImage(byteData.buffer.asUint8List());

//     // Resize the image
//     final img.Image resizedImage = img.copyResize(image!, width: 120, height: 120);

//     final ui.Codec codec = await ui.instantiateImageCodec(
//       img.encodePng(resizedImage).buffer.asUint8List(),
//     );
//     final ui.FrameInfo frameInfo = await codec.getNextFrame();

//     final ByteData? resizedByteData = await frameInfo.image.toByteData(format: ui.ImageByteFormat.png);
//     final Uint8List? resizedUint8List = resizedByteData?.buffer.asUint8List();

//     final BitmapDescriptor Currenticon = await BitmapDescriptor.fromBytes(resizedUint8List!);
//     setState(() {
//       CurrentIcon = Currenticon;
//     });
//   }
//   void setDestinationIcon() async {
//     final ByteData byteData = await rootBundle.load('assets/icons/driver_pin_map.jpg');
//     final img.Image? image = img.decodeImage(byteData.buffer.asUint8List());

//     // Resize the image
//     final img.Image resizedImage = img.copyResize(image!, width: 100, height: 150);

//     final ui.Codec codec = await ui.instantiateImageCodec(
//       img.encodePng(resizedImage).buffer.asUint8List(),
//     );
//     final ui.FrameInfo frameInfo = await codec.getNextFrame();

//     final ByteData? resizedByteData = await frameInfo.image.toByteData(format: ui.ImageByteFormat.png);
//     final Uint8List? resizedUint8List = resizedByteData?.buffer.asUint8List();

//     final BitmapDescriptor destinationIcon = await BitmapDescriptor.fromBytes(resizedUint8List!);
//     setState(() {
//       DestinationIcon = destinationIcon;
//     });
//   }
//   // void _addCurrentLocationMarker() {
//   //   if (CurrentIcon != null && currentPosition != null) {
//   //     setState(() {
//   //       _markers().add(
//   //         Marker(
//   //           markerId: MarkerId('current_location'),
//   //           position: currentPosition!,
//   //           icon: CurrentIcon!,
//   //         ),
//   //       );
//   //       _markers().add(
//   //         Marker(
//   //           markerId: MarkerId('current_location'),
//   //           position: destination!,
//   //           icon: DestinationIcon!,
//   //         ),
//   //       );
//   //     });
//   //   }
//   // }

//   Future<void> callNumber() async {
//     await launchUrl(dialnumber);
//   }
//   Future<void> directCall() async {
//     await FlutterPhoneDirectCaller.callNumber('012345678');
//   }

//   @override
//   void initState() {
//     setCurrentIcon();
//     setDestinationIcon();
//     super.initState();
//     //_addCurrentLocationMarker();
//     _checkLocationPermissions();
//   }

//   @override
//   void dispose() {
//     positionStreamSubscription?.cancel();
//     driverTimer?.cancel();
//     super.dispose();
//   }

//   void getPolyPoint() async {
//     PolylinePoints polylinePoints = PolylinePoints();

//     // Create a PolylineRequest object with required parameters
//     PolylineRequest request = PolylineRequest(
//       origin: PointLatLng(currentPosition.latitude, currentPosition.longitude),
//       destination: PointLatLng(destination.latitude, destination.longitude),
//       mode: TravelMode.driving, // Set the mode of travel if required
//     );

//     try {
//       // Pass the request object and API key to getRouteBetweenCoordinates
//       PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
//         request: request,
//         googleApiKey: AppConstants.google_key_api,
//       );

//       if (result.points.isNotEmpty) {
//         polyLineCoordinates.clear();
//         result.points.forEach((PointLatLng point) {
//           polyLineCoordinates.add(LatLng(point.latitude, point.longitude));
//         });
//         setState(() {
//           print("=====>>>>>>>Polyline coordinates updated");
//         });
//       } else {
//         print('=====>>>>>>No points found or error in fetching points');
//       }
//     } catch (e) {
//       print('Error occurred: $e');
//     }
//   }

//   void _checkLocationPermissions() async {
//     bool serviceEnabled;
//     LocationPermission permission;

//     serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       //print('=====>>>>>>Location services are disabled.');
//       return;
//     }

//     permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         //print('=====>>>>>>Location permissions are denied');
//         return;
//       }
//     }

//     if (permission == LocationPermission.deniedForever) {
//       // print('=====>>>>>>Location permissions are permanently denied.');
//       return;
//     }

//     getCurrentLocation();
//     listenToPositionStream();
//   }

//   void getCurrentLocation() async {
//     Position position = await Geolocator.getCurrentPosition();
//     setState(() {
//       currentPosition = LatLng(position.latitude, position.longitude);
//       getPolyPoint();
//       _simulateDriverMovement();
//     });
//   }

//   void listenToPositionStream() {
//     positionStreamSubscription =
//         Geolocator.getPositionStream().listen((Position newPosition) {
//       //print('=====>>>>>>New position obtained: ${newPosition.latitude}, ${newPosition.longitude}');
//       setState(() {
//         currentPosition = LatLng(newPosition.latitude, newPosition.longitude);
//         _animateCameraToPosition(newPosition);
//         getPolyPoint();
//       });
//     });
//   }

//   Future<void> _animateCameraToPosition(Position position) async {
//     final GoogleMapController controller = await _controller.future;
//     controller.animateCamera(
//         CameraUpdate.newLatLng(LatLng(position.latitude, position.longitude)));
//   }

//   void _simulateDriverMovement() {
//     const duration = Duration(seconds: 5);
//     driverTimer = Timer.periodic(duration, (timer) {
//       setState(() {
//         double newLat =
//             driverPosition.latitude + (Random().nextDouble() * 0.001 - 0.0005);
//         double newLng =
//             driverPosition.longitude + (Random().nextDouble() * 0.001 - 0.0005);
//         driverPosition = LatLng(newLat, newLng);
//         getPolyPoint();
//       });
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//         backgroundColor: Colors.white,
//         body: currentPosition == destination
//             ? Center(child: CircularProgressIndicator())
//             : Stack(
//                 children: [
//                   GoogleMap(
//                     initialCameraPosition: CameraPosition(
//                       target: currentPosition,
//                       zoom: 14.5,
//                     ),
//                     onMapCreated: (GoogleMapController controller) {
//                       _controller.complete(controller);
//                     },
//                     polylines: {
//                       Polyline(
//                         polylineId: PolylineId("route"),
//                         points: polyLineCoordinates,
//                         color: Colors.green,
//                         width: 6,
//                       ),
//                     },
//                     markers: _markers(),

//                   ),
//                   Positioned(
//                     left: 10,
//                     top: 10,
//                     child: Container(
//                       decoration: BoxDecoration(
//                         color: Colors.red,
//                         shape: BoxShape.circle,
//                       ),
//                       // child: Center(
//                       //   child: IconButton(
//                       //     icon: Icon(Icons.arrow_back_ios),
//                       //     color: Colors.white,
//                       //     onPressed: () {
//                       //       nextScreenReplace(Get.context, AppScreen());
//                       //       //Navigator.pop(context);
//                       //       //nextScreenReplace(context, CurrentLocation());
//                       //     },
//                       //   ),
//                       // ),
//                     ),
//                   ),
//                   Visibility(
//                     visible: currentPosition != destination,
//                     child: Align(
//                       alignment: Alignment.bottomCenter,
//                       child: Container(
//                         height: MediaQuery.of(context).size.height * 3 / 9,
//                         width: MediaQuery.of(context).size.width,
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.only(
//                             topLeft: Radius.circular(20),
//                             topRight: Radius.circular(20),
//                           ),
//                         ),
//                         child: SingleChildScrollView(
//                           scrollDirection: Axis.vertical,
//                           physics: BouncingScrollPhysics(),
//                           child: Padding(
//                             padding:
//                                 const EdgeInsets.symmetric(horizontal: 16.0),
//                             child: Column(
//                               children: [
//                                 Padding(
//                                   padding: const EdgeInsets.only(
//                                       top: 10, bottom: 5, left: 10),
//                                   child: Row(
//                                     mainAxisAlignment: MainAxisAlignment.start,
//                                     children: [
//                                       Text(
//                                         'អ្នកបើកបរនឹងមកដល់ 3 នាទីទៀត',
//                                         style: TextStyle(fontSize: 12),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                                 Divider(),
//                                 Row(
//                                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     GestureDetector(
//                                       onTap: () {
//                                         nextScreen(
//                                             context, DriverProfileScreen());
//                                       },
//                                       child: Row(
//                                         children: [
//                                           Padding(
//                                             padding: const EdgeInsets.fromLTRB(
//                                                 5, 5, 5, 5),
//                                             child: Container(
//                                               width: 60,
//                                               height: 60,
//                                               decoration: BoxDecoration(
//                                                 borderRadius:
//                                                     BorderRadius.circular(50),
//                                                 image: DecorationImage(
//                                                     image: NetworkImage(url)),
//                                               ),
//                                             ),
//                                           ),
//                                           SizedBox(width: 20),
//                                           Column(
//                                             crossAxisAlignment:
//                                                 CrossAxisAlignment.start,
//                                             mainAxisAlignment:
//                                                 MainAxisAlignment.start,
//                                             children: [
//                                               Text(
//                                                 'លាង ម៉េងហាំង',
//                                                 style: TextStyle(
//                                                     fontWeight: FontWeight.bold,
//                                                     fontSize: 20),
//                                               ),
//                                               Row(
//                                                 children: [
//                                                   Text(
//                                                     'កំពុងធ្វើដំណើរ800មែត្រ . . .',
//                                                     style:
//                                                         TextStyle(fontSize: 12),
//                                                   ),
//                                                   Icon(Icons.location_on,
//                                                       color: Colors.red,
//                                                       size: 16),
//                                                 ],
//                                               ),
//                                             ],
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                     Spacer(),
//                                     _buildPayPalButton(context),
//                                   ],
//                                 ),
//                                 Divider(),
//                                 Padding(
//                                   padding: const EdgeInsets.only(
//                                       left: 25, right: 10, top: 5),
//                                   child: Row(
//                                     mainAxisAlignment:
//                                         MainAxisAlignment.spaceBetween,
//                                     children: [
//                                       Text(
//                                         'តម្លៃ 8800 រៀល',
//                                         style: TextStyle(fontSize: 17),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                                 Padding(
//                                   padding: const EdgeInsets.symmetric(
//                                       horizontal: 8, vertical: 20),
//                                   child: Row(
//                                     mainAxisAlignment: MainAxisAlignment.center,
//                                     children: [
//                                       Container(
//                                         decoration: BoxDecoration(
//                                           color: Colors.green,
//                                           shape: BoxShape.circle,
//                                         ),
//                                         child: Stack(
//                                           children: [
//                                             IconButton(
//                                               onPressed: callNumber,
//                                               icon: Icon(
//                                                   CupertinoIcons.phone_fill,
//                                                   color: Colors.white),
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                       SizedBox(width: 16),
//                                       Container(
//                                         decoration: BoxDecoration(
//                                           color: Colors.green,
//                                           shape: BoxShape.circle,
//                                         ),
//                                         child: Stack(
//                                           children: [
//                                             IconButton(
//                                               onPressed: () {
//                                                 nextScreen(
//                                                     context, MessageScreen());
//                                               },
//                                               icon: Icon(
//                                                   CupertinoIcons
//                                                       .chat_bubble_fill,
//                                                   color: Colors.white),
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                       SizedBox(width: 16),
//                                       Container(
//                                         width: Get.width / 2,
//                                         child: ElevatedButton(
//                                           style: ElevatedButton.styleFrom(
//                                             backgroundColor: Colors.red[400],
//                                             padding: EdgeInsets.symmetric(
//                                                 horizontal: 16, vertical: 10),
//                                           ),
//                                           onPressed: () {
//                                             nextScreen(
//                                                 context, BookingDriver());
//                                           },
//                                           child: Text(
//                                             "លុបចោលការកក់",
//                                             style: TextStyle(
//                                                 color: Colors.white,
//                                                 fontSize: 16),
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//       ),
//     );
//   }

//   Widget _buildPayPalButton(BuildContext context) {
//     return Container(
//       alignment: Alignment.centerRight,
//       width: 80,
//       child: ElevatedButton(
//         onPressed: () {
//           _startPayPalPayment(context);
//         },
//         style: ElevatedButton.styleFrom(
//           backgroundColor: Colors.blue,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(10),
//           ),
//           padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
//         ),
//         child: Icon(Icons.payment, color: Colors.white),
//       ),
//     );
//   }

//   void _startPayPalPayment(BuildContext context) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (BuildContext context) => PaypalCheckoutView(
//           sandboxMode: true,
//           clientId:
//               "AapOPdf1LFi5JhFyhTUGqaa2jnaiqLV0F85Ekos2qWrn58vmrn0fqvzBJ7tAgEdB_SdxwiY5k8hYju4X",
//           secretKey:
//               "ECh47QMoxwLC7tFGEy8wH2L3bF6YUy4QBDCyBFWPXfjAZETt165rJ5uSWbvy3fqytb3Mso28BGbZAm5I",
//           transactions: [
//             {
//               "amount": {
//                 "total": '2.00',
//                 "currency": "USD",
//                 "details": {
//                   "subtotal": '2.0',
//                   "shipping": '0',
//                   "shipping_discount": 0,
//                 },
//               },
//               "description": "The payment transaction description.",
//               "item_list": {
//                 "items": [
//                   {
//                     "name": "Item name",
//                     "quantity": 1,
//                     "price": '2.00',
//                     "currency": "USD",
//                   },
//                 ],
//                 "shipping_address": {
//                   "recipient_name": "Bou Taihor",
//                   "line1": "53BT Meanchey",
//                   "line2": "",
//                   "city": "Phnom Penh",
//                   "country_code": "US",
//                   "postal_code": "73301",
//                   "phone": "+00000000",
//                   "state": "Texas",
//                 },
//               },
//             },
//           ],
//           note: "Contact us for any questions on your order.",
//           onSuccess: (Map params) async {
//             print("onSuccess: $params");
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(content: Text('Payment Successful: $params')),
//             );
//           },
//           onError: (error) {
//             print("onError: $error");
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(content: Text('Payment Error: $error')),
//             );
//           },
//           onCancel: (params) {
//             print('cancelled: $params');
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(content: Text('Payment Cancelled')),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }

import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:flutter_paypal_payment/flutter_paypal_payment.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:scholarar/util/app_constants.dart';
import 'package:scholarar/util/app_constants.dart';
import 'package:scholarar/util/color_resources.dart';
import 'package:scholarar/util/next_screen.dart';
import 'package:scholarar/view/app/app_screen.dart';
import 'package:scholarar/view/screen/booking_driver/start_to_end.dart';
import 'package:scholarar/view/screen/booking_driver/message.dart';
import 'package:scholarar/view/screen/booking_driver/profile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_geofire/flutter_geofire.dart';
import '../../../util/app_constants.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  bool toSelected = false;
  late LatLng destination =
      LatLng(latitudePasDir, longitudePasDir); //LatLng(11.544, 104.8112);
  List<LatLng> polyLineCoordinates = [];
  late LatLng driverDestination = LatLng(latitudePas, longitudePas);
  late LatLng currentPosition = destination;
  late LatLng driverPosition = driverDestination;

  StreamSubscription<Position>? positionStreamSubscription;
  String url =
      "https://toppng.com/uploads/preview/user-account-management-logo-user-icon-11562867145a56rus2zwu.png";
  Timer? driverTimer;
  BitmapDescriptor CurrentIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor DestinationIcon = BitmapDescriptor.defaultMarker;

  Set<Marker> _markers() {
    return <Marker>[
      Marker(
        markerId: MarkerId('current_location'),
        position: LatLng(
            latitudePasDir, longitudePasDir), //currentPosition,//currentPosition,
        icon: DestinationIcon!,
      ),
      Marker(
        markerId: MarkerId('destination'),
        position:
            LatLng(latitudePas, longitudePas), //driverPosition,//destination,
        icon: CurrentIcon!,
      ),
    ].toSet();
  }

    Future<void> setCurrentIcon() async {
    final ByteData byteData = await rootBundle.load('assets/icons/user_icon.jpg');
    final img.Image? image = img.decodeImage(byteData.buffer.asUint8List());

    // Resize the image
    final img.Image resizedImage = img.copyResize(image!, width: 120, height: 120);

    final ui.Codec codec = await ui.instantiateImageCodec(
      img.encodePng(resizedImage).buffer.asUint8List(),
    );
    final ui.FrameInfo frameInfo = await codec.getNextFrame();

    final ByteData? resizedByteData = await frameInfo.image.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List? resizedUint8List = resizedByteData?.buffer.asUint8List();

    final BitmapDescriptor Currenticon = await BitmapDescriptor.fromBytes(resizedUint8List!);
    setState(() {
      CurrentIcon = Currenticon;
    });
  }

  Future<void> setDestinationIcon() async {
    final ByteData byteData = await rootBundle.load('assets/icons/driver_pin_map.jpg');
    final img.Image? image = img.decodeImage(byteData.buffer.asUint8List());

    // Resize the image
    final img.Image resizedImage = img.copyResize(image!, width: 100, height: 150);

    final ui.Codec codec = await ui.instantiateImageCodec(
      img.encodePng(resizedImage).buffer.asUint8List(),
    );
    final ui.FrameInfo frameInfo = await codec.getNextFrame();

    final ByteData? resizedByteData = await frameInfo.image.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List? resizedUint8List = resizedByteData?.buffer.asUint8List();

    final BitmapDescriptor destinationIcon = await BitmapDescriptor.fromBytes(resizedUint8List!);
    setState(() {
      DestinationIcon = destinationIcon;
    });
  }

  Future<void> callNumber(String number) async {
    await launchUrl(Uri(scheme: 'tel', path: '$number'));
  }

  Future<void> directCall() async {
    await FlutterPhoneDirectCaller.callNumber('012345678');
  }


  before() async {
    await _checkLocationPermissions();
    await setCurrentIcon();
    await setDestinationIcon();
    //_addCurrentLocationMarker();
  }

  @override
  void initState() {
    setState(() {});
    before();
    super.initState();
  }

  @override
  void dispose() {
    positionStreamSubscription?.cancel();
    driverTimer?.cancel();
    super.dispose();
  }

  void getPolyPoint() async {
    PolylinePoints polylinePoints = PolylinePoints();

    // Create a PolylineRequest object with required parameters
    PolylineRequest request = PolylineRequest(
      origin: PointLatLng(destination.latitude, destination.longitude),
      destination:
          PointLatLng(driverDestination.latitude, driverDestination.longitude),
      mode: TravelMode.driving, // Set the mode of travel if required
    );

    try {
      // Pass the request object and API key to getRouteBetweenCoordinates
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        request: request,
        googleApiKey: AppConstants.google_key_api,
      );

      if (result.points.isNotEmpty) {
        polyLineCoordinates.clear();
        result.points.forEach((PointLatLng point) {
          polyLineCoordinates.add(LatLng(point.latitude, point.longitude));
        });
        setState(() {
          print("=====>>>>>>>Polyline coordinates updated");
        });
      } else {
        print('=====>>>>>>No points found or error in fetching points');
      }
    } catch (e) {
      print('Error occurred: $e');
    }
  }

  Future<void> _checkLocationPermissions() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      //print('=====>>>>>>Location services are disabled.');
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        //print('=====>>>>>>Location permissions are denied');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // print('=====>>>>>>Location permissions are permanently denied.');
      return;
    }

    //getCurrentLocation();
    listenToPositionStream();
  }

  // void getCurrentLocation() async {
  //   Position position = await Geolocator.getCurrentPosition();
  //   setState(() {
  //     currentPosition = LatLng(position.latitude, position.longitude);
  //     getPolyPoint();
  //     _simulateDriverMovement();
  //   });
  // }

  void listenToPositionStream() {
    positionStreamSubscription =
        Geolocator.getPositionStream().listen((Position newPosition) {
      //print('=====>>>>>>New position obtained: ${newPosition.latitude}, ${newPosition.longitude}');
      setState(() {
        currentPosition = LatLng(newPosition.latitude, newPosition.longitude);
        _animateCameraToPosition(newPosition);
        getPolyPoint();
      });
    });
  }

  Future<void> _animateCameraToPosition(Position position) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(
        CameraUpdate.newLatLng(LatLng(position.latitude, position.longitude)));
  }

  void _simulateDriverMovement() {
    const duration = Duration(seconds: 5);
    driverTimer = Timer.periodic(duration, (timer) {
      setState(() {
        double newLat =
            driverPosition.latitude + (Random().nextDouble() * 0.001 - 0.0005);
        double newLng =
            driverPosition.longitude + (Random().nextDouble() * 0.001 - 0.0005);
        driverPosition = LatLng(newLat, newLng);
        getPolyPoint();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body:  Stack(
                children: [
                  GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: currentPosition,
                      zoom: 14.5,
                    ),
                    onMapCreated: (GoogleMapController controller) {
                      _controller.complete(controller);
                    },
                    polylines: {
                      Polyline(
                        polylineId: PolylineId("route"),
                        points: polyLineCoordinates,
                        color: Colors.green,
                        width: 6,
                      ),
                    },
                    markers: _markers(),
                  ),
                  Positioned(
                    left: 10,
                    top: 10,
                    child: Container(
                      padding: EdgeInsets.only(left: 10),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: IconButton(
                          icon: Icon(Icons.arrow_back_ios),
                          color: Colors.white,
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: currentPosition != destination,
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        height: MediaQuery.of(context).size.height * 3 / 9,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                        ),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          physics: BouncingScrollPhysics(),
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Column(
                              children: [
                                SizedBox(height: 10,),
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        nextScreen(
                                            context, DriverProfileScreen());
                                      },
                                      child: Row(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                10, 5, 5, 5),
                                            child: Container(
                                              width: 70,
                                              height: 70,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(50),
                                                image: DecorationImage(
                                                    image: NetworkImage(url)),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 20),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Text(
                                                getDriverTrip.isNotEmpty
                                                    ? '${getDriverTrip['driver_id']['first_name']} ${getDriverTrip['driver_id']['last_name']}'
                                                    : "Driver",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 20),
                                              ),
                                              Row(
                                                children: [
                                                  Text(
                                                    'កំពុងធ្វើដំណើរ . . .',
                                                    style:
                                                        TextStyle(fontSize: 12),
                                                  ),
                                                  Icon(Icons.location_on,
                                                      color: Colors.red,
                                                      size: 16),
                                                ],
                                              ),
                                            ],
                                          ),
                                           _buildPayPalButton(context)
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                Divider(),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 25, right: 10, top: 5),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'តម្លៃ ${getDriverTrip['cost']} រៀល',
                                        style: TextStyle(fontSize: 17),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 20),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              color: Colors.green,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Stack(
                                              children: [
                                                IconButton(
                                                  onPressed: () {
                                                    callNumber(
                                                        "${getDriverTrip['driver_id']['phone_number']}");
                                                  },
                                                  icon: Icon(
                                                      CupertinoIcons.phone_fill,
                                                      color: Colors.white),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(width: 10),
                                          Container(
                                            decoration: BoxDecoration(
                                              color: Colors.green,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Stack(
                                              children: [
                                                IconButton(
                                                  onPressed: () {
                                                    nextScreen(context,
                                                        MessageScreen());
                                                  },
                                                  icon: Icon(
                                                      CupertinoIcons
                                                          .chat_bubble_fill,
                                                      color: Colors.white),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(width: 10),
                                      Container(
                                        width: Get.width / 2,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red[400],
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 10),
                                          ),
                                          onPressed: () {
                                            _showAlertDialog();
                                          },
                                          child: Text(
                                            "រាយការណ៍សុវត្ថិភាព",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  void _showAlertDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("បញ្ជាក់"),
          content: Text(
            "តេីអ្នកពិតជាចង់លុបចោលការកក់មែនទេ?",
            style: TextStyle(color: ColorResources.blackColor, fontSize: 16),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: ColorResources.greyColor),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'បោះបង់',
                style:
                    TextStyle(color: ColorResources.blackColor, fontSize: 14),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: ColorResources.redColor),
              onPressed: () {
                nextScreen(context, AppScreen());
              },
              child: Text(
                'យល់ព្រម',
                style:
                    TextStyle(color: ColorResources.whiteColor, fontSize: 14),
              ),
            ),
          ],
        );
      },
    );
  }

    Widget _buildPayPalButton(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      width: 80,
      child: ElevatedButton(
        onPressed: () {
          _startPayPalPayment(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
        child: Icon(Icons.payment, color: Colors.white),
      ),
    );
  }

    void _startPayPalPayment(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => PaypalCheckoutView(
          sandboxMode: true,
          clientId:
              "AapOPdf1LFi5JhFyhTUGqaa2jnaiqLV0F85Ekos2qWrn58vmrn0fqvzBJ7tAgEdB_SdxwiY5k8hYju4X",
          secretKey:
              "ECh47QMoxwLC7tFGEy8wH2L3bF6YUy4QBDCyBFWPXfjAZETt165rJ5uSWbvy3fqytb3Mso28BGbZAm5I",
          transactions: [
            {
              "amount": {
                "total": '2.00',
                "currency": "USD",
                "details": {
                  "subtotal": '2.0',
                  "shipping": '0',
                  "shipping_discount": 0,
                },
              },
              "description": "The payment transaction description.",
              "item_list": {
                "items": [
                  {
                    "name": "Item name",
                    "quantity": 1,
                    "price": '2.00',
                    "currency": "USD",
                  },
                ],
                "shipping_address": {
                  "recipient_name": "Bou Taihor",
                  "line1": "53BT Meanchey",
                  "line2": "",
                  "city": "Phnom Penh",
                  "country_code": "US",
                  "postal_code": "73301",
                  "phone": "+00000000",
                  "state": "Texas",
                },
              },
            },
          ],
          note: "Contact us for any questions on your order.",
          onSuccess: (Map params) async {
            print("onSuccess: $params");
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Payment Successful: $params')),
            );
          },
          onError: (error) {
            print("onError: $error");
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Payment Error: $error')),
            );
          },
          onCancel: (params) {
            print('cancelled: $params');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Payment Cancelled')),
            );
          },
        ),
      ),
    );
  }
}