import 'package:flutter/material.dart';
import 'package:scholarar/util/color_resources.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:geocoding/geocoding.dart';

class DisplayScreen extends StatefulWidget {
  @override
  _DisplayScreenState createState() => _DisplayScreenState();
}

class _DisplayScreenState extends State<DisplayScreen> {
  List<Map<String, dynamic>>? storedTripsData;
  bool isLoading = true;
  int? _expandedIndex; // To keep track of which trip card is expanded

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedData = prefs.getString('driverTrips'); // Updated key to 'driverTrips'

    if (storedData != null) {
      List<dynamic> decodedData = json.decode(storedData);
      setState(() {
        storedTripsData = decodedData
            .map((data) => data as Map<String, dynamic>)
            .toList()
            .reversed
            .toList(); // Reverse the list
        isLoading = false;
      });
      print('Stored Trips Data: $storedTripsData');
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<String> _getAddressFromCoordinates(double latitude, double longitude) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
    if (placemarks.isNotEmpty) {
      Placemark place = placemarks.first;
      return '${place.street}, ${place.locality}, ${place.administrativeArea}, ${place.country}';
    }
    return 'Unknown location';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '​ប្រវត្តិការបញ្ជាកក់', // Updated title to English for consistency
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : storedTripsData != null && storedTripsData!.isNotEmpty
              ? SingleChildScrollView(
                  child: Column(
                    children: List.generate(
                      storedTripsData!.length,
                      (index) => _buildTripCard(storedTripsData![index], index),
                    ),
                  ),
                )
              : Center(child: Text('អ្នកមិនធ្លាប់បញ្ជាការកក់ទេ')),
    );
  }

  Widget _buildTripCard(Map<String, dynamic> tripData, int index) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //SizedBox(height: 10),
              Row(
                children: [
                  Container(
                    // padding: EdgeInsets.all(5),
                    alignment: Alignment.center,
                    child: CircleAvatar(
                      backgroundImage: AssetImage('assets/images/human.jpg'),
                      radius: 21,
                    )
                  ),
                  SizedBox(width: 10),
                  Text(
                    'អំពីការធ្វើដំណើរ:',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              _buildSummaryInfo(tripData),
              TextButton(
                onPressed: () {
                  setState(() {
                    _expandedIndex = _expandedIndex == index ? null : index; // Toggle details for the clicked card
                  });
                },
                child: Text(
                  _expandedIndex == index ? 'មើលខ្លី' : 'មើលលម្អិត',
                  style: TextStyle(color: Colors.teal),
                ),
              ),
              Visibility(
                visible: _expandedIndex == index, // Show details only for the clicked card
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _buildDetailInfo(tripData),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryInfo(Map<String, dynamic> tripData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildInfoRow('លេខសម្គាល់ការកក់', tripData['_id']),
            _buildInfoRow('Status', tripData['status']),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'កាលបរិច្ឆេទ:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Text(
              tripData['createdAt'],
              style: TextStyle(
                color: Colors.black54,
              ),
            ),
          ],
        )
      ],
    );
  }

  List<Widget> _buildDetailInfo(Map<String, dynamic> tripData) {
    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildInfoRow('ឈ្មោះអ្នកដំណើរ', tripData['passenger_name']),
          _buildInfoRow('លេខទូរស័ព្ទអ្នកដំណើរ', tripData['passenger_phone_number']),
        ],
      ),
      FutureBuilder<String>(
        future: _getAddressFromCoordinates(
          tripData['start_location']['coordinates'][1],
          tripData['start_location']['coordinates'][0],
        ),
        builder: (context, snapshot) {
          return _buildInfoRow('ទីតាំងចាប់ផ្ដើម', snapshot.data ?? 'Loading...');
        },
      ),
      FutureBuilder<String>(
        future: _getAddressFromCoordinates(
          tripData['end_location']['coordinates'][1],
          tripData['end_location']['coordinates'][0],
        ),
        builder: (context, snapshot) {
          return _buildInfoRow('ទីតាំងបញ្ចប់', snapshot.data ?? 'Loading...');
        },
      ),
      // FutureBuilder<String>(
      //   future: _getAddressFromCoordinates(
      //     tripData['driver_location']['coordinates'][1],
      //     tripData['driver_location']['coordinates'][0],
      //   ),
      //   builder: (context, snapshot) {
      //     return _buildInfoRow('ទីតាំងអ្នកបើកបរ', snapshot.data ?? 'Loading...');
      //   },
      // ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildInfoRow('ឈ្មោះអ្នកបើកបរ', '${tripData['driver_id']['first_name']} ${tripData['driver_id']['last_name']}'),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0),
            child: Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.payments_outlined,
                        color: Colors.teal,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'តម្លៃ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${tripData['cost']} រៀល',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ];
  }

  Widget _buildInfoRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Text(
              value != null ? value.toString() : 'N/A',
              style: TextStyle(
                color: value == "accepted" ? Colors.green : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
