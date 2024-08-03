// ignore_for_file: prefer_const_constructors

import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;
import 'dart:ui';
import 'dart:typed_data';
import 'package:flutter/rendering.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:scholarar/controller/auth_controller.dart';
import 'package:scholarar/util/app_constants.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:scholarar/util/next_screen.dart';
import 'package:scholarar/view/screen/account/sing_in_account_screen.dart';
import 'package:scholarar/view/screen/booking/booking_screen.dart';
import 'package:curved_drawer_fork/curved_drawer_fork.dart';
import 'package:scholarar/view/screen/profile/settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:scholarar/controller/auth_controller.dart';

class BookingDriver extends StatefulWidget {
  const BookingDriver({super.key});

  @override
  State<BookingDriver> createState() => _BookingDriverState();
}

class _BookingDriverState extends State<BookingDriver> {
  SharedPreferences? sharedPreferences;
  AuthController authController = Get.find<AuthController>();
  bool fromSelected = false;
  bool toSelected = false;
  bool isLoading = false;
  bool stopWaiting = false;
  late GoogleMapController googleMapController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyEachFrom = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyEachTo = GlobalKey<FormState>();
  TextEditingController _searchController = TextEditingController();
  TextEditingController _searchFromController =
      TextEditingController(text: selectedFromAddress);
  TextEditingController _searchToController =
      TextEditingController(text: selectedToAddress);
  //BitmapDescriptor SourceIcon = BitmapDescriptor.defaultMarker;
  //BitmapDescriptor DestinationIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor CurrentLocationIcon = BitmapDescriptor.defaultMarker;

  // If not yet login
  TextEditingController _usernameController = TextEditingController(text: "${newUserInfo?['userDetails']['first_name']} ${newUserInfo['userDetails']['last_name']}");
  TextEditingController _phoneNumberController = TextEditingController(text: "${newUserInfo?['userDetails']['phone_number']}");
  final _formInfoKey = GlobalKey<FormState>();


  static const CameraPosition initialCameraPosition = CameraPosition(
    target: LatLng(11.672144885466007, 105.0565917044878),
    zoom: 15,
  );

   Set<Marker> _markers() {
     return <Marker>[
       Marker(
         markerId: MarkerId('current_location'),
         position: selectedLatLng!,
         icon: CurrentLocationIcon!,
       ),
     ].toSet();
   }
  LatLng selectedLatLng = LatLng(0, 0);


  Future<Position> _getGeoLocationPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      await Geolocator.openLocationSettings();
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  void searchLocation() async {
    try {
      List<Location> locations =
          await locationFromAddress(_searchController.text);
      if (locations.isNotEmpty) {
        LatLng searchedLatLng =
            LatLng(locations[0].latitude, locations[0].longitude);

        _markers().clear();
        _markers().add(Marker(
          markerId: MarkerId('searchedLocation'),
          position: searchedLatLng,
        ));

        googleMapController
            .animateCamera(CameraUpdate.newLatLng(searchedLatLng));

        setState(() {
          selectedLatLng = searchedLatLng;
          if (fromSelected == false) {
            getAddressFromLatLng(searchedLatLng);
          } else {
            getAddressToLatLng(searchedLatLng);
          }
        });
      }
    } catch (e) {
      //print('Error: $e');
    }
  }

  // void setCustomerMarkerIcon() async{
  //   //BitmapDescriptor.fromAssetImage(ImageConfiguration.empty, "assets/images/user.jpg").then((icon){SourceIcon = icon;});
  //   //BitmapDescriptor.fromAssetImage(ImageConfiguration.empty, "assets/images/human.jpg").then((icon){DestinationIcon = icon;});
  //   BitmapDescriptor.fromAssetImage(ImageConfiguration(size: ui.Size(2, 2)), "assets/icons/user_icon.jpg").then((icon){setState(() {
  //     CurrentLocationIcon = icon;
  //   });});
  // }
  void setCustomerMarkerIcon() async {
    final ByteData byteData = await rootBundle.load('assets/icons/user_icon.jpg');
    final img.Image? image = img.decodeImage(byteData.buffer.asUint8List());

    // Resize the image
    final img.Image resizedImage = img.copyResize(image!, width: 150, height: 170);

    final ui.Codec codec = await ui.instantiateImageCodec(
      img.encodePng(resizedImage).buffer.asUint8List(),
    );
    final ui.FrameInfo frameInfo = await codec.getNextFrame();

    final ByteData? resizedByteData = await frameInfo.image.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List? resizedUint8List = resizedByteData?.buffer.asUint8List();

    final BitmapDescriptor icon = await BitmapDescriptor.fromBytes(resizedUint8List!);
    setState(() {
      CurrentLocationIcon = icon;
    });
  }

