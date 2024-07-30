// ignore_for_file: prefer_const_constructors

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:scholarar/controller/auth_controller.dart';
import 'package:scholarar/helper/get_di.dart';
import 'package:scholarar/util/app_constants.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:scholarar/util/next_screen.dart';
import 'package:scholarar/view/screen/account/sing_in_account_screen.dart';
import 'package:scholarar/view/screen/booking/booking_screen.dart';
import 'package:scholarar/view/screen/home/waiting.dart';
import 'package:curved_drawer_fork/curved_drawer_fork.dart';
import 'package:scholarar/view/screen/profile/profile_screen.dart';
import 'package:scholarar/view/screen/profile/settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CurrentLocation extends StatefulWidget {
  const CurrentLocation({super.key});

  @override
  State<CurrentLocation> createState() => _CurrentLocationState();
}

class _CurrentLocationState extends State<CurrentLocation> {
  SharedPreferences? sharedPreferences;
  AuthController authController = Get.find<AuthController>();
  bool fromSelected = false;
  bool toSelected = false;
  bool isLoading = false;
  late GoogleMapController googleMapController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyEachFrom = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyEachTo = GlobalKey<FormState>();
  TextEditingController _searchController = TextEditingController();
  TextEditingController _searchFromController = TextEditingController(text: selectedFromAddress);
  TextEditingController _searchToController = TextEditingController(text: selectedToAddress);

  // If not yet login
  final _usernameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formInfoKey = GlobalKey<FormState>();

  static const CameraPosition initialCameraPosition = CameraPosition(
    target: LatLng(11.672144885466007, 105.0565917044878), 
    zoom: 15,
  );

