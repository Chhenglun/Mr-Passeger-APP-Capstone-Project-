import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scholarar/util/next_screen.dart';
import 'package:scholarar/view/screen/home/current_location.dart';
import 'package:scholarar/view/screen/home/slide.dart';
import 'package:scholarar/view/screen/new_home_screen/premium.dart';
import '../../../controller/splash_controller.dart';

class NewHomeScreen extends StatefulWidget {
  const NewHomeScreen({super.key});

  @override
  State<NewHomeScreen> createState() => _NewHomeScreenState();
}

class _NewHomeScreenState extends State<NewHomeScreen> {

  @override

  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: 3,
      child: GetBuilder<SplashController>(builder: (splash){
      return Scaffold(
        // appBar: AppBar(
        //   backgroundColor: Colors.red.shade600,
        //   centerTitle: true,
        //   title: Text('Mr. Driver App',style: TextStyle(fontSize: 24,color: Colors.white),),
        // ),
        appBar: AppBar(
        automaticallyImplyLeading: false,
        title: TypewriterAnimatedTextKit(
          text: ['Welcome To Mr. Driver App'],
          textStyle: TextStyle(
            color: Colors.red,
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
          speed: Duration(milliseconds: 200),
        ),
        actions: [
          IconButton(
              onPressed: () {
                // LocalNotifications.showSimpleNotification(
                //     title: "Message from KUNVATH",
                //     body: "Hello! How are you today?",
                //     payload: "This is simple data");
              },
              icon: Icon(
                Icons.notifications,
                color: Colors.red,
              ))
        ],
      ),
        body: Column(
          children: [
            Expanded(
              child: Column(
                children: [
                  SliderHome(),
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Expanded(child: _buildHumanButton()),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Expanded(child: _buildPassAppButton()),
                  ),
                  //PremiumPlanPage()
                ],
              ),
            ),
          ],
        ),
          );
        }
      ),
    );
  }
  Widget _buildHumanButton() {
    return InkWell(
      onTap: () {
        nextScreen(context, CurrentLocation());
      },
      // onTap: () {
      //   //await _firebaseAPI.initNotifications();
      //   String? deviceToken =frmTokenPublic; // Use the token obtained from initNotifications
      //   String driverId =authController.userPassengerMap?["userDetails"]["_id"]; // Ensure this is the correct driver ID
      //   if (deviceToken != null && driverId != null) {
      //     _trackingController.updateToken(deviceToken, driverId);
      //     isLoading = true;
      //     customShowSnackBar('ការបើកការកក់របស់អ្នកទទួលបានជោគជ័យ', context, isError: false);
      //     nextScreen(context, CurrentLocation());
      //   } else {
      //     customShowSnackBar('Device token or driver ID is missing', context,
      //         isError: true);
      //   }
      // },
      child: Card(
        color: Colors.grey.shade300,
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: EdgeInsets.all(5),
          alignment: Alignment.center,
          child: CircleAvatar(
            backgroundImage: AssetImage('assets/images/human.jpg'),
            radius: 60,
          )
        ),
      ),
    );
  }
  Widget _buildPassAppButton(){
    return InkWell(
      onTap: () {},
      child: Card(
        color: Colors.grey.shade300,
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: EdgeInsets.all(5),
          alignment: Alignment.center,
          child: CircleAvatar(
            backgroundImage: AssetImage('assets/images/passapp.jpg'),
            radius: 60,
          ),
        ),
      ),
    );
  }
}
