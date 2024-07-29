// ignore_for_file: prefer_const_constructors

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
<<<<<<< HEAD
import 'package:get/get_core/src/get_main.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:scholarar/controller/auth_controller.dart';
=======
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:scholarar/controller/auth_controller.dart';
import 'package:scholarar/helper/get_di.dart';
>>>>>>> develop_chhenglun
import 'package:scholarar/util/app_constants.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:scholarar/util/next_screen.dart';
<<<<<<< HEAD
import 'package:scholarar/view/screen/booking/booking_screen.dart';
import 'package:scholarar/view/screen/home/alert_content.dart';
=======
import 'package:scholarar/view/screen/account/sing_in_account_screen.dart';
import 'package:scholarar/view/screen/booking/booking_screen.dart';
>>>>>>> develop_chhenglun
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
<<<<<<< HEAD
=======
  SharedPreferences? sharedPreferences;
>>>>>>> develop_chhenglun
  AuthController authController = Get.find<AuthController>();
  bool fromSelected = false;
  bool ToSelected = false;
  bool isLoading = false;
  late GoogleMapController googleMapController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyEachFrom = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyEachTo = GlobalKey<FormState>();
  TextEditingController _searchController = TextEditingController();
  TextEditingController _searchFromController =
      TextEditingController(text: selectedFromAddress);
  TextEditingController _searchToController =
      TextEditingController(text: selectedToAddress);

  //If not yet login
  final _usernameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formInfoKey = GlobalKey<FormState>();

  static const CameraPosition initialCameraPosition = CameraPosition(
      target: LatLng(11.672144885466007, 105.0565917044878), zoom: 15);

  //target: LatLng(37.42796133580664, -122.085749655962), zoom: 14);

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

        markers.clear();
        markers.add(Marker(
            markerId: MarkerId('searchedLocation'), position: searchedLatLng));

        googleMapController
            .animateCamera(CameraUpdate.newLatLng(searchedLatLng));

        setState(() {
          selectedLatLng = searchedLatLng;
          fromSelected == false
              ? getAddressFromLatLng(searchedLatLng)
              : getAddressToLatLng(searchedLatLng);
        });
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    LatLng currentLatLng = LatLng(position.latitude, position.longitude);

    markers.clear();
    markers.add(
        Marker(markerId: MarkerId('currentLocation'), position: currentLatLng));

    googleMapController.animateCamera(CameraUpdate.newLatLng(currentLatLng));

    setState(() {
      selectedLatLng = currentLatLng;
      fromSelected == false
          ? getAddressFromLatLng(currentLatLng)
          : getAddressToLatLng(currentLatLng);
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

  before() async {
    await _getGeoLocationPosition();
    await getCurrentLocation();
    setState(() {
      //_searchFromController = selectedAddress;
      // latCur = selectedLatLng.latitude;
      // longCur = selectedLatLng.longitude;
      // print(latCur);
      // print(longCur);
    });
  }

  final _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
  }
  init() async {
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
        // appBar: AppBar(
        //   leading: TextButton(
        //             onPressed: () {
        //               Navigator.pop(context);
        //             },
        //             child: Row(
        //               children: [Icon(Icons.arrow_back_ios), Text('ត្រឡប់ក្រោយ')],
        //             )),
        //   title: const Text("ជ្រើសរើសទីតាំងចាប់ផ្ដើម", style: TextStyle(fontSize: 12),),
        //   centerTitle: true,
        // ),
        // floatingActionButton: FloatingActionButton(
        //   onPressed: () async {
        //     await getCurrentLocation();
        //   },
        //   child: Icon(Icons.my_location),
        // ),
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
            //Optional Label Text
            //DrawerItem(icon: Icon(Icons.phone), label: "Contact")
          ],
          onTap: (index) {
            print('Button Pressed');

            _pageController.animateToPage(index,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut);
          },
        ),
        //drawer: Drawer(),
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
                            onTap: ToSelected == false
                                ? (LatLng latLng) {
                                    markers.clear();
                                    markers.add(Marker(
                                        markerId: MarkerId('selectedLocation'),
                                        position: latLng));
                                    setState(() {
                                      selectedLatLng = latLng;
                                      fromSelected == false
                                          ? getAddressFromLatLng(latLng)
                                          : getAddressToLatLng(latLng);
                                    });
                                  }
                                : null),
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
<<<<<<< HEAD
                                  child: Builder(
                                    builder: (BuildContext context) {
                                      return IconButton(
                                        icon: Icon(Icons.menu),
                                        color: Colors.white,
                                        onPressed: () {
                                          Scaffold.of(context).openDrawer();
                                        },
                                      );
                                    },
                                  ),
                                  // child: IconButton(
                                  //     icon: Icon(
                                  //       Icons.menu, //Icons.arrow_back_ios,
                                  //     ),
                                  //     color: Colors.white,
                                  //     // onPressed: () {
                                  //     //   setState(() {
                                  //     //     selectedFromAddress = '';
                                  //     //     selectedToAddress = '';
                                  //     //   });
                                  //     //   Navigator.pop(context);
                                  //     // },
                                  //     onPressed: () {
                                  //       Scaffold.of(context).openDrawer();
                                  //     }),
                                ),
                              ),
                              SizedBox(
                                width:
                                    MediaQuery.sizeOf(context).width * 1 / 24,
                              ),
                              ToSelected == false
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
                                                  hintText: "Search",
                                                  hintStyle: TextStyle(
                                                      color: Colors.grey),
                                                  border: InputBorder.none,
                                                ),
                                                onSubmitted: (query) =>
                                                    searchLocation(),
                                              ),
                                            ),
                                          ],