  Set<Marker> markers = {};
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
    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  void searchLocation() async {
    try {
      List<Location> locations = await locationFromAddress(_searchController.text);
      if (locations.isNotEmpty) {
        LatLng searchedLatLng = LatLng(locations[0].latitude, locations[0].longitude);

        markers.clear();
        markers.add(Marker(
          markerId: MarkerId('searchedLocation'), 
          position: searchedLatLng,
        ));

        googleMapController.animateCamera(CameraUpdate.newLatLng(searchedLatLng));

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

  Future<void> getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    LatLng currentLatLng = LatLng(position.latitude, position.longitude);

    markers.clear();
    markers.add(Marker(
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
    List<Placemark> placemarks = await placemarkFromCoordinates(latLng.latitude, latLng.longitude);
    Placemark place = placemarks[0];
    setState(() {
      selectedFromAddress = "${place.name}, ${place.thoroughfare}, ${place.subLocality}, ${place.locality}";
      _searchFromController.text = selectedFromAddress;
    });
  }

  void getAddressToLatLng(LatLng latLng) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(latLng.latitude, latLng.longitude);
    Placemark place = placemarks[0];
    setState(() {
      selectedToAddress = "${place.name}, ${place.thoroughfare}, ${place.subLocality}, ${place.locality}";
      _searchToController.text = selectedToAddress;
    });
  }

  Future<void> before() async {
    await _getGeoLocationPosition();
    await getCurrentLocation();
    setState(() {
      // Placeholder for additional setup if needed
    });
  }

  final PageController _pageController = PageController();

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
    super.initState();
    init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CurvedDrawer(
        color: const Color.fromARGB(255, 255, 240, 219),
        buttonBackgroundColor: Colors.lightGreenAccent,
        labelColor: Colors.red,
        backgroundColor: Colors.transparent,
        width: 75.0,
        items: const <DrawerItem>[
          DrawerItem(icon: Icon(Icons.home), label: "Home"),
          DrawerItem(icon: Icon(FontAwesomeIcons.car), label: "Booking"),
          DrawerItem(icon: Icon(Icons.person), label: "Profile"),
        ],
        onTap: (index) {
          print('Button Pressed');
          _pageController.animateToPage(index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut);
        },
      ),
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
                        markers: markers,
                        zoomControlsEnabled: false,
                        mapType: MapType.normal,
                        onMapCreated: (GoogleMapController controller) {
                          googleMapController = controller;
                        },
                        onTap: toSelected == false
                            ? (LatLng latLng) {
                                markers.clear();
                                markers.add(Marker(
                                    markerId: MarkerId('selectedLocation'),
                                    position: latLng));
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
                        left: 10,
                        child: Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: IconButton(
                                  icon: Icon(Icons.person),
                                  color: Colors.white,
                                  onPressed: () {
                                    String token = sharedPreferences!.getString(AppConstants.token) ?? "";
                                    if (token.isNotEmpty) {
                                      print("First Check Token $token");
                                      nextScreenReplace(Get.context, SettingScreen());
                                    } else {
                                      print("Logout Token: ");
                                      nextScreenReplace(context, SignInAccountScreen());
                                    }
                                  },
                                ),
                              ),
                            ),
                            SizedBox(width: MediaQuery.sizeOf(context).width * 1 / 24),
                            Container(
                              width: MediaQuery.sizeOf(context).width * 17 / 24,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(25),
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    IconButton(
                                      color: Colors.black,
                                      icon: Icon(Icons.search),
                                      onPressed: () {},
                                    ),
                                    SizedBox(width: MediaQuery.sizeOf(context).width * 0.5 / 24),
                                    Expanded(
                                      child: TextField(
                                        controller: _searchController,
                                        decoration: InputDecoration(
                                          hintText: "Search",
                                          hintStyle: TextStyle(color: Colors.grey),
                                          border: InputBorder.none,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      'Undo Selected Location',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ],
                                ),
                              ),
                            ),
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
                          Row(
                            children: [
                              Container(
                                width: MediaQuery.sizeOf(context).width * 3 / 24,
                                child: Text(
                                  'From',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                      border: Border.all(color: Colors.red),
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 5),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.only(left: 5, right: 5),
                                            child: Form(
                                              key: _formKeyEachFrom,
                                              child: TextFormField(
                                                controller: _searchFromController,
                                                validator: (un_value) {
                                                  if (un_value == null || un_value.isEmpty) {
                                                    return 'Please choose FROM location';
                                                  }
                                                  return null;
                                                },
                                                enabled: false,
                                                decoration: InputDecoration(
                                                  labelText: 'Select location',
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
                                          if (_formKeyEachFrom.currentState?.validate() ?? false) {
                                            fromSelected = true;
                                            latCur = selectedLatLng.latitude;
                                            longCur = selectedLatLng.longitude;
                                            print(latCur);
                                            print(longCur);
                                          }
                                        });
                                      },
                                      child: Text('OK', style: TextStyle(color: Colors.red)),
                                    )
                                  : Container(),
                            ],
                          ),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              Container(
                                width: MediaQuery.sizeOf(context).width * 3 / 24,
                                child: Text(
                                  'To',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                      border: Border.all(color: Colors.red),
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 5, right: 5),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.only(left: 5),
                                            child: Form(
                                              key: _formKeyEachTo,
                                              child: TextFormField(
                                                controller: _searchToController,
                                                validator: (un_value) {
                                                  if (un_value == null || un_value.isEmpty) {
                                                    return 'Please choose TO location';
                                                  }
                                                  return null;
                                                },
                                                enabled: false,
                                                decoration: InputDecoration(
                                                  labelText: 'Select location',
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
                                          if (_formKeyEachTo.currentState?.validate() ?? false) {
                                            toSelected = true;
                                          }
                                        });
                                      },
                                      child: Text('OK', style: TextStyle(color: Colors.red)),
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
            if (isLoading)
              Container(
                color: Colors.white.withOpacity(0.8),
                child: Center(
                  child: Text('Loading...'),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
            width: MediaQuery.sizeOf(context).width,
            child: Padding(
              padding: const EdgeInsets.all(3.0),
              child: ElevatedButton(
                onPressed: () async {
                  setState(() {
                    latDir = selectedLatLng.latitude;
                    longDir = selectedLatLng.longitude;
                    print(latDir);
                    print(longDir);
                    isLoading = true;
                  });
                  if ((_formKeyEachFrom.currentState?.validate() ?? false) &&
                      (_formKeyEachTo.currentState?.validate() ?? false)) {
                    nextScreen(context, BookingScreen());
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
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
