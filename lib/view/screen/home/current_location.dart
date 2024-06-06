import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:scholarar/util/app_constants.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:scholarar/view/screen/home/waiting.dart';

class CurrentLocation extends StatefulWidget {
  const CurrentLocation({super.key});

  @override
  State<CurrentLocation> createState() => _CurrentLocationState();
}

class _CurrentLocationState extends State<CurrentLocation> {
  bool isLoading = false;
  late GoogleMapController googleMapController;
  TextEditingController _searchFromController = TextEditingController(text: selectedFromAddress);
  TextEditingController _searchToController = TextEditingController(text: selectedToAddress);

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

  void searchFromLocation() async {
    try {
      List<Location> locations =
          await locationFromAddress(_searchToController.text);
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
          getAddressFromLatLng(searchedLatLng);
        });
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void searchToLocation() async {
    try {
      List<Location> locations =
          await locationFromAddress(_searchToController.text);
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
          getAddressFromLatLng(searchedLatLng);
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
      getAddressFromLatLng(currentLatLng);
    });
  }

  Future getCurrentFromLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    LatLng currentLatLng = LatLng(position.latitude, position.longitude);

    markers.clear();
    markers.add(
        Marker(markerId: MarkerId('currentLocation'), position: currentLatLng));

    googleMapController.animateCamera(CameraUpdate.newLatLng(currentLatLng));

    setState(() {
      selectedLatLng = currentLatLng;
      getAddressFromLatLng(currentLatLng);
    });
  }

  Future getCurrentToLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    LatLng currentLatLng = LatLng(position.latitude, position.longitude);

    markers.clear();
    markers.add(
        Marker(markerId: MarkerId('currentLocation'), position: currentLatLng));

    googleMapController.animateCamera(CameraUpdate.newLatLng(currentLatLng));

    setState(() {
      selectedLatLng = currentLatLng;
      getAddressFromLatLng(currentLatLng);
    });
  }

  void getAddressFromLatLng(LatLng latLng) async {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(latLng.latitude, latLng.longitude);
    Placemark place = placemarks[0];
    setState(() {
      selectedFromAddress =
          "${place.name}, ${place.thoroughfare}, ${place.subLocality}, ${place.locality}";
    });
  }

  void getAddressToLatLng(LatLng latLng) async {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(latLng.latitude, latLng.longitude);
    Placemark place = placemarks[0];
    setState(() {
      selectedToAddress =
          "${place.name}, ${place.thoroughfare}, ${place.subLocality}, ${place.locality}";
    });
  }

  before() async {
    await _getGeoLocationPosition();
    await getCurrentLocation();
    setState(() {
      //_searchFromController = selectedAddress;
      latCur = selectedLatLng.latitude;
      longCur = selectedLatLng.longitude;
      print(latCur);
      print(longCur);
    });
  }

  @override
  void initState() {
    before();
    super.initState();
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
                          onTap: (LatLng latLng) {
                            markers.clear();
                            markers.add(Marker(
                                markerId: MarkerId('selectedLocation'),
                                position: latLng));
                            setState(() {
                              selectedLatLng = latLng;
                              getAddressFromLatLng(latLng);
                            });
                          },
                        ),
                        Positioned(
                          top: 10,
                          left: 10,
                          child: Container(
                                child: ElevatedButton(
                                    style: const ButtonStyle(
                                      backgroundColor:
                                          MaterialStatePropertyAll(Colors.red),
                                    ),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.arrow_back_ios,
                                          color: Colors.white,
                                        ),
                                        Text(
                                          'ត្រឡប់ក្រោយ',
                                          style: TextStyle(color: Colors.white),
                                        )
                                      ],
                                    )),
                              ),
                        ),
                        Positioned(
                          bottom: 10,
                          right: 10,
                          child: FloatingActionButton(
                            onPressed: () async {
                              await getCurrentLocation();
                            },
                            child: Icon(Icons.my_location),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                      padding: EdgeInsets.fromLTRB(5, 5, 10, 5),
                      child: Expanded(
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  width:
                                      MediaQuery.sizeOf(context).width * 3 / 24,
                                  child: Text(
                                    'From',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
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
                                          selectedFromAddress.isNotEmpty
                                          ? Container()
                                          : InkWell(
                                            onTap: () {},
                                            child: Container(
                                              padding: EdgeInsets.fromLTRB(
                                                  5, 8, 5, 8),
                                              decoration: BoxDecoration(
                                                  color: Colors.red,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                              child: Text(
                                                'CURRENT',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                    color: Colors.white),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 5),
                                              child: TextField(
                                                controller:
                                                    _searchFromController,
                                                decoration: InputDecoration(
                                                    suffixIcon: IconButton(
                                                      onPressed: () {},
                                                      icon: Icon(Icons.search,
                                                          color: Colors.black),
                                                    ),
                                                    hintText: selectedFromAddress.isNotEmpty
                        ? selectedFromAddress
                        :'Search...',
                                                    border: InputBorder.none),
                                                onSubmitted: (query) =>
                                                    searchFromLocation(),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                TextButton(onPressed: () {}, child: Text('OK'))
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                Container(
                                  width:
                                      MediaQuery.sizeOf(context).width * 3 / 24,
                                  child: Text(
                                    'To',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
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
                                          selectedToAddress.isNotEmpty
                                          ? Container()
                                          : InkWell(
                                            child: Container(
                                              padding:
                                                  EdgeInsets.fromLTRB(5, 8, 5, 8),
                                              decoration: BoxDecoration(
                                                  color: Colors.red,
                                                  borderRadius:
                                                      BorderRadius.circular(10)),
                                              child: Text(
                                                'CURRENT',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                    color: Colors.white),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 5),
                                              child: TextField(
                                                controller: _searchToController,
                                                decoration: InputDecoration(
                                                    suffixIcon: IconButton(
                                                      onPressed: () {},
                                                      icon: Icon(Icons.search,
                                                          color: Colors.black),
                                                    ),
                                                    hintText: 'Search...',
                                                    border: InputBorder.none),
                                                onSubmitted: (query) =>
                                                    searchFromLocation(),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                TextButton(onPressed: () {}, child: Text('OK'))
                              ],
                            ),
                          ],
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
                      await Future.delayed(Duration(seconds: 3), () {
                        setState(() {
                          isLoading = false;
                        });
                      });
                      //await postAddress();
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext context) => const Waiting(),
                          ));
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
