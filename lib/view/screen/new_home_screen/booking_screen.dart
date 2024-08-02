import 'package:flutter/material.dart';
import 'package:scholarar/util/color_resources.dart';
import 'package:scholarar/util/next_screen.dart';
import 'package:scholarar/view/screen/new_home_screen/booking_detail_screen.dart';
class Booking {
  final String id;
  final String title;
  final String date;
  final String status;

  Booking({required this.id, required this.title, required this.date, required this.status});
}

class BookingHistoryScreen extends StatefulWidget {
  @override
  State<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen> {
  final List<Booking> bookings = [
    Booking(id: '1', title: 'Booking 1', date: '2024-07-29', status: 'Completed'),
    Booking(id: '2', title: 'Booking 2', date: '2024-07-30', status: 'Completed'),
    Booking(id: '3', title: 'Booking 3', date: '2024-07-31', status: 'Completed'),
  ];

  bool isLoading = true;

  Future<void> init() async {
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    setState(() {
      init();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Booking History',style: TextStyle(color: ColorResources.whiteColor),),
        centerTitle: true,
        backgroundColor: Colors.red,
      ),
      body: isLoading != false
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final booking = bookings[index];
          return Card(
            elevation: 5,
            margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            child: ListTile(
              leading: CircleAvatar(
                child: Text(booking.title[0]),
                backgroundColor: Colors.blue,
              ),
              title: Text(booking.title),
              subtitle: Text('Date: ${booking.date}\nStatus: ${booking.status}'),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {
                nextScreen(context, BookingDetailScreen(booking: booking));
              },
            ),
          );
        },
      ),
    );
  }
}