=======
                                  child: IconButton(
                                    icon: Icon(
                                      Icons.person, // Icons.arrow_back_ios,
                                    ),
                                    color: Colors.white,
                                    onPressed: ()  {
                                      //If this device already has a token then go to profile screen if not go to sign-in scre
                                      String token = sharedPreferences!.getString(AppConstants.token) ?? "";
                                      if (token != null && token.isNotEmpty) {
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
                                  border:
                                      Border.all(color: Colors.white, width: 2),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 6),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      IconButton(
                                        color: Colors.black,
                                        icon: Icon(
                                          Icons.search,
>>>>>>> develop_chhenglun
                                        ),
                                      ),
<<<<<<< HEAD
                                    )
                                  : ElevatedButton(
                                      style: ButtonStyle(
                                          backgroundColor:
                                              WidgetStatePropertyAll(
                                                  Colors.white)),
                                      onPressed: () {
                                        setState(() {
                                          selectedFromAddress = '';
                                          selectedToAddress = '';
                                        });
                                        nextScreenReplace(
                                            Get.context, CurrentLocation());
                                      },
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.cancel,
                                            color: Colors.red,
=======
                                      SizedBox(width: MediaQuery.sizeOf(context).width * 0.5 / 24),
                                      Expanded(
                                        child: TextField(
                                          controller: _searchController,
                                          decoration: InputDecoration(
                                            hintText: "Search",
                                            hintStyle:
                                                TextStyle(color: Colors.grey),
                                            border: InputBorder.none,
>>>>>>> develop_chhenglun
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Text(
                                            'Undo Selected Location',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ],
                                      ))
                            ],
                          ),
                        ),
                        ToSelected == false
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
                                    width: MediaQuery.sizeOf(context).width *
                                        3 /
                                        24,
                                    child: Text(
                                      'From',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                          border: Border.all(color: Colors.red),
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 5),
                                        child: Row(
                                          children: [
                                            // selectedFromAddress.isNotEmpty
                                            //     ? Container()
                                            //     : InkWell(
                                            //         onTap: () {},
                                            //         child: Container(
                                            //           padding:
                                            //               EdgeInsets.fromLTRB(
                                            //                   5, 8, 5, 8),
                                            //           decoration: BoxDecoration(
                                            //               color: Colors.red,
                                            //               borderRadius:
                                            //                   BorderRadius
                                            //                       .circular(10)),
                                            //           child: Text(
                                            //             'CURRENT',
                                            //             style: TextStyle(
                                            //                 fontSize: 12,
                                            //                 color: Colors.white),
                                            //           ),
                                            //         ),
                                            //       ),
                                            Expanded(
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 5, right: 5),
                                                child: Form(
                                                  key: _formKeyEachFrom,
                                                  child: TextFormField(
                                                    controller:
                                                        _searchFromController,
                                                    validator: (un_value) {
                                                      if (un_value == null ||
                                                          un_value.isEmpty) {
                                                        return 'Please choose FROM location';
                                                      }
                                                      return null;
                                                    },
                                                    enabled:
                                                        false, //!fromSelected,
                                                    decoration: InputDecoration(
                                                        // suffixIcon: fromSelected ==
                                                        //         false
                                                        //     ? IconButton(
                                                        //         onPressed: () {},
                                                        //         icon: Icon(
                                                        //             Icons.search,
                                                        //             color: Colors
                                                        //                 .black),
                                                        //       )
                                                        //     : null,
                                                        // hintText: selectedFromAddress
                                                        //         .isNotEmpty
                                                        //     ? selectedFromAddress
                                                        //     : 'Select location...',
                                                        labelText:
                                                            'Select location',
                                                        border:
                                                            InputBorder.none),
                                                    // onSubmitted: (query) =>
                                                    //     searchFromLocation(),
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
                                                latCur =
                                                    selectedLatLng.latitude;
                                                longCur =
                                                    selectedLatLng.longitude;
                                                print(latCur);
                                                print(longCur);
                                              }
                                            });
                                          },
                                          child: Text('OK',
                                              style:
                                                  TextStyle(color: Colors.red)))
                                      : Container()
                                  // : TextButton(
                                  //     onPressed: () {},
                                  //     child: Text('  ',))
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: [
                                  Container(
                                    width: MediaQuery.sizeOf(context).width *
                                        3 /
                                        24,
                                    child: Text(
                                      'To',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                          border: Border.all(color: Colors.red),
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 5, right: 5),
                                        child: Row(
                                          children: [
                                            // selectedToAddress.isNotEmpty
                                            //     ? Container()
                                            //     : InkWell(
                                            //         child: Container(
                                            //           padding:
                                            //               EdgeInsets.fromLTRB(
                                            //                   5, 8, 5, 8),
                                            //           decoration: BoxDecoration(
                                            //               color: Colors.red,
                                            //               borderRadius:
                                            //                   BorderRadius
                                            //                       .circular(10)),
                                            //           child: Text(
                                            //             'CURRENT',
                                            //             style: TextStyle(
                                            //                 fontSize: 12,
                                            //                 color: Colors.white),
                                            //           ),
                                            //         ),
                                            //       ),
                                            Expanded(
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 5),
                                                child: Form(
                                                  key: _formKeyEachTo,
                                                  child: TextFormField(
                                                    controller:
                                                        _searchToController,
                                                    validator: (un_value) {
                                                      if (un_value == null ||
                                                          un_value.isEmpty) {
                                                        return 'Please choose To location';
                                                      }
                                                      return null;
                                                    },
                                                    enabled:
                                                        false, //!ToSelected,
                                                    decoration: InputDecoration(
                                                        // suffixIcon: ToSelected ==
                                                        //         false
                                                        //     ? IconButton(
                                                        //         onPressed: () {},
                                                        //         icon: Icon(
                                                        //             Icons.search,
                                                        //             color: Colors
                                                        //                 .black),
                                                        //       )
                                                        //     : null,
                                                        // hintText: selectedToAddress
                                                        //         .isNotEmpty
                                                        //     ? selectedToAddress
                                                        //     : 'Select location',
                                                        labelText:
                                                            'Select location',
                                                        border:
                                                            InputBorder.none),
                                                    // onSubmitted: (query) =>
                                                    //     searchToLocation(),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  ToSelected == false
                                      ? TextButton(
                                          onPressed: () {
                                            setState(() {
                                              if (_formKeyEachTo.currentState
                                                      ?.validate() ??
                                                  false) {
                                                ToSelected = true;
                                              }
                                            });
                                          },
                                          child: Text(
                                            'OK',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        )
                                      : Container()
                                ],
                              ),
                            ],
                          ),
                        ),
                      )),
                  // Padding(
                  //   padding: const EdgeInsets.fromLTRB(5, 10, 5, 10),
                  //   child: Column(
                  //     mainAxisAlignment: MainAxisAlignment.start,
                  //     crossAxisAlignment: CrossAxisAlignment.start,
                  //     children: [
                  //       Text("Latitude: ${selectedLatLng.latitude}"),
                  //       Text("Longitude: ${selectedLatLng.longitude}"),
                  //     ],
                  //   ),
                  // ),
                ],
              ),
              if (isLoading == true)
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
            // Container(
            //     width: MediaQuery.sizeOf(context).width * 7 / 12,
            //     child: Padding(
            //       padding: const EdgeInsets.all(3.0),
            //       child: Text(
            //         selectedAddress.isNotEmpty
            //             ? selectedAddress
            //             : 'សូមជ្រើសរើសទីតាំងគោលដៅលើផែនទី ឬអាចចុចប៊ូតុងដើម្បីកំណត់យកទីតាំងបច្ចុប្បន្ន',
            //         style: TextStyle(color: Colors.grey.shade500),
            //       ),
            //     )),
            Container(
              padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
              width: MediaQuery.sizeOf(context).width * 12 / 12,
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
<<<<<<< HEAD
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
                                'សូមបំពេញព័ត៍មានផ្ទាល់ខ្លួន',
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
                                    TextFormField(
                                      controller: _passwordController,
                                      decoration: InputDecoration(
                                          labelText: 'លេខសម្ងាត់'),
                                      keyboardType: TextInputType.text,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'សូមដាក់លេខសម្ងាត់';
                                        }
                                        return null;
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              actions: <Widget>[
                                TextButton(
                                  child: Text('Cancel'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                ElevatedButton(
                                  style: ButtonStyle(
                                      backgroundColor:
                                          WidgetStatePropertyAll(Colors.red)),
                                  child: Text(
                                    'Submit',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  onPressed: () async {
                                    if (_formInfoKey.currentState!.validate()) {
                                      // Handle submission logic here
                                      await authController
                                          .registerBoookingController(
                                        context,
                                        name: _usernameController.text,
                                        gender: '',
                                        phoneNumber:
                                            _phoneNumberController.text,
                                        email: '',
                                        password: _passwordController.text,
                                      );
                                      // await Navigator.push(
                                      //   context,
                                      //   MaterialPageRoute(
                                      //       builder: (context) =>
                                      //           BookingScreen()),
                                      // );
                                    }
                                  },
                                ),
                              ],
                            );
                          },
                        );
                        // Navigator.push(
                        //     context,
                        //     MaterialPageRoute(
                        //       builder: (BuildContext context) =>
                        //           const Waiting(),
                        //     ));
                      }
=======
                      if (_formKeyEachFrom.currentState!.validate() &&
                              _formKeyEachTo.currentState!.validate() ??
                          false) {
                       nextScreen(context, BookingScreen());
                      }
                      // await Future.delayed(Duration(seconds: 3), () {
                      //   setState(() {
                      //     isLoading = false;
                      //   });
                      // });
>>>>>>> develop_chhenglun
                      //await postAddress();
                      // Navigator.push(
                      //     context,
                      //     MaterialPageRoute(
                      //       builder: (BuildContext context) => const Waiting(),
                      //     ));
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
            ),
          ],
        ));
  }
}