  Future<void> getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    LatLng currentLatLng = LatLng(position.latitude, position.longitude);

    _markers().clear();
    _markers().add(Marker(
      markerId: MarkerId('currentLocation'),
      position: currentLatLng,
    ));

    googleMapController.animateCamera(CameraUpdate.newLatLng(currentLatLng));
    setState(() {
      selectedLatLng = currentLatLng;
      if (fromSelected == false) {
        getAddressFromLatLng(currentLatLng);
      } else {
        getAddressToLatLng(currentLatLng);
      }
    });
  }

  void getAddressFromLatLng(LatLng latLng) async {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(latLng.latitude, latLng.longitude);
    Placemark place = placemarks[0];
    setState(() {
      selectedFromAddress =
          "${place.name}, ${place.thoroughfare}, ${place.subLocality}, ${place.locality}";
      _searchFromController.text = selectedFromAddress;
    });
  }

  void getAddressToLatLng(LatLng latLng) async {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(latLng.latitude, latLng.longitude);
    Placemark place = placemarks[0];
    setState(() {
      selectedToAddress =
          "${place.name}, ${place.thoroughfare}, ${place.subLocality}, ${place.locality}";
      _searchToController.text = selectedToAddress;
    });
  }

  Future<void> before() async {
    await _getGeoLocationPosition();
    await getCurrentLocation();
    setState(() {});
  }

  final PageController _pageController = PageController();

  int _counter = 180;
  late Timer _timer;

  Future<void> postData() async {
    setState(() {
      isLoading = true;
    });
    final String url =
        'http://ec2-54-82-25-173.compute-1.amazonaws.com:8000/api/trips/createTrip';

    final Map<String, dynamic> data = {
      "passenger_id": authController.userPassengerMap?['userDetails']['_id'],
      "start_location": [longCur, latCur],
      "end_location": [longDir, latDir]
    };

    final response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 201) {
      setState(() {
        isLoading = false;
        isWaiting = true;
      });
      print('Data posted successfully');
      if (isWaiting == true) {
        _timer = Timer.periodic(Duration(seconds: 1), (timer) {
          setState(() {
            if (_counter > 0) {
              _counter--;
            } else {
              _timer.cancel();
              setState(() {
                stopWaiting = true;
              });
            }
          });
        });
      } else {
        setState(() {
          driAccept = true;
        });
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => BookingScreen()),
        );
      }
    } else {
      setState(() {
        isLoading = false;
      });
      print('response.statusCode ${response.statusCode}');
      print('Failed to post data');
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose(); // Ensure dispose method calls the super class dispose
  }

  Future<void> init() async {
    sharedPreferences = await SharedPreferences.getInstance();
    authController.getPassengerInfoController();
    print("User Details: ${authController.userPassengerMap}");
  }

  @override
  void initState() {
    before();
    setCustomerMarkerIcon();
    super.initState();
    _addCurrentLocationMarker();
    init();
  }
  void _addCurrentLocationMarker() {
    if (CurrentLocationIcon != null && selectedLatLng != null) {
      setState(() {
        _markers().add(
          Marker(
            markerId: MarkerId('current_location'),
            position: selectedLatLng!,
            icon: CurrentLocationIcon!,
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                      GoogleMap(
                      initialCameraPosition: initialCameraPosition,
                      markers:   _markers(),
                      zoomControlsEnabled: false,
                      mapType: MapType.normal,
                      onMapCreated: (GoogleMapController controller) {
                        googleMapController = controller;
                        print('Map created');
                      },
                      onTap: toSelected == false
                          ? (LatLng latLng) {
                        // print('Map tapped at: $latLng');
                       ;
                        _markers().clear();
                        _addCurrentLocationMarker();
                        // _markers.add(Marker(
                        //   markerId: MarkerId('selectedLocation'),
                        //   icon: CurrentLocationIcon,
                        //   position: latLng,
                        // ));


                        setState(() {
                          selectedLatLng = latLng;
                          if (fromSelected == false) {
                            getAddressFromLatLng(latLng);
                          } else {
                            getAddressToLatLng(latLng);
                          }
                        });
                      }

                          : null,

                    ),
                    Positioned(
                          top: 10,
                          left: 16,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: Container(
                                  alignment: Alignment.center,
                                  margin: EdgeInsets.only(left: 10),
                                  child: IconButton(
                                    icon: Icon(Icons.arrow_back_ios),
                                    color: Colors.white,
                                    onPressed: () {
                                      Navigator.pop(context);
                                      String token = sharedPreferences!
                                          .getString(AppConstants.token) ??
                                          "";
                                      // if (token.isNotEmpty) {
                                      //   print("First Check Token $token");
                                      //   nextScreen(context, SettingScreen());
                                      // } else {
                                      //   print("Logout Token: $token");
                                      //   nextScreen(
                                      //       context, SignInAccountScreen());
                                      // }
                                    },
                                  ),
                                ),
                              ),
                              SizedBox(
                                  width: MediaQuery.sizeOf(context).width *
                                      1 /
                                      24),
                              toSelected == false
                                  ? Container(
                                      width: MediaQuery.sizeOf(context).width *
                                          17 /
                                          24,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(25),
                                        border: Border.all(
                                            color: Colors.white, width: 2),
                                      ),
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(right: 6),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            IconButton(
                                              color: Colors.black,
                                              icon: Icon(
                                                Icons.search,
                                              ),
                                              onPressed: () {
                                                searchLocation();
                                              },
                                            ),
                                            SizedBox(
                                              width: MediaQuery.sizeOf(context)
                                                      .width *
                                                  0.5 /
                                                  24,
                                            ),
                                            Expanded(
                                              child: TextField(
                                                controller: _searchController,
                                                decoration: InputDecoration(
                                                  hintText: "ស្វែងរកទីតាំង...",
                                                  hintStyle: TextStyle(
                                                      color: Colors.grey),
                                                  border: InputBorder.none,
                                                ),
                                                onSubmitted: (query) =>
                                                    searchLocation(),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  : Container(
                                margin: EdgeInsets.only(right: 10),
                                    child: ElevatedButton(
                                        style: ButtonStyle(
                                            backgroundColor:
                                                WidgetStatePropertyAll(
                                                    Colors.white)),
                                        onPressed: () {
                                          setState(() {
                                            selectedFromAddress = '';
                                            selectedToAddress = '';
                                            // latCur;
                                            // longCur;
                                            // latDir;
                                            // longDir;
                                          });
                                          nextScreenReplace(
                                              Get.context, BookingDriver());
                                        },
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.cancel,
                                              color: Colors.red,
                                            ),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            Text(
                                              'លុបចោលទីតាំងដែលបានជ្រេីសរេីស',
                                              style: TextStyle(color: Colors.red),
                                            ),
                                          ],
                                        )),
                                  )
                            ],
                          ),
                        ),
                        toSelected == false
                            ? Positioned(
                                bottom: 65,
                                right: 10,
                                child: FloatingActionButton(
                                  onPressed: () async {
                                    await getCurrentLocation();
                                  },
                                  child: Icon(Icons.my_location),
                                ),
                              )
                            : Container()
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(5, 5, 10, 5),
                    child: Expanded(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            SizedBox(height: 5),
                            Row(
                              children: [
                                Container(
                                  width:
                                      Get.width / 5,
                                  child: Text(
                                    'ចាប់ផ្តេីមពី',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                        //border: Border.all(color: Colors.grey.shade50),
                                        borderRadius: BorderRadius.circular(16),
                                        color: Colors.grey.shade500),
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 5),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 5, right: 5),
                                              child: Form(
                                                key: _formKeyEachFrom,
                                                child: TextFormField(
                                                  controller:
                                                      _searchFromController,
                                                  style: TextStyle(color: Colors.white),
                                                  validator: (un_value) {
                                                    if (un_value == null ||
                                                        un_value.isEmpty) {
                                                      return 'សូមជ្រេីសរេីសទីតំាងចាប់ផ្តេីម';
                                                    }
                                                    return null;
                                                  },
                                                  maxLines: null,
                                                  enabled: false,
                                                  decoration: InputDecoration(
                                                    hintText: fromSelected ==
                                                            false
                                                        ? 'ទីតំាងចាប់ផ្តេីម'
                                                        : 'ទីតំាងដែលបានជ្រេីសរេីស',
                                                    border: InputBorder.none,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                fromSelected == false
                                    ? TextButton(
                                        onPressed: () {
                                          setState(() {
                                            if (_formKeyEachFrom.currentState
                                                    ?.validate() ??
                                                false) {
                                              fromSelected = true;
                                              latCur = selectedLatLng.latitude;
                                              longCur =
                                                  selectedLatLng.longitude;
                                              print('latCur ${latCur}');
                                              print('longCur ${longCur}');
                                            }
                                          });
                                        },
                                        child: Text('OK', style: TextStyle(color: Colors.red)),
                                      )
                                    : Container(),
                              ],
                            ),
                            SizedBox(height: 5),
                            Row(
                              children: [
                                Container(
                                  width: Get.width / 5,
                                  child: Text(
                                    'គោលដៅ',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                        //border: Border.all(color: Colors.grey.shade50),
                                        borderRadius: BorderRadius.circular(20),
                                        color: Colors.grey.shade500),
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 5, right: 5),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 5),
                                              child: Form(
                                                key: _formKeyEachTo,
                                                child: TextFormField(
                                                  controller:
                                                      _searchToController,
                                                  style: TextStyle(color: Colors.white),
                                                  validator: (un_value) {
                                                    if (un_value == null ||
                                                        un_value.isEmpty) {
                                                      return 'សូមជ្រេីសរេីសទីតាំងគោលដៅ';
                                                    }
                                                    return null;
                                                  },
                                                  enabled: false,
                                                  maxLines: null,
                                                  decoration: InputDecoration(
                                                    hintText: toSelected ==
                                                            false
                                                        ? 'ទីតំាងគោលដៅ'
                                                        : 'គោលដៅដែលបានជ្រេីសរេីស',
                                                    border: InputBorder.none,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                toSelected == false
                                    ? TextButton(
                                        onPressed: () {
                                          setState(() {
                                            if (_formKeyEachTo.currentState
                                                    ?.validate() ??
                                                false) {
                                              toSelected = true;
                                            }
                                          });
                                        },
                                        child: Text('OK',
                                            style:
                                                TextStyle(color: Colors.red)),
                                      )
                                    : Container(),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (isLoading == true)
                Container(
                  color: Colors.white.withOpacity(0.8),
                  child: Center(child: CircularProgressIndicator()),
                ),
              if (isWaiting == true &&
                  stopWaiting == false &&
                  driAccept == false)
                Center(
                  child: Container(
                    width: MediaQuery.sizeOf(context).width * 1 / 1,
                    color: Colors.white.withOpacity(0.8),
                    child: Column(children: [
                      SizedBox(
                        height: MediaQuery.sizeOf(context).height * 2 / 15,
                      ),
                      Stack(
                        children: [
                          Container(
                            width: 220,
                            height: 220,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black12,
                            ),
                            child: CircularProgressIndicator(
                              value: (_counter / 10),
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.red),
                              strokeWidth: 5,
                            ),
                          ),
                          Positioned(
                            left: 80,
                            top: 100,
                            child: Text(
                              '$_counter វិនាទី',
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: MediaQuery.sizeOf(context).height * 1 / 30,
                      ),
                      Text('សូមរង់ចាំការឆ្លើយតបពីអ្នកបើកបរ'),
                      SizedBox(
              height: MediaQuery.sizeOf(context).height * 1 / 15,
            ),
            // ElevatedButton(
            //                     style: const ButtonStyle(
            //                       backgroundColor:
            //                           MaterialStatePropertyAll(Colors.red),
            //                     ),
            //                     onPressed: () {
            //                       setState(() {
            //                         stopWaiting = true;
            //                       });
            //                       //Navigator.pop(context);
            //                     },
            //                     child: Padding(
            //                       padding: const EdgeInsets.all(15.0),
            //                       child: Text(
            //                         'លុបចោលការកក់',
            //                         style: TextStyle(color: Colors.white),
            //                       ),
            //                     )),
                    ]),
                  ),
                ),
            ],
          ),
        ),
        bottomNavigationBar: isLoading == true || isWaiting == true &&
                  stopWaiting == false &&
                  driAccept == false
              ? null
        //   ? Container(
        //   padding: EdgeInsets.fromLTRB(10, 0, 10, 5),
        //   width: MediaQuery.sizeOf(context).width * 12 / 12,
        //   child: Padding(
        //     padding: const EdgeInsets.all(3.0),
        //     child: ElevatedButton(
        //       onPressed: (){},
        //       style: const ButtonStyle(
        //           backgroundColor: MaterialStatePropertyAll(Colors.grey),
        //         ),
        //         child: Text(
        //           'បញ្ជាក់ការកក់',
        //           style: TextStyle(
        //               color: Colors.white,
        //               fontSize: 16,
        //               fontWeight: FontWeight.bold),
        //         )
        //     ),
        //   ),
        // )
        : Container(
          padding: EdgeInsets.fromLTRB(10, 0, 10, 5),
          width: MediaQuery.sizeOf(context).width * 12 / 12,
          child: Padding(
            padding: const EdgeInsets.all(3.0),
            child: ElevatedButton(
                onPressed: () async {
                  String token =
                      sharedPreferences!.getString(AppConstants.token) ?? "";
                  //         if (token.isNotEmpty) {
                  //           print("First Check Token $token");
                  //           nextScreen(context, SettingScreen());
                  //         } else {
                  //           print("Logout Token: $token");
                  //           nextScreen(context, SignInAccountScreen());
                  //         }
                  if (token.isNotEmpty) {
                    setState(() {
                      latDir = selectedLatLng.latitude;
                      longDir = selectedLatLng.longitude;
                      // print(latDir);
                      // print(longDir);
                      isLoading = true;
                    });
                    await Future.delayed(Duration(seconds: 3), () {
                      setState(() {
                        isLoading = false;
                      });
                    });
                    if (_formKeyEachFrom.currentState!.validate() &&
                        _formKeyEachTo.currentState!.validate()) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text(
                              'សូមបំពេញព័ត៍មានអ្នកដំណើរ',
                              style: TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.bold),
                            ),
                            content: Form(
                              key: _formInfoKey,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  TextFormField(
                                    controller: _usernameController,
                                    decoration: InputDecoration(
                                      labelText: 'ឈ្មោះ',
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'សូមបំពេញឈ្មោះ';
                                      }
                                      return null;
                                    },
                                  ),
                                  TextFormField(
                                    controller: _phoneNumberController,
                                    decoration: InputDecoration(
                                        labelText: 'លេខទូរស័ព្ទ'),
                                    keyboardType: TextInputType.phone,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'សូមបំពេញលេខទូរស័ព្ទ';
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),
                            actions: <Widget>[
                              TextButton(
                                child: Text('លុបចោល'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                              ElevatedButton(
                                style: ButtonStyle(
                                    backgroundColor:
                                        WidgetStatePropertyAll(Colors.red)),
                                child: Text(
                                  'បញ្ជូន',
                                  style: TextStyle(color: Colors.white),
                                ),
                                onPressed: () async {
                                  if (_formInfoKey.currentState!.validate()) {
                                    Navigator.of(context).pop();
                                    postData();
                                    // Handle submission logic here
                                    //   name: _usernameController.text,
                                    //   phoneNumber:  _phoneNumberController.text,
                                    // latCur;
                                    //       longCur;
                                    //       latDir;
                                    //       longDir;
                                  }
                                },
                              ),
                            ],
                          );
                        },
                      );
                    }
                  } else {
                    print("Logout Token: $token");
                    nextScreen(context, SignInAccountScreen());
                  }
                },
                style: const ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll(Colors.red),
                ),
                child: Text(
                  'បញ្ជាក់ការកក់',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                )),
          ),
        )
    );
  }
}
